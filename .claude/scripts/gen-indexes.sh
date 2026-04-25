#!/usr/bin/env bash
#
# gen-indexes.sh
#
# 다음 5개 폴더의 INDEX.md를 자동 생성/갱신한다.
#   - docs/02-domains/INDEX.md       (도메인 목록 + completion 상태)
#   - docs/04-api/INDEX.md           (API 명세 목록)
#   - docs/05-data/INDEX.md          (스키마/정책 목록)
#   - docs/06-operations/INDEX.md    (운영 문서/런북 목록)
#   - docs/09-guides/INDEX.md        (가이드 목록)
#
# 자동 생성 영역은 마커 사이를 갱신:
#   <!-- AUTO:LIST:START --> ... <!-- AUTO:LIST:END -->
#
# 사용법:
#   bash .claude/scripts/gen-indexes.sh           # 갱신
#   bash .claude/scripts/gen-indexes.sh --check   # 갱신 필요 시 exit 1

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

MODE="apply"
[[ "${1:-}" == "--check" ]] && MODE="check"

# Extract first H1 heading from a markdown file (or filename if absent).
file_title() {
  local file="$1"
  local title
  title=$(grep -m1 '^# ' "$file" 2>/dev/null | sed 's/^# *//' | head -c 100)
  if [[ -z "$title" ]]; then
    basename "$file" .md
  else
    echo "$title"
  fi
}

# Domain completion status (matches sync-registry.sh logic).
domain_status() {
  local dir="$1"
  [[ ! -d "$dir" ]] && echo "missing" && return
  local md_count
  md_count=$(find "$dir" -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$md_count" -eq 0 ]]; then
    echo "skeleton"
    return
  fi
  if [[ -f "$dir/domain-model.md" && -f "$dir/business-rules.md" ]]; then
    if grep -q '{UNSET}' "$dir/domain-model.md" "$dir/business-rules.md" 2>/dev/null; then
      echo "partial"
    else
      echo "complete"
    fi
  else
    echo "partial"
  fi
}

# ---------- per-folder generators ----------

gen_domains_list() {
  echo "## 도메인 목록"
  echo
  echo "| 도메인 | 상태 | 주요 문서 |"
  echo "|---|---|---|"
  local has=0
  for d in docs/02-domains/*/; do
    [[ ! -d "$d" ]] && continue
    has=1
    local name status files
    name=$(basename "$d")
    status=$(domain_status "$d")
    files=$(find "$d" -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" 2>/dev/null \
            | sort | xargs -I{} basename {} .md | tr '\n' ',' | sed 's/,$//; s/,/, /g')
    [[ -z "$files" ]] && files='—'
    echo "| [\`$name\`](./$name/) | $status | $files |"
  done
  [[ "$has" -eq 0 ]] && echo "| _(도메인 없음)_ | — | — |"
}

gen_api_list() {
  echo "## REST API"
  echo
  local has=0
  for f in $(find docs/04-api/rest -maxdepth 1 -name "*.yaml" -o -name "*.yml" 2>/dev/null | sort); do
    has=1
    echo "- [\`$(basename "$f")\`](./rest/$(basename "$f"))"
  done
  [[ "$has" -eq 0 ]] && echo "_(REST API 명세 없음)_"
  echo
  echo "## 이벤트 스키마"
  echo
  has=0
  for f in $(find docs/04-api/events -maxdepth 1 -name "*.yaml" -o -name "*.yml" 2>/dev/null | sort); do
    has=1
    echo "- [\`$(basename "$f")\`](./events/$(basename "$f"))"
  done
  [[ "$has" -eq 0 ]] && echo "_(이벤트 스키마 없음)_"
  echo
  echo "## 공통 규약"
  echo
  for f in $(find docs/04-api -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" -not -name "INDEX.md" 2>/dev/null | sort); do
    local title
    title=$(file_title "$f")
    echo "- [$title](./$(basename "$f"))"
  done
}

gen_data_list() {
  echo "## 스키마"
  echo
  local has=0
  for f in $(find docs/05-data/schemas -maxdepth 1 -name "*.md" 2>/dev/null | sort); do
    has=1
    local title
    title=$(file_title "$f")
    echo "- [$title](./schemas/$(basename "$f"))"
  done
  [[ "$has" -eq 0 ]] && echo "_(스키마 없음)_"
  echo
  echo "## 마이그레이션"
  echo
  has=0
  for f in $(find docs/05-data/migrations -maxdepth 1 -name "*.md" 2>/dev/null | sort); do
    has=1
    local title
    title=$(file_title "$f")
    echo "- [$title](./migrations/$(basename "$f"))"
  done
  [[ "$has" -eq 0 ]] && echo "_(마이그레이션 없음)_"
  echo
  echo "## 정책"
  echo
  for f in $(find docs/05-data -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" -not -name "INDEX.md" 2>/dev/null | sort); do
    local title
    title=$(file_title "$f")
    echo "- [$title](./$(basename "$f"))"
  done
}

gen_operations_list() {
  echo "## 운영 문서"
  echo
  for f in $(find docs/06-operations -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" -not -name "INDEX.md" 2>/dev/null | sort); do
    local title
    title=$(file_title "$f")
    echo "- [$title](./$(basename "$f"))"
  done
  echo
  echo "## 런북"
  echo
  local has=0
  for f in $(find docs/06-operations/runbooks -maxdepth 1 -name "*.md" 2>/dev/null | sort); do
    has=1
    local title
    title=$(file_title "$f")
    echo "- [$title](./runbooks/$(basename "$f"))"
  done
  [[ "$has" -eq 0 ]] && echo "_(런북 없음)_"
  echo
  echo "## 버그 리포트"
  echo
  has=0
  for f in $(find docs/06-operations/bugs -maxdepth 1 -name "BUG-*.md" 2>/dev/null | sort); do
    has=1
    local title
    title=$(file_title "$f")
    echo "- [$title](./bugs/$(basename "$f"))"
  done
  [[ "$has" -eq 0 ]] && echo "_(등록된 버그 리포트 없음)_"
}

gen_guides_list() {
  echo "## 가이드 목록"
  echo
  echo "| 문서 | 주제 |"
  echo "|---|---|"
  for f in $(find docs/09-guides -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" -not -name "INDEX.md" 2>/dev/null | sort); do
    local title name
    title=$(file_title "$f")
    name=$(basename "$f")
    echo "| [\`$name\`](./$name) | $title |"
  done
}

# ---------- splicer ----------

splice_section() {
  local target="$1" content_file="$2"
  local start="<!-- AUTO:LIST:START -->"
  local end="<!-- AUTO:LIST:END -->"

  if ! grep -qF "$start" "$target" || ! grep -qF "$end" "$target"; then
    echo "ERROR: marker AUTO:LIST not found in $target" >&2
    return 1
  fi

  awk -v start="$start" -v end="$end" -v content_file="$content_file" '
    BEGIN { skipping = 0 }
    {
      if ($0 == start) {
        print
        while ((getline line < content_file) > 0) print line
        close(content_file)
        skipping = 1
        next
      }
      if ($0 == end) {
        skipping = 0
        print
        next
      }
      if (!skipping) print
    }
  ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
}

# Default header for newly created INDEX.md.
write_default_header() {
  local target="$1" title="$2" intro="$3"
  cat > "$target" <<EOF
# $title

> $intro
> 자동 생성됨. \`bash .claude/scripts/gen-indexes.sh\`로 갱신하세요.

<!-- AUTO:LIST:START -->
<!-- AUTO:LIST:END -->
EOF
}

# Process one folder: ensure INDEX.md exists with markers, splice list.
process_folder() {
  local folder="$1" title="$2" intro="$3" generator="$4"
  local target="$folder/INDEX.md"

  if [[ ! -f "$target" ]]; then
    if [[ "$MODE" == "check" ]]; then
      echo "MISSING: $target (run gen-indexes.sh)" >&2
      return 1
    fi
    write_default_header "$target" "$title" "$intro"
    echo "  [생성] $target"
  fi

  # Ensure markers exist (idempotent).
  if ! grep -qF "<!-- AUTO:LIST:START -->" "$target"; then
    if [[ "$MODE" == "check" ]]; then
      echo "ERROR: $target missing AUTO:LIST markers" >&2
      return 1
    fi
    printf '\n<!-- AUTO:LIST:START -->\n<!-- AUTO:LIST:END -->\n' >> "$target"
  fi

  local tmp
  tmp=$(mktemp)
  $generator > "$tmp"

  # Compare: build candidate, compare to current
  local candidate
  candidate=$(mktemp)
  cp "$target" "$candidate"
  splice_section "$candidate" "$tmp"

  if [[ "$MODE" == "check" ]]; then
    if ! diff -q "$target" "$candidate" >/dev/null 2>&1; then
      echo "STALE: $target" >&2
      diff -u "$target" "$candidate" | head -20 >&2
      rm -f "$tmp" "$candidate"
      return 1
    fi
  else
    if ! diff -q "$target" "$candidate" >/dev/null 2>&1; then
      cp "$candidate" "$target"
      echo "  [갱신] $target"
    else
      echo "  [변경 없음] $target"
    fi
  fi

  rm -f "$tmp" "$candidate"
  return 0
}

# ---------- main ----------

EXIT=0
echo "=== INDEX.md 자동 생성 (mode: $MODE) ==="
echo

process_folder "docs/02-domains" \
  "Domains Index" \
  "DDD 기반 비즈니스 도메인 목록과 진행 상태." \
  gen_domains_list || EXIT=1

process_folder "docs/04-api" \
  "API Index" \
  "REST API, 이벤트 스키마, 공통 규약 목록." \
  gen_api_list || EXIT=1

process_folder "docs/05-data" \
  "Data Index" \
  "데이터베이스 스키마, 마이그레이션, 데이터 정책 목록." \
  gen_data_list || EXIT=1

process_folder "docs/06-operations" \
  "Operations Index" \
  "배포, 운영, 장애 대응 문서와 런북 목록." \
  gen_operations_list || EXIT=1

process_folder "docs/09-guides" \
  "Guides Index" \
  "개발 컨벤션과 작업 가이드 목록." \
  gen_guides_list || EXIT=1

echo
if [[ "$MODE" == "check" ]]; then
  if [[ "$EXIT" -eq 0 ]]; then
    echo "OK: 모든 INDEX.md가 최신 상태입니다."
  else
    echo "ERROR: 일부 INDEX.md가 동기화되지 않았습니다." >&2
    echo "       Run: bash .claude/scripts/gen-indexes.sh" >&2
  fi
else
  echo "완료."
fi

exit "$EXIT"
