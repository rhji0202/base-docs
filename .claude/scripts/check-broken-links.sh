#!/bin/bash
# Check for broken relative links in markdown files under docs/
# Returns non-zero exit code if broken links are found

BROKEN=0
TOTAL=0

find docs/ -name "*.md" -type f 2>/dev/null | while read -r file; do
  dir=$(dirname "$file")

  # Extract relative markdown links: [text](relative/path.md) or [text](./relative/path.md)
  grep -oP '\[.*?\]\(\K(?!https?://|#|mailto:)[^)]+' "$file" 2>/dev/null | while read -r link; do
    # Remove anchor fragments
    link="${link%%#*}"
    # Skip empty
    [ -z "$link" ] && continue

    TOTAL=$((TOTAL + 1))

    # Resolve relative path
    target="$dir/$link"

    if [ ! -e "$target" ]; then
      echo "BROKEN: $file -> $link"
      BROKEN=$((BROKEN + 1))
    fi
  done
done

if [ "$BROKEN" -gt 0 ]; then
  echo ""
  echo "Found $BROKEN broken link(s) out of $TOTAL checked."
  exit 1
else
  echo "All links OK ($TOTAL checked)."
  exit 0
fi
