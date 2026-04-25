#!/usr/bin/env bash
#
# lint-docs.sh — 문서 건강 종합 검사
#
# 검사 항목:
#   1. {UNSET} 마커 잔존 카운트
#   2. registry.md 동기화 상태 (sync-registry --check)
#   3. INDEX.md 동기화 상태 (gen-indexes --check)
#   4. 깨진 마크다운 링크 (check-broken-links)
#   5. 400줄 초과 문서
#   6. 30일 이상 미검증 문서 (last_verified frontmatter)
#   7. tech-stack.md 변경 시 동일 커밋에 ADR 포함 여부 (git mode)
#
# Modes:
#   bash .claude/scripts/lint-docs.sh           # 전체 검사 (warnings + errors)
#   bash .claude/scripts/lint-docs.sh --strict  # 모든 경고를 에러로 (CI용)
#   bash .claude/scripts/lint-docs.sh --quick   # 동기화·링크만 (pre-commit용)

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

MODE="full"
case "${1:-}" in
  --strict) MODE="strict" ;;
  --quick) MODE="quick" ;;
esac

ERRORS=0
WARNINGS=0
TODAY=$(date +%s)
THIRTY_DAYS_AGO=$((TODAY - 30 * 86400))

# ---- color helpers (TTY only) ----
if [[ -t 1 ]]; then
  RED=$'\033[31m'; YEL=$'\033[33m'; GRN=$'\033[32m'; RST=$'\033[0m'
else
  RED=""; YEL=""; GRN=""; RST=""
fi

err()  { echo "${RED}ERROR${RST}: $*" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "${YEL}WARN${RST}: $*"; WARNINGS=$((WARNINGS + 1)); }
ok()   { echo "${GRN}OK${RST}: $*"; }
section() { echo; echo "==== $* ===="; }

# ---------- 1. UNSET markers ----------
check_unset() {
  section "1. {UNSET} 마커 검사"
  local count
  count=$(grep -r '{UNSET}' docs/ 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -eq 0 ]]; then
    ok "{UNSET} 마커 없음 (모든 항목 결정됨)"
  else
    warn "{UNSET} 마커 ${count}개 잔존"
    grep -rn '{UNSET}' docs/ 2>/dev/null | head -10 | sed 's/^/    /'
    [[ "$count" -gt 10 ]] && echo "    ... (${count}개 중 처음 10개만 표시)"
  fi
}

# ---------- 2. registry sync ----------
check_registry() {
  section "2. registry.md 동기화 상태"
  if [[ ! -x ".claude/scripts/sync-registry.sh" ]]; then
    warn "sync-registry.sh 없음. 건너뜀."
    return
  fi
  if bash .claude/scripts/sync-registry.sh --check >/dev/null 2>&1; then
    ok "registry.md is up to date"
  else
    err "registry.md 동기화 필요. Run: bash .claude/scripts/sync-registry.sh"
  fi
}

# ---------- 3. indexes sync ----------
check_indexes() {
  section "3. INDEX.md 동기화 상태"
  if [[ ! -x ".claude/scripts/gen-indexes.sh" ]]; then
    warn "gen-indexes.sh 없음. 건너뜀."
    return
  fi
  if bash .claude/scripts/gen-indexes.sh --check >/dev/null 2>&1; then
    ok "5개 INDEX.md 모두 최신"
  else
    err "일부 INDEX.md 동기화 필요. Run: bash .claude/scripts/gen-indexes.sh"
  fi
}

# ---------- 4. broken links ----------
check_links() {
  section "4. 깨진 링크 검사"
  if [[ ! -x ".claude/scripts/check-broken-links.sh" ]]; then
    warn "check-broken-links.sh 없음. 건너뜀."
    return
  fi
  local out
  out=$(bash .claude/scripts/check-broken-links.sh 2>&1)
  if echo "$out" | tail -1 | grep -q "^All links OK"; then
    ok "$(echo "$out" | tail -1)"
  else
    err "깨진 링크 발견:"
    echo "$out" | sed 's/^/    /'
  fi
}

# ---------- 5. file size ----------
check_file_size() {
  section "5. 파일 크기 (>400줄)"
  local long_files
  long_files=$(find docs/ -name "*.md" -type f -exec wc -l {} + 2>/dev/null | awk '$1 > 400 && !/total/ { print $1, $2 }')
  if [[ -z "$long_files" ]]; then
    ok "모든 문서가 400줄 이하"
  else
    while IFS= read -r line; do
      warn "긴 문서 ($line)"
    done <<<"$long_files"
  fi
}

# ---------- 6. stale (last_verified) ----------
check_stale() {
  section "6. 30일 이상 미검증 문서 (last_verified)"
  local stale_count=0
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    local lv
    lv=$(awk '
      BEGIN { in_fm = 0 }
      /^---[[:space:]]*$/ { if (in_fm == 1) exit; in_fm = 1; next }
      in_fm == 1 && /^last_verified:/ {
        sub(/^last_verified:[[:space:]]*/, "")
        gsub(/[" \r\t]/, "")
        print
        exit
      }
    ' "$file")
    [[ -z "$lv" ]] && continue
    local lv_epoch
    if lv_epoch=$(date -j -f "%Y-%m-%d" "$lv" +%s 2>/dev/null); then
      :
    elif lv_epoch=$(date -d "$lv" +%s 2>/dev/null); then
      :
    else
      continue
    fi
    if [[ "$lv_epoch" -lt "$THIRTY_DAYS_AGO" ]]; then
      warn "stale: $file (last_verified: $lv)"
      stale_count=$((stale_count + 1))
    fi
  done < <(grep -rl '^last_verified:' docs/ 2>/dev/null)

  if [[ "$stale_count" -eq 0 ]]; then
    ok "30일 이상 미검증 문서 없음"
  fi
}

# ---------- 7. tech-stack vs ADR ----------
check_tech_stack_adr() {
  section "7. tech-stack.md 변경 vs ADR (git)"
  if ! command -v git >/dev/null 2>&1; then
    warn "git 미사용 환경. 건너뜀."
    return
  fi
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    warn "git repo 아님. 건너뜀."
    return
  fi
  # Check unstaged + staged changes only (not full history).
  if git diff --name-only HEAD 2>/dev/null | grep -q "docs/03-architecture/tech-stack.md"; then
    if git diff --name-only HEAD 2>/dev/null | grep -q "docs/07-decisions/ADR-"; then
      ok "tech-stack.md 변경에 ADR 동반됨"
    else
      err "tech-stack.md가 변경되었으나 동일 변경 세트에 ADR이 없음. 새 ADR 작성 필요."
    fi
  else
    ok "tech-stack.md 변경 없음"
  fi
}

# ---------- 8. F-XXX feature without registry entry ----------
check_orphan_features() {
  section "8. registry에 없는 Feature"
  local orphans=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    local id
    id=$(awk '
      BEGIN { in_fm = 0 }
      /^---[[:space:]]*$/ { if (in_fm == 1) exit; in_fm = 1; next }
      in_fm == 1 && /^id:/ {
        sub(/^id:[[:space:]]*/, "")
        gsub(/[" \r\t]/, "")
        print
        exit
      }
    ' "$f")
    [[ -z "$id" ]] && continue
    if ! grep -q "^${id}:" docs/00-overview/registry.md 2>/dev/null; then
      warn "Feature $id가 registry.md에 없음 ($f)"
      orphans=$((orphans + 1))
    fi
  done < <(find docs/01-product/features -maxdepth 1 -name 'F-*.md' 2>/dev/null)

  if [[ "$orphans" -eq 0 ]]; then
    ok "모든 Feature가 registry에 등록됨"
  fi
}

# ---------- main ----------

case "$MODE" in
  quick)
    check_registry
    check_indexes
    check_links
    ;;
  *)
    check_unset
    check_registry
    check_indexes
    check_links
    check_file_size
    check_stale
    check_tech_stack_adr
    check_orphan_features
    ;;
esac

echo
echo "==== 요약 ===="
echo "에러: ${ERRORS}, 경고: ${WARNINGS}"

# strict 모드: warning도 실패로 처리
if [[ "$MODE" == "strict" ]] && [[ "$WARNINGS" -gt 0 ]]; then
  exit 1
fi

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi

exit 0
