# Resuming a prior fix (continue, don't restart)

Read this when a prior run **already touched this issue** and you want to continue
from its session instead of starting cold — the in-flight signals in the main flow
matched (any trace comment, a `fixed`/legacy `fix-submitted` label, an open
`fix/issue-<number>` PR, **or** a parked `needs-decision`/`needs-info` that a human
just answered). This is the only departure from the one-issue→one-fresh-branch
rule, and it applies only to the *same* issue's own prior work.

Two trigger shapes, two cases below:
- **case 0** — a non-fix outcome (`needs-decision`/`needs-info`) that a human
  comment newer than the trace now resolves. No branch/PR exists yet; you resume
  to carry the prior analysis into the now-unblocked work.
- **case 1–3** — a fix was already in flight (`fixed` label / open PR), and you
  continue on its existing branch.

> A `done` issue never reaches here — `done` is human-only and final, and the
> worker bails out on it in Setup before this file is ever read.

`$ISSUE` and `$TMP` come from Setup and don't survive across Bash calls —
re-derive them at the top of each snippet here (`ISSUE` from the argument,
`TMP="$(git rev-parse --show-toplevel)/.triage-issue-tmp/issue-$ISSUE"`).

If you find such a signal:

```bash
gh pr list --head "fix/issue-$ISSUE" --state open --json number,url,state
```

**Do not branch fresh and do not open a second PR** — a new `fix/issue-<number>`
collides with the existing branch and duplicates the work. Recover the prior
branch from the trace comment and continue on top of it.

## Recovering the branch from the trace

The trace lives in an HTML comment on a prior issue comment, in one of three
shapes (parse all — this skill and `fix-issue` share the branch convention, and
the oldest tool used a different format):

```
<!-- triage-issue · session: <id> · branch: fix/issue-336 · <sha> -->   (this skill)
<!-- fix-issue · session: <id> · branch: fix/issue-336 · <sha> -->      (fix-issue)
<!-- session:<id> branch:fix/issue-336 -->                              (legacy)
```

The `branch:` value is what you act on. The `session:<id>` is consumed by the
background-resume path below (and lets a human reopen the session manually with
`claude --resume <id>`); on its own, a running skill can't pull another session's
conversation into the current context. You recover the *work* from git (the
branch + commits) and the issue thread (what the prior comment said) — for almost
all follow-ups that's enough without resuming at all.

Pull the `branch:` value out, then decide:

0. **A parked non-fix outcome just got answered** (the issue is `needs-decision`
   or `needs-info`, has **no** branch/PR, and the latest comment — *newer than your
   trace* — supplies the missing decision or info: "A로 가주세요", "주문번호
   1024-0917 이고 결제 상태는 …", "그렇게 하기로 정했어요"). The prior session is the
   one that read the issue and wrote up exactly which decision/info it was waiting
   on — so resume **that** session and feed it the human's answer, rather than
   re-classifying cold and re-reading the whole thread. It then acts on the answer:
   typically the issue is now `auto-fix`-able, so the resumed session goes through
   the normal Fix flow (branch off `master-qa`, fix, review, PR, transition to
   `fixed`). If the answer only *partially* unblocks it, it may re-comment and stay
   `needs-decision`/`needs-info`. Use the **"Carrying the prior session's context"**
   procedure below — there's no existing branch here, so it creates `fix/issue-N`
   fresh off `master-qa` when a fix results. (No prior session id resumable? Fall
   through to a normal fresh classification — you still have the thread.)

1. **Owner asked for more work** (the latest comment is *newer than the trace* and
   reports the fix fell short — "아직 안 돼요", "여전히 같은 문제", "추가확인
   필요합니다", "수정 부탁", a review rejection): **resume the prior session and
   continue on its existing branch/PR.** This is the case the user cares about most
   — the prior run already did the analysis and the first fix, so you want its
   reasoning, not a cold restart.

   **Default path: resume the session.** Go to
   **[Carrying the prior session's context](#carrying-the-prior-sessions-context-resume-in-place)**
   below — pull `session:<id>` from the latest trace and `claude --resume` it in a
   worktree so it picks up exactly where it left off, addresses the new complaint,
   re-reviews, and pushes follow-up commits to the *same* PR.

   **Fallback (session id gone/pruned):** if there's no resumable session, continue
   from git alone — the branch + the issue thread are enough:
   ```bash
   git fetch origin
   git switch "fix/issue-$ISSUE" 2>/dev/null || git switch -c "fix/issue-$ISSUE" "origin/fix/issue-$ISSUE"
   ```
   Address the specific point the owner raised (re-read their comment — they told
   you what to check), go through the **Review** step again, commit, and `git push`
   to update the open PR. Comment on the issue with what changed, reusing the
   **same branch** in a fresh trace line. Do this work inside a worktree (below) so
   it never touches the main checkout.

2. **No open action — `fixed`, awaiting review** (PR open, nobody asked for
   changes): report the PR link + state and stop. The label stays `fixed`; a human
   moves it to `done` after reviewing. Nudging would be noise.

3. **PR was merged/closed and the issue is still open** for a genuinely new
   reason: treat it as a new fixable issue and branch fresh — the old branch is
   spent. Say so explicitly in your report.

When unsure which case you're in, surface the PR link and the latest comment and
ask the user rather than guessing — resuming on the wrong branch is hard to undo.

## Carrying the prior session's context (resume in place)

This is the shared engine for **case 0** (a `needs-decision`/`needs-info` issue a
human just answered) and **case 1** (a `fixed` issue with a "still broken"
follow-up). In both, a prior session already did the thinking — case 0's session
wrote up exactly which decision/info it was blocked on; case 1's investigated and
made the first fix. That reasoning lives in the session, not fully in the comments
or commits. Resuming it continues that train of thought instead of re-deriving it
cold, which is the whole point of carrying context forward.

You (the new worker) can't absorb another session's context into your own; the
only thing that restores it is `claude --resume <id>` **in its own process**. So
delegate the continuation to a resumed `claude`, run **from a worktree** so its
commits land on `fix/issue-$ISSUE` without touching the main checkout. You're
already isolated, so this is a normal foreground call you wait on — not another
background fan-out.

The one difference between the cases is the branch the worktree starts on:
- **case 1** — an existing `fix/issue-$ISSUE` branch/PR; check it out and add
  follow-up commits to the same PR.
- **case 0** — no branch yet; start the worktree on `origin/master-qa`. If the
  resumed session concludes a fix (the answer made it `auto-fix`-able), it creates
  `fix/issue-$ISSUE` there and opens the **first** PR; if the answer only partly
  unblocks it, it re-comments and stays non-fix (no branch).

**Resume continues a conversation — it does NOT re-trigger this skill.** A
resumed session picks up where it left off, with all its prior turns loaded. If
you pass `-p "/triage-issue $ISSUE"` to it, that reads as a new user message in
the old thread, not a fresh skill run — the model just answers it. So send a
plain-language instruction telling it to finish the job, not a slash command.

Run the `skip` bail-out and the in-flight branch check first; only then this.

**1. Find the prior session id** from the trace comments in `$TMP/issue.json`
(matches all three trace shapes):

```bash
PREV_SESSION=$(jq -r '[.comments[].body] | join("\n")' "$TMP/issue.json" \
  | grep -oE 'session: ?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' \
  | tail -1 | sed -E 's/session: ?//')
```

`tail -1` takes the most recent. No match → no resume: continue the normal flow
yourself (you have the branch + thread). Then confirm the transcript still
exists — sessions are pruned after `cleanupPeriodDays` (default 30):

```bash
ls ~/.claude/projects/*/"$PREV_SESSION".jsonl >/dev/null 2>&1 || PREV_SESSION=""
```

If it's gone, treat it as "no resume" and fall through to the normal flow.

**2. Resume in a worktree with a continue-the-work instruction** (only when
`PREV_SESSION` is set):

First capture the **human's latest message** — the answer (case 0) or the
complaint (case 1) — so you can hand it to the resumed session verbatim; it's the
reason you're resuming, so don't make the resumed run guess at it. It's the latest
comment without a trace marker:

```bash
HUMAN_MSG=$(jq -r '[.comments[] | select((.body|contains("<!-- triage-issue")) or (.body|contains("<!-- fix-issue")) | not) | .body] | last // ""' "$TMP/issue.json")
```

Set `RESUME_KIND` to which case you're in, then create the worktree on the right
base — case 1 reuses the existing branch (same PR); case 0 starts on
`origin/master-qa` (no branch yet):

```bash
ROOT=$(git rev-parse --show-toplevel)
WT="$ROOT/.triage-issue-worktrees/issue-$ISSUE"     # per-issue path → concurrent issues never collide
RESUME_KIND=case0      # case0 = parked needs-decision/needs-info now answered; case1 = fixed + still-broken

if [ "$RESUME_KIND" = "case1" ]; then
  git fetch origin "fix/issue-$ISSUE" 2>/dev/null || true
  git worktree add "$WT" "fix/issue-$ISSUE" 2>/dev/null \
    || git worktree add "$WT" -b "fix/issue-$ISSUE" "origin/fix/issue-$ISSUE" 2>/dev/null \
    || git worktree add "$WT" origin/master-qa 2>/dev/null || true   # last-resort: branch gone
else
  git fetch origin master-qa 2>/dev/null || true
  git worktree add "$WT" origin/master-qa 2>/dev/null || true        # case0: fresh, no branch yet
fi
```

Then resume, telling the session what's new and what to do. The instruction
differs only in framing the human's message (answer vs. complaint):

```bash
if [ "$RESUME_KIND" = "case1" ]; then
  SITUATION="Your earlier fix didn't fully resolve issue #$ISSUE. Here is the follow-up from the thread:

$HUMAN_MSG

You are resumed in a worktree on your existing fix/issue-$ISSUE branch (your prior commits are here). Address THIS follow-up, run the mandatory review subagent, commit and push to the SAME branch (updating the existing PR)."
else
  SITUATION="The decision/info you were waiting on for issue #$ISSUE has arrived. Here is the human's answer from the thread:

$HUMAN_MSG

You are resumed in a fresh worktree on origin/master-qa (no branch yet — you had parked this as needs-decision/needs-info). Act on the answer: if it makes the issue fixable, create the fix/issue-$ISSUE branch here, make the fix, run the mandatory review subagent, commit, push, and open the PR. If the answer only partly unblocks it, re-comment with what's still needed and stay non-fix."
fi

( cd "$WT" && claude --resume "$PREV_SESSION" --output-format json \
    --allowedTools "Bash,Edit,Read,Write,Glob,Grep,Task" \
    -p "$SITUATION

Pick up from where you left off using what you already know — you wrote the prior analysis on this issue. When you finish, comment on the issue with what changed (fresh trace line) and set the label: 'fixed' if you opened a PR, otherwise leave the appropriate triage label. Do NOT apply 'done' (a human does that). If it's still genuinely blocked, say so and stop — don't invent an answer. Do not ask me to clarify; act on your best judgment from the context you already have." )
```

- **Plain-language, not `/triage-issue`** — the resumed session continues its
  thread. The prompt re-establishes the worktree situation (it doesn't know it
  was moved) and tells it to finish.
- **No commit collisions:** every `git switch` / commit / push happens inside
  `$WT`. The main checkout's branch and index are untouched.
- `--resume "$PREV_SESSION"` runs from `$WT`, which resolves because session-id
  lookup spans the repo's whole worktree family. Must be a worktree of *this*
  repo — an unrelated directory fails the lookup.
- headless (`-p`) has no interactive approver, so tools must be pre-approved via
  `--allowedTools`. `gh`/`git`/`uv`/`curl` are all `Bash`; the review subagent is
  `Task`.
- This is a foreground call — wait on it, read its JSON result (`.result`,
  `.session_id`, `.is_error`), and fold its outcome (PR link, etc.) into your own
  worker summary rather than redoing it.

**3. Clean up (best-effort, optional).** The fix commits are already pushed, so
the worktree is disposable. Remove it with git's own command — never `rm -rf`
(see the cleanup note in Setup for why):

```bash
git worktree remove "$WT" --force 2>/dev/null || true
```

If that's denied or fails, leave it — `.triage-issue-worktrees/` is git-ignored,
so a leftover worktree never gets committed and is harmless. The same per-issue
path is reused on the next run for this issue.

**Fallback:** if the resumed run exits non-zero (`.is_error == true`) or its JSON
can't be parsed, don't abandon the issue — continue the normal Fix flow yourself
on the branch you recovered (and best-effort `git worktree remove`). Resume is an
optimization for context, not a hard dependency.

> Note on worktree vs branch/PR: removing the worktree never deletes the branch
> or the PR. Commits live in the main repo's `.git` and on origin; the PR lives
> on GitHub. The worktree is just a disposable checkout — re-create it anytime
> with `git worktree add` to keep working on the same branch/PR.
