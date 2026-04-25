#!/usr/bin/env bash
#
# reset-samples.sh
#
# base-docs는 템플릿 저장소입니다. 이 저장소를 복제하여 실제 프로젝트를
# 시작할 때, 참고용으로 포함된 샘플 문서(F-001 user-authentication,
# identity 도메인, 관련 ADR 및 API/스키마 예시)를 일괄 제거하고
# INDEX.md / registry.md / CLAUDE.md의 샘플 참조를 모두 정리합니다.
#
# 제거 대상 파일:
#   - docs/01-product/features/F-001-user-authentication.md
#   - docs/02-domains/identity/ (디렉토리 전체)
#   - docs/07-decisions/ADR-001-monolith-first.md
#   - docs/07-decisions/ADR-002-postgresql.md
#   - docs/07-decisions/ADR-003-auth-strategy.md
#   - docs/04-api/rest/auth.yaml
#   - docs/04-api/events/identity-events.yaml
#   - docs/05-data/schemas/users.md
#
# 자동 정리 대상:
#   - docs/01-product/features/INDEX.md     (F-001 행 제거, 다음 ID 재설정)
#   - docs/07-decisions/INDEX.md            (ADR-001~003 행 제거, 카테고리 비움)
#   - docs/00-overview/registry.md          (sync-registry.sh로 재생성)
#   - CLAUDE.md (루트)                      (Bootstrap 체크박스 3개 해제)
#
# 사용법:
#   bash .claude/scripts/reset-samples.sh          # dry-run (미리보기)
#   bash .claude/scripts/reset-samples.sh --apply  # 실제 실행

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

SAMPLES=(
  "docs/01-product/features/F-001-user-authentication.md"
  "docs/02-domains/identity"
  "docs/07-decisions/ADR-001-monolith-first.md"
  "docs/07-decisions/ADR-002-postgresql.md"
  "docs/07-decisions/ADR-003-auth-strategy.md"
  "docs/04-api/rest/auth.yaml"
  "docs/04-api/events/identity-events.yaml"
  "docs/05-data/schemas/users.md"
)

APPLY=false
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

# Portable in-place file edit: rewrite via temp file.
edit_file() {
  local file="$1" filter="$2"
  [[ ! -f "$file" ]] && return 0
  local tmp
  tmp=$(mktemp)
  eval "$filter" < "$file" > "$tmp"
  mv "$tmp" "$file"
}

# ---------- file deletion ----------

echo "=== 샘플 문서 제거 ==="
echo "저장소: $REPO_ROOT"
echo

MISSING=0
FOUND=0
for path in "${SAMPLES[@]}"; do
  if [[ -e "$path" ]]; then
    echo "  [제거 예정] $path"
    FOUND=$((FOUND + 1))
  else
    echo "  [이미 없음] $path"
    MISSING=$((MISSING + 1))
  fi
done

echo
echo "발견: $FOUND, 이미 없음: $MISSING"
echo

# ---------- index/registry/CLAUDE preview ----------

echo "=== 인덱스/레지스트리 정리 예정 ==="
echo
echo "  1. docs/01-product/features/INDEX.md"
echo "     - F-001 행 제거"
echo "     - '다음 사용 가능 ID'를 F-001로 재설정"
echo
echo "  2. docs/07-decisions/INDEX.md"
echo "     - Active 테이블의 ADR-001~003 행 제거"
echo "     - '카테고리별' 섹션의 ADR-XXX 항목 제거"
echo
echo "  3. docs/00-overview/registry.md"
echo "     - sync-registry.sh가 자동 재생성"
echo
echo "  4. CLAUDE.md (루트)"
echo "     - Bootstrap Progress 3개 항목 체크 해제"
echo

if ! $APPLY; then
  echo "[dry-run] 실제로 실행하려면 --apply 옵션을 붙여 다시 실행하세요:"
  echo "  bash .claude/scripts/reset-samples.sh --apply"
  exit 0
fi

if [[ $FOUND -eq 0 ]] && [[ ! -f "docs/01-product/features/INDEX.md" ]]; then
  echo "정리할 항목이 없습니다. 종료합니다."
  exit 0
fi

# ---------- apply: delete files ----------

echo "=== 1단계: 샘플 파일 삭제 ==="
for path in "${SAMPLES[@]}"; do
  if [[ -e "$path" ]]; then
    rm -rf "$path"
    echo "  [삭제됨] $path"
  fi
done
echo

# ---------- apply: clean features/INDEX.md ----------

echo "=== 2단계: features/INDEX.md 정리 ==="
F_INDEX="docs/01-product/features/INDEX.md"
if [[ -f "$F_INDEX" ]]; then
  edit_file "$F_INDEX" 'sed -E "/^\| \[F-[0-9]{3}\]\(\.\/F-/d; s/다음 사용 가능 ID: \*\*F-[0-9]{3}\*\*/다음 사용 가능 ID: **F-001**/"'
  echo "  [갱신] $F_INDEX"
else
  echo "  [건너뜀] $F_INDEX (파일 없음)"
fi
echo

# ---------- apply: clean decisions/INDEX.md ----------

echo "=== 3단계: decisions/INDEX.md 정리 ==="
A_INDEX="docs/07-decisions/INDEX.md"
if [[ -f "$A_INDEX" ]]; then
  # Remove Active table data rows referencing ADR-XXX, and category bullet items.
  edit_file "$A_INDEX" 'sed -E "/^\| \[ADR-[0-9]{3}\]\(\.\/ADR-/d; /^- ADR-[0-9]{3}:/d"'
  echo "  [갱신] $A_INDEX"
else
  echo "  [건너뜀] $A_INDEX (파일 없음)"
fi
echo

# ---------- apply: regenerate registry.md ----------

echo "=== 4단계: registry.md 재생성 ==="
if [[ -x ".claude/scripts/sync-registry.sh" ]]; then
  if bash .claude/scripts/sync-registry.sh > /dev/null 2>&1; then
    echo "  [갱신] docs/00-overview/registry.md"
  else
    echo "  [경고] sync-registry.sh 실패 (수동 실행 필요)"
  fi
else
  echo "  [건너뜀] sync-registry.sh 없음"
fi
echo

echo "=== 4-2단계: 폴더별 INDEX.md 재생성 ==="
if [[ -x ".claude/scripts/gen-indexes.sh" ]]; then
  if bash .claude/scripts/gen-indexes.sh > /dev/null 2>&1; then
    echo "  [갱신] 5개 폴더의 INDEX.md"
  else
    echo "  [경고] gen-indexes.sh 실패 (수동 실행 필요)"
  fi
else
  echo "  [건너뜀] gen-indexes.sh 없음"
fi
echo

# ---------- apply: uncheck CLAUDE.md bootstrap items ----------

echo "=== 5단계: CLAUDE.md Bootstrap 체크박스 해제 ==="
ROOT_CLAUDE="CLAUDE.md"
if [[ -f "$ROOT_CLAUDE" ]]; then
  edit_file "$ROOT_CLAUDE" 'sed -E "
    s/^- \[x\] 첫 번째 도메인 \(identity\) 완성$/- [ ] 첫 번째 도메인 (identity) 완성/
    s/^- \[x\] 첫 번째 기능 \(F-001 user-authentication\) 완성$/- [ ] 첫 번째 기능 (F-001 user-authentication) 완성/
    s/^- \[x\] 첫 번째 ADR 시리즈 \(ADR-001~003\) 작성$/- [ ] 첫 번째 ADR 시리즈 (ADR-001~003) 작성/
  "'
  echo "  [갱신] $ROOT_CLAUDE"
else
  echo "  [건너뜀] $ROOT_CLAUDE (파일 없음)"
fi
echo

# ---------- 6. clean sample references in non-sample docs ----------

echo "=== 6단계: 비-샘플 문서의 sample 링크 정리 ==="
# These 4 docs are kept as structural examples but reference the deleted samples.
# Replace markdown links to deleted samples with placeholder text so links don't break.
SAMPLE_LINK_FILES=(
  "docs/03-architecture/overview.md"
  "docs/03-architecture/components.md"
  "docs/03-architecture/security.md"
  "docs/05-data/backup-recovery.md"
)

for f in "${SAMPLE_LINK_FILES[@]}"; do
  [[ ! -f "$f" ]] && continue
  edit_file "$f" 'sed -E "
    s|\[[^]]*\]\([^)]*ADR-00[123]-[^)]*\.md\)|_(관련 ADR 작성 필요)_|g
    s|\[[^]]*\]\([^)]*02-domains/identity[^)]*\)|_(관련 도메인)_|g
    s|\[[^]]*\]\([^)]*05-data/schemas/users\.md\)|_(관련 스키마)_|g
  "'
  echo "  [갱신] $f"
done
echo

# ---------- 7. broken-link report ----------

echo "=== 7단계: 깨진 링크 자동 검사 ==="
if [[ -x ".claude/scripts/check-broken-links.sh" ]]; then
  LINK_OUTPUT=$(bash .claude/scripts/check-broken-links.sh 2>&1 || true)
  if echo "$LINK_OUTPUT" | tail -1 | grep -q "^All links OK"; then
    echo "  [OK] 깨진 링크 없음"
  else
    echo "  [경고] 정리 후에도 깨진 링크가 남아있습니다. 직접 수정하세요:"
    echo
    echo "$LINK_OUTPUT" | grep "^BROKEN" | sed 's/^/    /'
    echo
  fi
else
  echo "  [건너뜀] check-broken-links.sh 없음"
fi
echo

# ---------- final ----------

echo "=== 완료 ==="
echo
echo "다음 단계:"
echo "  1. /init-project 명령으로 {UNSET} 항목을 채워가세요."
echo "  2. 7단계에서 보고된 깨진 링크가 있다면 수동으로 수정하세요."
echo "  3. 첫 기능 작성: /new-feature"
echo "  4. 종합 검증: bash .claude/scripts/lint-docs.sh"
