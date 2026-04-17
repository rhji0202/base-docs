#!/bin/bash
# Usage: next-id.sh [feature|adr|rfc|bug]
# Returns the next available ID for the given document type

TYPE="${1:-feature}"

case "$TYPE" in
  feature)
    PREFIX="F"
    DIR="docs/01-product/features"
    PATTERN="F-([0-9]+)"
    ;;
  adr)
    PREFIX="ADR"
    DIR="docs/07-decisions"
    PATTERN="ADR-([0-9]+)"
    ;;
  rfc)
    PREFIX="RFC"
    DIR="docs/08-rfcs"
    PATTERN="RFC-([0-9]+)"
    ;;
  bug)
    PREFIX="BUG"
    DIR="docs/06-operations/bugs"
    PATTERN="BUG-([0-9]+)"
    ;;
  *)
    echo "Usage: $0 [feature|adr|rfc|bug]" >&2
    exit 1
    ;;
esac

# Find the highest existing ID
MAX_ID=0
if [ -d "$DIR" ]; then
  for file in "$DIR"/*.md; do
    if [[ "$file" =~ $PATTERN ]]; then
      NUM="${BASH_REMATCH[1]}"
      # Remove leading zeros for comparison
      NUM=$((10#$NUM))
      if [ "$NUM" -gt "$MAX_ID" ]; then
        MAX_ID=$NUM
      fi
    fi
  done
fi

NEXT_ID=$((MAX_ID + 1))
NEXT_ID_PADDED=$(printf "%03d" $NEXT_ID)

echo "${PREFIX}-${NEXT_ID_PADDED}"
