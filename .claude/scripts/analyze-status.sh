#!/bin/bash
# Usage: analyze-status.sh
# Reports overall documentation health for the docs/ project.
# Cross-platform safe: uses printf (not echo -n), NUL-safe find loops, no sed -i.

set -u

DOCS_DIR="docs"

if [ ! -d "$DOCS_DIR" ]; then
  printf "ERROR: '%s' directory not found. Run from project root.\n" "$DOCS_DIR" >&2
  exit 1
fi

#
# 1. Total markdown files
#
TOTAL_FILES=0
while IFS= read -r -d '' _; do
  TOTAL_FILES=$((TOTAL_FILES + 1))
done < <(find "$DOCS_DIR" -type f -name "*.md" -print0)

#
# 2. Completion distribution (frontmatter: "completion: X")
#
count_completion() {
  local label="$1"
  local count=0
  while IFS= read -r -d '' file; do
    if grep -qE "^completion:[[:space:]]+${label}([[:space:]]|$)" "$file"; then
      count=$((count + 1))
    fi
  done < <(find "$DOCS_DIR" -type f -name "*.md" -print0)
  printf "%d" "$count"
}

COMPLETE_COUNT=$(count_completion "complete")
PARTIAL_COUNT=$(count_completion "partial")
SKELETON_COUNT=$(count_completion "skeleton")

#
# 3. {UNSET} markers: total occurrences and file count
#
UNSET_TOTAL=0
UNSET_FILES=0
declare -a UNSET_TOP_FILES=()
declare -a UNSET_TOP_COUNTS=()

count_unset() {
  # grep -c counts matching lines, not matches. Use grep -o | wc -l for total
  # occurrences, and normalize whitespace/CR to get a clean integer.
  grep -o "{UNSET" "$1" 2>/dev/null | wc -l | tr -cd '0-9'
}

while IFS= read -r -d '' file; do
  n=$(count_unset "$file")
  n=${n:-0}
  if [ "$n" -gt 0 ] 2>/dev/null; then
    UNSET_TOTAL=$((UNSET_TOTAL + n))
    UNSET_FILES=$((UNSET_FILES + 1))
    UNSET_TOP_FILES+=("$file")
    UNSET_TOP_COUNTS+=("$n")
  fi
done < <(find "$DOCS_DIR" -type f -name "*.md" -print0)

# Also scan CLAUDE.md at repo root (it's the main entry point)
if [ -f "CLAUDE.md" ]; then
  n=$(count_unset "CLAUDE.md")
  n=${n:-0}
  if [ "$n" -gt 0 ] 2>/dev/null; then
    UNSET_TOTAL=$((UNSET_TOTAL + n))
    UNSET_FILES=$((UNSET_FILES + 1))
    UNSET_TOP_FILES+=("CLAUDE.md")
    UNSET_TOP_COUNTS+=("$n")
  fi
fi

#
# 4. Large files (>400 lines)
#
LARGE_COUNT=0
declare -a LARGE_FILES=()
declare -a LARGE_LINES=()

while IFS= read -r -d '' file; do
  # wc -l is POSIX; strip whitespace
  lines=$(wc -l < "$file" | tr -d ' \t\r\n')
  if [ "$lines" -gt 400 ]; then
    LARGE_COUNT=$((LARGE_COUNT + 1))
    LARGE_FILES+=("$file")
    LARGE_LINES+=("$lines")
  fi
done < <(find "$DOCS_DIR" -type f -name "*.md" -print0)

#
# 5. Today's date (portable)
#
TODAY=$(date +%Y-%m-%d)

#
# Output report
#
printf "## Documentation Health Report\n"
printf "%s\n\n" "- Date: $TODAY"

printf "### Summary\n"
printf "| 항목 | 수치 |\n"
printf "|---|---|\n"
printf "| 전체 문서 | %d files |\n" "$TOTAL_FILES"
printf "| Complete | %d |\n" "$COMPLETE_COUNT"
printf "| Partial | %d |\n" "$PARTIAL_COUNT"
printf "| Skeleton | %d |\n" "$SKELETON_COUNT"
printf "| {UNSET} 마커 | %d (%d files) |\n" "$UNSET_TOTAL" "$UNSET_FILES"
printf "| 400줄 초과 | %d files |\n\n" "$LARGE_COUNT"

#
# Top {UNSET} files (sorted by count, top 10)
#
printf "### Top {UNSET} Files\n"
if [ "${#UNSET_TOP_FILES[@]}" -eq 0 ]; then
  printf "_(none)_\n\n"
else
  # Build "count\tfile" lines, sort desc by count, take top 10
  TMP_UNSET=$(mktemp 2>/dev/null || printf "/tmp/analyze-status-unset.%s" "$$")
  : > "$TMP_UNSET"
  i=0
  while [ "$i" -lt "${#UNSET_TOP_FILES[@]}" ]; do
    printf "%s\t%s\n" "${UNSET_TOP_COUNTS[$i]}" "${UNSET_TOP_FILES[$i]}" >> "$TMP_UNSET"
    i=$((i + 1))
  done
  rank=1
  # sort numerically descending on first column
  while IFS=$'\t' read -r cnt path; do
    printf "%d. %s — %s개\n" "$rank" "$path" "$cnt"
    rank=$((rank + 1))
    if [ "$rank" -gt 10 ]; then
      break
    fi
  done < <(sort -rn -k1,1 "$TMP_UNSET")
  rm -f "$TMP_UNSET"
  printf "\n"
fi

#
# Large files list
#
printf "### Large Files (>400 lines)\n"
if [ "$LARGE_COUNT" -eq 0 ]; then
  printf "_(none)_\n\n"
else
  i=0
  while [ "$i" -lt "${#LARGE_FILES[@]}" ]; do
    printf "%s\n" "- ${LARGE_FILES[$i]} — ${LARGE_LINES[$i]} lines"
    i=$((i + 1))
  done
  printf "\n"
fi

#
# Bootstrap Progress (from CLAUDE.md)
#
printf "### Bootstrap Progress\n"
if [ -f "CLAUDE.md" ]; then
  # Extract the Bootstrap Progress section: from heading until next heading or EOF
  awk '
    /^## Bootstrap Progress/ { in_sec = 1; next }
    in_sec && /^## / { in_sec = 0 }
    in_sec { print }
  ' CLAUDE.md | grep -E '^- \[' || printf "_(checklist not found)_\n"
else
  printf "_(CLAUDE.md not found)_\n"
fi
printf "\n"

#
# Recommendations
#
printf "### Recommendations\n"
REC_COUNT=0
if [ "$UNSET_TOTAL" -gt 0 ]; then
  printf "* [ACTION] {UNSET} 마커 %d개 해결 (grep -rn '{UNSET' docs/ CLAUDE.md)\n" "$UNSET_TOTAL"
  REC_COUNT=$((REC_COUNT + 1))
fi
if [ "$SKELETON_COUNT" -gt 0 ]; then
  printf "* [ACTION] skeleton 문서 %d개를 partial/complete 로 승격\n" "$SKELETON_COUNT"
  REC_COUNT=$((REC_COUNT + 1))
fi
if [ "$LARGE_COUNT" -gt 0 ]; then
  printf "* [ACTION] 400줄 초과 파일 %d개 분할 검토\n" "$LARGE_COUNT"
  REC_COUNT=$((REC_COUNT + 1))
fi
if [ "$REC_COUNT" -eq 0 ]; then
  printf "* 문서 상태 양호 — 추가 조치 불필요\n"
fi
