#!/bin/bash
# PostToolUse hook: validate frontmatter on markdown files in docs/
# Receives JSON on stdin with tool_name and tool_input
# Exit 0 = OK, Exit 2 = blocking error

# Read hook input from stdin
INPUT=$(cat)

# Extract the file path from the tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

# Only validate markdown files in docs/
if [[ -z "$FILE_PATH" ]] || [[ ! "$FILE_PATH" =~ ^docs/.*\.md$ ]]; then
  exit 0
fi

# Only validate feature, ADR, and RFC files (they require frontmatter)
if [[ "$FILE_PATH" =~ docs/01-product/features/F- ]] || \
   [[ "$FILE_PATH" =~ docs/07-decisions/ADR- ]] || \
   [[ "$FILE_PATH" =~ docs/08-rfcs/RFC- ]]; then

  # Check if file has frontmatter (starts with ---)
  if ! head -1 "$FILE_PATH" 2>/dev/null | grep -q "^---"; then
    echo "WARNING: $FILE_PATH is missing frontmatter (---)" >&2
    # Non-blocking warning (exit 0, not exit 2)
    exit 0
  fi

  # Check required fields
  FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$FILE_PATH" 2>/dev/null)

  if ! echo "$FRONTMATTER" | grep -q "^id:"; then
    echo "WARNING: $FILE_PATH frontmatter missing 'id' field" >&2
  fi

  if ! echo "$FRONTMATTER" | grep -q "^status:"; then
    echo "WARNING: $FILE_PATH frontmatter missing 'status' field" >&2
  fi
fi

exit 0
