#!/usr/bin/env bash
# PostToolUse hook: Edit/Write 직후 .py 파일에 ruff check --fix + format 실행
# 입력: stdin JSON ({tool_input: {file_path: "..."}})
# 출력: stdin JSON 그대로 통과 (pass-through). ruff 실패는 stderr로 경고만 표시.

set -u

INPUT="$(cat)"
echo -n "$INPUT"  # pass-through to stdout (non-blocking hook contract)

# file_path 추출 (jq 없이 단순 파싱)
FILE_PATH="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null)"

[ -z "$FILE_PATH" ] && exit 0
[[ "$FILE_PATH" != *.py ]] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# 프로젝트 루트는 스크립트 위치(.claude/scripts/hooks/) 기준으로 도출
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# 프로젝트 venv의 ruff 우선, 없으면 PATH 폴백
RUFF="$PROJECT_ROOT/.venv/bin/ruff"
[ ! -x "$RUFF" ] && RUFF="$(command -v ruff 2>/dev/null)"
[ -z "$RUFF" ] && exit 0

# .claude/ 제외 (pre-commit 설정과 일치)
case "$FILE_PATH" in
  */.claude/*) exit 0 ;;
esac

# check --fix → format. 실패해도 hook은 차단하지 않음 (stderr로만 알림)
if ! "$RUFF" check --fix "$FILE_PATH" >&2; then
  echo "⚠️  ruff check 실패: $FILE_PATH" >&2
fi
if ! "$RUFF" format "$FILE_PATH" >&2; then
  echo "⚠️  ruff format 실패: $FILE_PATH" >&2
fi

exit 0
