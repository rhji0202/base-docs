# Resuming a prior fix (continue, don't restart)

Read this when a prior run **already touched this issue** and you want to continue
from its session instead of starting cold — the in-flight signals in the main flow
matched (any trace comment, a `fixed` label, an open `fix/issue-<number>` PR,
**or** a parked `pending` that a human just answered). This is the only departure
from the one-issue→one-fresh-branch rule, and it applies only to the *same* issue's
own prior work.

Four cases below, by what state the prior run left:
- **case 0** — a `pending` outcome (the prior run was blocked on a human: its trace
  carries `kind: decision`/`info`/`question`) that a human comment newer than the
  trace now resolves. No branch/PR exists yet; you resume to carry the prior
  analysis into the now-unblocked work, transitioning `pending` → `doing`.
- **case 1** — a fix in flight (`fixed` label / open PR) with a newer "still broken"
  comment: continue on its existing branch, transitioning `fixed` → `doing` while
  you work, back to `fixed` on push.
- **case 2** — a fix in flight with *no* new complaint: just report the PR and stop
  (no transition; it stays `fixed`).
- **case 3** — the PR was merged or closed-without-merge: the branch is spent, so
  branch fresh as a new fixable issue.

> An `approved` issue never reaches here — `approved` is human-only (human-approved,
> awaiting master merge), and the worker bails out on it in Setup before this file
> is ever read.

`$ISSUE` and `$TMP` come from Setup and don't survive across Bash calls —
re-derive them at the top of each snippet here (`ISSUE` from the argument,
`TMP="$(git rev-parse --show-toplevel)/.triage-issue-tmp/issue-$ISSUE"`).

If you find such a signal, inspect the PR across **all** states (not just open) so
you can tell open vs merged vs closed-without-merge — they route to different cases:

```bash
gh pr list --head "fix/issue-$ISSUE" --state all --json number,url,state,mergedAt \
  --jq 'sort_by(.number) | last'    # the most recent PR on this branch, if any
```

- **open** → cases 1/2 below (resume or report).
- **merged** (`state=MERGED` / `mergedAt` set) → the fix shipped; the merge's
  `Closes #ISSUE` should have closed the issue. If the issue is somehow still open,
  there's nothing to redo — report it and stop.
- **closed, not merged** (`state=CLOSED`, `mergedAt` null) → a human rejected the
  whole approach; the branch is spent. This is **case 3**: branch fresh as a new
  fixable issue and say so explicitly.

**For the open/resume cases, do not branch fresh and do not open a second PR** — a
new `fix/issue-<number>` collides with the existing branch and duplicates the work.
Recover the prior branch from the trace comment and continue on top of it.

## Recovering the branch from the trace

The trace lives in an HTML comment on a prior issue comment, in one of several
shapes (parse all — this skill and `fix-issue` share the branch convention, the
current shape adds a `kind:` field for `pending` outcomes, and the oldest tool used
a different format):

```
<!-- triage-issue · session: <id> · branch: fix/issue-336 · kind: (none) · <sha> -->   (current — final fix trace, orchestrator-written, has session)
<!-- triage-issue · session: <id> · branch: (none) · kind: decision · (none) -->       (current — final pending trace, orchestrator-written, has session)
<!-- triage-issue · branch: fix/issue-336 · kind: (none) · start · claimed -->         (current — start-trace, worker-written, NO session — a claim marker only)
<!-- triage-issue · session: <id> · branch: fix/issue-336 · <sha> -->                  (this skill, pre-kind)
<!-- fix-issue · session: <id> · branch: fix/issue-336 · <sha> -->                     (fix-issue)
<!-- session:<id> branch:fix/issue-336 -->                                             (legacy)
```

> **Session lives only in the *final* trace, not the start-trace.** The worker posts
> a session-free `start · claimed` trace when it claims the branch (it doesn't know
> its own resumable id); the **orchestrator** writes the resumable `session: <id>`
> into the final trace after the run exits, from the run's `--output-format json`. So
> always pull `session:` from the **newest** trace (the final one) — a start-trace
> that happens to be newest just means the run is still mid-flight and there's nothing
> to resume yet (empty `PREV_SESSION` → correct fall-through to cold continue).

The `branch:` value is what you act on. The `kind:` value (present only on the
current shape, for `pending` outcomes) tells you *why* the prior run parked it —
`decision`, `info`, or `question` — so you can judge whether the latest human
comment actually answers that. On the pre-`kind` shapes, infer it from the prior
comment's text. The `session:<id>` is consumed by the
background-resume path below (and lets a human reopen the session manually with
`claude --resume <id>`); on its own, a running skill can't pull another session's
conversation into the current context. You recover the *work* from git (the
branch + commits) and the issue thread (what the prior comment said) — for almost
all follow-ups that's enough without resuming at all.

Pull the `branch:` value out, then decide:

0. **A parked `pending` just got answered** (the issue is `pending`, has **no**
   branch/PR, and the latest comment — *newer than your trace* — supplies the
   missing decision or info the trace's `kind:` named: "A로 가주세요", "주문번호
   1024-0917 이고 결제 상태는 …", "그렇게 하기로 정했어요"). The prior session is the
   one that read the issue and wrote up exactly which decision/info it was waiting
   on — so resume **that** session and feed it the human's answer, rather than
   re-classifying cold and re-reading the whole thread. The resumed session
   transitions the label `pending` → `doing` and acts on the answer: typically the
   issue is now fixable, so it goes through the normal Fix flow (branch off
   `master-qa`, fix, review, PR, transition to `fixed`). If the answer only
   *partially* unblocks it, it may re-comment and stay `pending` (refreshing the
   `kind`). Use the **"Carrying the prior session's context"** procedure below —
   there's no existing branch here, so it creates `fix/issue-N` fresh off
   `master-qa` when a fix results. (No prior session id resumable? Fall through to a
   normal fresh classification — you still have the thread.)

   > **Known soft window (not a duplicate-PR risk).** Because case 0 starts with no
   > branch, the `fix/issue-N` claim (Fix step 1's worktree `add`) is the lock, and
   > it only engages *once the resumed session decides to fix* — not during the
   > "is this answer enough?" reasoning. So two concurrent sweeps that both see the
   > just-answered `pending` can both spend reasoning effort before one of them
   > creates the branch; the other then loses the `add` race and backs off (Fix step
   > 1). Only one PR ever opens — the waste is duplicated *thinking*, not a second
   > PR. There's no held lock for the reasoning span (you can't lock an issue you
   > haven't branched yet), and adding one isn't worth the complexity; this is the
   > accepted cost of the no-branch-until-fixable design.

1. **Owner asked for more work** (the latest comment is *newer than the trace* and
   reports the fix fell short — "아직 안 돼요", "여전히 같은 문제", "추가확인
   필요합니다", "수정 부탁", a review rejection): **resume the prior session and
   continue on its existing branch/PR**, moving the label `fixed` → `doing` while
   you work it (and back to `fixed` when you push the follow-up). This is the case
   the user cares about most — the prior run already did the analysis and the first
   fix, so you want its reasoning, not a cold restart.

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
   moves it to `approved` after reviewing. Nudging would be noise.

3. **PR was merged/closed and the issue is still open** for a genuinely new
   reason: treat it as a new fixable issue and branch fresh — the old branch is
   spent. Say so explicitly in your report.

When unsure which case you're in, surface the PR link and the latest comment and
ask the user rather than guessing — resuming on the wrong branch is hard to undo.

## Carrying the prior session's context (resume in place)

This is the shared engine for **case 0** (a `pending` issue a human just answered)
and **case 1** (a `fixed` issue with a "still broken" follow-up). In both, a prior
session already did the thinking — case 0's session wrote up exactly which
decision/info it was blocked on; case 1's investigated and made the first fix. That
reasoning lives in the session, not fully in the comments or commits. Resuming it
continues that train of thought instead of re-deriving it cold, which is the whole
point of carrying context forward.

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
  resumed session concludes a fix (the answer made it fixable), it transitions
  `pending` → `doing`, creates `fix/issue-$ISSUE` there, and opens the **first** PR;
  if the answer only partly unblocks it, it re-comments and stays `pending` (no
  branch).

**Resume continues a conversation — it does NOT re-trigger this skill.** A
resumed session picks up where it left off, with all its prior turns loaded. If
you pass `-p "/triage-issue $ISSUE"` to it, that reads as a new user message in
the old thread, not a fresh skill run — the model just answers it. So send a
plain-language instruction telling it to finish the job, not a slash command.

Run the `skip` bail-out and the in-flight branch check first; only then this.

**1. Find the prior session id from the *latest trace*, and let that trace's own
`branch:` decide the case.** The single newest `triage-issue` trace is the current
truth: if its `branch:` is `fix/issue-$ISSUE`, a fix is the live state (case 1);
if its `branch:` is `(none)`, the issue was last parked at `pending` (case 0) — even
if an *older* start-trace still mentions the fix branch (e.g. a fix that flipped to
`pending` mid-flow). Resuming the latest trace's session is therefore correct for
both: it's the fix session in case 1, and the parking session in case 0. This also
fixes the two traps — a stale fix start-trace under a newer pending trace (don't
treat as case 1), and a later unrelated pending/question trace (its session, not an
older fix session, is the one that holds the current context):

```bash
# The newest triage-issue trace IS the current state. Take its session + branch.
LATEST_TRACE=$(jq -r '[.comments[] | select(.body|test("<!-- *triage-issue")) | .body] | last // ""' "$TMP/issue.json")
PREV_SESSION=$(printf '%s' "$LATEST_TRACE" \
  | grep -oiE 'session: ?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' \
  | tail -1 | sed -E 's/session: ?//I')
# Decide the case from the latest trace's branch (not from any older trace).
if printf '%s' "$LATEST_TRACE" | grep -qE "branch: *fix/issue-$ISSUE( |\$)"; then
  RESUME_KIND=case1     # latest trace is a fix trace → fix in flight
else
  RESUME_KIND=case0     # latest trace is pending (branch: (none)) → parked, just answered
fi
```

(If the only traces are the legacy `fix-issue ·` / bare `<!-- session:… -->` shapes,
fall back to matching those too — they predate the `triage-issue` marker. They
always carried a fix branch, so they read as case 1.)

No match → no resume: continue the normal flow yourself (you have the branch +
thread). A trace whose session reads `(n/a)` (the orchestrator couldn't read a
`.session_id` from the run's JSON — e.g. the worker died before exit), or a legacy
`(subagent)` sentinel from before the headless-only redesign, is the expected
non-resumable case: the UUID regex above leaves `PREV_SESSION` empty and you
correctly fall through to a cold re-read (use the trace's `kind:` field for the prior
intent). Then confirm the transcript still exists — sessions are pruned after
`cleanupPeriodDays` (default 30):

```bash
[ -n "$PREV_SESSION" ] && ls ~/.claude/projects/*/"$PREV_SESSION".jsonl >/dev/null 2>&1 || PREV_SESSION=""
```

If it's gone, treat it as "no resume" and fall through to the normal flow. (As in
Setup, a present `.jsonl` is not proof the session is *running* — but here you're
not gating concurrency on it, only deciding whether there's a transcript worth
resuming; the branch/PR already established ownership.)

**2. Resume in a worktree with a continue-the-work instruction** (only when
`PREV_SESSION` is set):

First capture the **human's latest message** — the answer (case 0) or the
complaint (case 1) — so you can hand it to the resumed session verbatim; it's the
reason you're resuming, so don't make the resumed run guess at it. It's the latest
comment without a trace marker:

```bash
HUMAN_MSG=$(jq -r '[.comments[] | select((.body|contains("<!-- triage-issue")) or (.body|contains("<!-- fix-issue")) | not) | .body] | last // ""' "$TMP/issue.json")
```

`RESUME_KIND` was already decided in step 1 from the latest trace's branch (don't
re-hardcode it here). Create the worktree on the right base — case 1 reuses the
existing branch (same PR); case 0 starts on `origin/master-qa` (no branch yet):

```bash
ROOT=$(git rev-parse --show-toplevel)
WT="$ROOT/.triage-issue-worktrees/issue-$ISSUE"     # per-issue path → concurrent issues never collide
# RESUME_KIND comes from step 1 (case1 = latest trace is a fix trace; case0 = latest trace is pending)

if [ "$RESUME_KIND" = "case1" ]; then
  git fetch origin "fix/issue-$ISSUE" 2>/dev/null || true
  git worktree add "$WT" "fix/issue-$ISSUE" 2>/dev/null \
    || git worktree add "$WT" -b "fix/issue-$ISSUE" "origin/fix/issue-$ISSUE" 2>/dev/null
  # Do NOT silently fall back to master-qa here: case 1 means an existing fix branch
  # with prior commits. If we couldn't land on it, the branch is genuinely gone —
  # that's case 3 (branch spent), not "resume on a clean base". Assert and bail.
  if [ "$(git -C "$WT" rev-parse --abbrev-ref HEAD 2>/dev/null)" != "fix/issue-$ISSUE" ]; then
    echo "case1: could not check out fix/issue-$ISSUE (branch gone?) — fall back to fresh classification (case 3), do NOT resume onto master-qa"
    git worktree remove "$WT" --force 2>/dev/null || true
    PREV_SESSION=""    # disable resume; the prior commits aren't here
  fi
else
  git fetch origin master-qa 2>/dev/null || true
  git worktree add "$WT" origin/master-qa 2>/dev/null || true        # case0: fresh, no branch yet
  [ "$(git -C "$WT" rev-parse --abbrev-ref HEAD 2>/dev/null)" ] \
    || { echo "case0: worktree add failed — aborting resume rather than working an undefined base"; PREV_SESSION=""; }
fi
```

Then resume, telling the session what's new and what to do. The instruction
differs only in framing the human's message (answer vs. complaint):

```bash
if [ "$RESUME_KIND" = "case1" ]; then
  SITUATION="Your earlier fix didn't fully resolve issue #$ISSUE. Here is the follow-up from the thread:

$HUMAN_MSG

You are resumed in a worktree on your existing fix/issue-$ISSUE branch (your prior commits are here). First move the label fixed → doing (you're actively on it again). Address THIS follow-up, run the mandatory review subagent, commit and push to the SAME branch (updating the existing PR), then move the label back doing → fixed."
else
  SITUATION="The decision/info you were waiting on for issue #$ISSUE has arrived. Here is the human's answer from the thread:

$HUMAN_MSG

You are resumed in a fresh worktree on origin/master-qa (no branch yet — you had parked this as pending). Act on the answer: if it makes the issue fixable, move the label pending → doing, create the fix/issue-$ISSUE branch here, make the fix, run the mandatory review subagent, commit, push, open the PR, and move the label doing → fixed. If the answer only partly unblocks it, re-comment with what's still needed and stay pending (refresh the trace's kind)."
fi

( cd "$WT" && claude --resume "$PREV_SESSION" --output-format json \
    --allowedTools "Bash,Edit,Read,Write,Glob,Grep,Task" \
    -p "$SITUATION

Pick up from where you left off using what you already know — you wrote the prior analysis on this issue. When you finish, comment on the issue with what changed (fresh trace line, including kind: for a pending outcome) and set the label: 'fixed' if you opened a PR, otherwise 'pending'. Do NOT apply 'approved' (a human does that). If it's still genuinely blocked, say so and stop — don't invent an answer. Do not ask me to clarify; act on your best judgment from the context you already have." )
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
