# Notify the team

Read this when you need to send a team notification after acting on an issue.
The notification channel is configurable; **this project currently uses WeCom
(기업위챗)**, so the payload/encoding below follow WeCom's webhook contract. If
the project later switches channels (Slack, Discord, Telegram…), only the
**Sending** snippet changes — the URL discovery and the "when to notify" rules
stay the same.

Send by default for outcomes that need someone's attention:

- a PR was opened (**auto-fix → fixed**),
- a PR was updated on resume (follow-up commits pushed),
- the issue was labeled **needs-info** or **needs-decision** (someone has to
  respond before it can move).

By default don't notify for `skip`, `question`, or a `fixed` issue you didn't
touch this run (already had its PR, awaiting review — nothing new to report) —
those need no team action and the ping is just noise.
This is a default, not a hard rule: if the user explicitly asks you to notify for
one of these, do it — their instruction wins. For a `--triage-only` sweep, a
per-issue ping for every `needs-info`/`needs-decision` can be a lot of noise; if
you're sorting a big backlog, prefer one summary ping (or none) over dozens —
use judgment and lean quiet unless the user wants each one.

## Finding the webhook URL

The webhook URL is a secret (it embeds the key) — it is NOT in this file. The
config key is `NOTIFY_WEBHOOK_URL`. Look in this order and use the first non-empty
value:

1. the `NOTIFY_WEBHOOK_URL` env var, then
2. a `NOTIFY_WEBHOOK_URL=` line in the repo-root `.env`.

```bash
NOTIFY_WEBHOOK_URL="${NOTIFY_WEBHOOK_URL:-$(grep -E '^NOTIFY_WEBHOOK_URL=' .env 2>/dev/null | head -1 | cut -d= -f2- | sed 's/^["'"'"']//; s/["'"'"']$//')}"
```

If nothing is set, skip the notification (don't fail the run) and tell the user
it wasn't sent because no channel is configured. To configure it, add the key to
the repo `.env` (already git-ignored) or export it:

```bash
export NOTIFY_WEBHOOK_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=<key>'
```

## Sending — WeCom contract (build JSON with `jq -a`, do NOT hand-write the heredoc)

Korean content gets mangled two ways with WeCom and you must defend against both:

1. A raw `-d "{...}"` heredoc on Git-Bash/Windows corrupts the bytes before curl
   sees them. → Build the payload with `jq`, never by hand.
2. WeCom is a Chinese service and decodes the body as GBK unless told otherwise,
   so even correct UTF-8 bytes render as mojibake. → Use `jq -a` (emits pure
   ASCII `\uXXXX` escapes, unbreakable in transit) **and** send the
   `charset=utf-8` header.

Both together are what actually fixed it — `jq` alone or the header alone was not
enough. Send like this (the `msgtype:"markdown"` payload is WeCom-specific; swap
it if the channel changes):

```bash
if [ -n "$NOTIFY_WEBHOOK_URL" ]; then
  SLUG=$(gh repo view --json nameWithOwner -q .nameWithOwner)   # don't hard-code ydj317/redpost
  OUTCOME="수정 PR 생성"          # plain-Korean action taken; fill per the outcome
  PR_URL="https://github.com/$SLUG/pull/358"   # set to the real PR url, or leave empty for non-fix outcomes

  # Build the body with REAL newlines. The newline must live in printf's FORMAT
  # string — printf does NOT expand \n inside a %s argument, so never smuggle a
  # "\n> ..." string through %s (that's what renders as a literal "n>" in WeCom).
  # Append the optional PR line as its own printf only when there's a URL.
  CONTENT=$(printf '**이슈 #%s 처리 완료**\n> 제목: %s\n> 결과: %s\n> [이슈 보기](https://github.com/%s/issues/%s)' \
    "$ISSUE" "$TITLE" "$OUTCOME" "$SLUG" "$ISSUE")
  [ -n "$PR_URL" ] && CONTENT="$CONTENT$(printf '\n> [PR 보기](%s)' "$PR_URL")"

  PAYLOAD=$(jq -na --arg c "$CONTENT" '{msgtype:"markdown",markdown:{content:$c}}')
  RESP=$(curl -s "$NOTIFY_WEBHOOK_URL" \
    -H 'Content-Type: application/json; charset=utf-8' \
    --data-binary "$PAYLOAD")
  echo "$RESP" | jq -e '.errcode == 0' >/dev/null \
    && echo "notification sent OK" \
    || echo "notification FAILED — team did NOT get the ping: $RESP"
fi
```

`$ISSUE`/`$TMP`/`$TITLE` don't survive across Bash calls — re-derive them here
(`ISSUE` from the argument,
`TMP="$(git rev-parse --show-toplevel)/.triage-issue-tmp/issue-$ISSUE"`, `TITLE`
with `jq -r .title "$TMP/issue.json"`). Set `OUTCOME` to the plain-Korean action
taken (예: `수정 PR 생성`, `needs-info 라벨 — 추가 정보 요청`, `needs-decision
라벨 — 결정 요청`). Set `PR_URL` to the real PR url for a fix, or leave it empty
for non-fix outcomes (the PR line is then omitted).

> **Why this shape (don't revert it):** an earlier version asked you to fill a
> `<PR_LINE>` placeholder with the string `\n> [PR 보기](url)` and pass it through
> a trailing `%s`. `printf` only interprets `\n` in its **format string**, never
> in a `%s` value, so that newline shipped to WeCom literally and rendered as a
> broken `이슈 보기n> PR 보기`. Keeping every newline inside a `printf` format
> string — and adding the PR line as its own `printf` — is what makes the line
> break actually render.

Keep `<outcome>` to the action taken — don't append internal triage jargon. The
team reads this ping; say what happened in plain Korean (`오너 답변 완료`,
`추가 정보 요청`), not the label taxonomy. The snippet verifies `errcode == 0` (a
WeCom success field) — if it prints `FAILED`, the team did NOT get the ping, so
report that to the user. WeCom truncates long markdown, so keep it to a few lines.
