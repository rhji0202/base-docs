#!/bin/bash
# PostToolUse hook: auto-sync registry.md when feature/domain/ADR docs change.
# Receives JSON on stdin with tool_name and tool_input.
# Non-blocking: always exits 0.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Decide which sync scripts to run based on which doc area changed.
RUN_REGISTRY=0
RUN_INDEXES=0

case "$FILE_PATH" in
  *docs/01-product/features/F-*.md|*docs/02-domains/*|*docs/07-decisions/ADR-*.md)
    RUN_REGISTRY=1
    RUN_INDEXES=1
    ;;
  *docs/04-api/*|*docs/05-data/*|*docs/06-operations/*|*docs/09-guides/*)
    RUN_INDEXES=1
    ;;
  *)
    exit 0
    ;;
esac

if [[ "$RUN_REGISTRY" -eq 1 ]] && [[ -x "$REPO_ROOT/.claude/scripts/sync-registry.sh" ]]; then
  if OUTPUT=$(bash "$REPO_ROOT/.claude/scripts/sync-registry.sh" 2>&1); then
    if echo "$OUTPUT" | grep -q "registry.md 갱신 완료"; then
      echo "[auto-sync] registry.md updated (trigger: $FILE_PATH)" >&2
    fi
  else
    echo "[auto-sync] WARNING: sync-registry failed" >&2
    echo "$OUTPUT" >&2
  fi
fi

if [[ "$RUN_INDEXES" -eq 1 ]] && [[ -x "$REPO_ROOT/.claude/scripts/gen-indexes.sh" ]]; then
  if OUTPUT=$(bash "$REPO_ROOT/.claude/scripts/gen-indexes.sh" 2>&1); then
    if echo "$OUTPUT" | grep -q "\[갱신\]"; then
      echo "[auto-sync] INDEX.md updated (trigger: $FILE_PATH)" >&2
    fi
  else
    echo "[auto-sync] WARNING: gen-indexes failed" >&2
    echo "$OUTPUT" >&2
  fi
fi

exit 0
