#!/usr/bin/env bash
# Check broken relative markdown links in docs/.
# Returns non-zero exit code if broken links are found.
#
# Skips:
#   - External URLs (http, https, mailto, tel, anchor-only)
#   - docs/99-templates/ (placeholder examples like F-XXX, ADR-XXX)
#   - File paths containing literal `XXX` (placeholder pattern)
#
# Portable: uses awk instead of grep -P (BSD grep does not support -P).
#
# Usage:
#   bash .claude/scripts/check-broken-links.sh                # check all
#   bash .claude/scripts/check-broken-links.sh --include-templates  # include 99-templates/

set -u

INCLUDE_TEMPLATES=false
[[ "${1:-}" == "--include-templates" ]] && INCLUDE_TEMPLATES=true

BROKEN=0
TOTAL=0
BROKEN_LIST=""

# Extract every markdown link (`[text](target)`) from a file, one per line.
# Multiple links on the same line are all captured.
# Skips links inside fenced code blocks (```), which are usually examples.
extract_links() {
  awk '
    /^```/ { in_code = !in_code; next }
    in_code { next }
    {
      s = $0
      while (match(s, /\[[^]]*\]\([^)]+\)/)) {
        link = substr(s, RSTART, RLENGTH)
        sub(/^\[[^]]*\]\(/, "", link)
        sub(/\)$/, "", link)
        print link
        s = substr(s, RSTART + RLENGTH)
      }
    }
  ' "$1"
}

while IFS= read -r file; do
  # Skip 99-templates/ unless explicitly included (placeholder examples, not real links).
  if ! $INCLUDE_TEMPLATES; then
    case "$file" in
      docs/99-templates/*) continue ;;
    esac
  fi

  dir=$(dirname "$file")
  while IFS= read -r link; do
    [[ -z "$link" ]] && continue

    # Skip external/anchor/email/protocol-relative.
    case "$link" in
      http://*|https://*|mailto:*|tel:*|\#*|//*) continue ;;
    esac

    # Skip placeholder patterns (e.g. F-XXX, ADR-XXX in code-block examples).
    case "$link" in
      *XXX*|*\**) continue ;;
    esac

    # Strip anchor fragment.
    link="${link%%#*}"
    # Strip query string.
    link="${link%%\?*}"
    [[ -z "$link" ]] && continue

    TOTAL=$((TOTAL + 1))
    target="$dir/$link"

    if [[ ! -e "$target" ]]; then
      BROKEN=$((BROKEN + 1))
      BROKEN_LIST="${BROKEN_LIST}BROKEN: $file -> $link"$'\n'
    fi
  done < <(extract_links "$file")
done < <(find docs/ -name "*.md" -type f 2>/dev/null)

if [[ "$BROKEN" -gt 0 ]]; then
  printf '%s' "$BROKEN_LIST"
  echo
  echo "Found $BROKEN broken link(s) out of $TOTAL checked."
  exit 1
else
  echo "All links OK ($TOTAL checked)."
  exit 0
fi
