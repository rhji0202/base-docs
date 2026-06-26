---
name: triage-issue
description: >-
  Orchestrate triaging GitHub issues: resolve which issue(s) to process, dispatch
  a triage-issue-worker run per issue (in parallel for many), and report the
  per-category results. Command-only — invoke ONLY when the user explicitly runs
  `/triage-issue` (with a number, with `all` to sweep every open issue, with
  `--triage-only` to label without fixing, or `--no-review`). Use this when the
  user wants to LABEL/CLASSIFY a backlog (sort issues into auto-fix /
  needs-decision / needs-info / question) and optionally fix the auto-fixable
  ones. Do NOT auto-trigger from phrases like "fix the bug" or "what's wrong with
  this issue"; this dispatches work that takes real actions (labels, comments,
  branches, PRs) so it must be deliberately invoked.
---

# triage-issue (orchestrator)

You are the **orchestrator**. Your entire job is three steps:

1. **Resolve** which issue number(s) to process (from the argument, or by listing
   open issues and letting the user pick) and which mode (sort-only vs. also-fix).
2. **Dispatch** one `triage-issue-worker` run per issue — in parallel for many.
3. **Report** the results back, as a per-category tally for a sweep.

That's all. You do **not** read the issue body, classify it, branch, edit code,
run tests, review, or open a PR — every one of those belongs to the worker
(`triage-issue-worker` skill). If you catch yourself about to `gh issue view` an
issue's body or open a source file, stop: that's the worker's job, dispatch it
instead. The only substantive thing you do is resolve the target and mode.

## Arguments

```
/triage-issue <number> [--triage-only] [--no-review]
/triage-issue all       [--triage-only] [--no-review]
```

- `<number>` — the issue number. `337`, `#337`, or a full URL all work. Strip the
  `#` before passing it on.
- `all` — process every open issue (one worker each). See **No number given?**.
- `--triage-only` — passed straight through to the worker, which then classifies,
  labels, and comments but **stops before fixing** (no branch, no PR). This is the
  "sort my inbox" mode.
- `--no-review` — passed straight through; the worker skips its pre-PR subagent
  review. Use only for trivial, obviously-safe fixes (typo, copy, doc); when in
  doubt, don't pass it. (The worker ignores it for auth/payment/wallet/user-data
  diffs — those always get a security review.)

**No number given?** If the user invokes the skill without a parsable issue number
(e.g. `/triage-issue 백로그 정리해줘`), don't guess. List the open issues:

```bash
gh issue list --state open --limit 30 --json number,title,labels,updatedAt \
  --template '{{range .}}#{{.number}}  {{.title}}  [{{range .labels}}{{.name}} {{end}}]{{"\n"}}{{end}}'
```

Show the list (drop ones already labeled `skip` — they're settled), then offer
the choices and let the user pick:

1. **One issue** — they name a number; dispatch a single worker.
2. **Sort everything (triage-only)** — dispatch a worker per issue *with*
   `--triage-only`. The natural reading of "백로그 정리", "이슈 분류해줘",
   "라벨 붙여줘", "sort the issues", "triage everything".
3. **Process everything (triage + fix)** — dispatch a worker per issue *without*
   `--triage-only`. The reading of "전부 처리", "다 고쳐줘", "process them all".

When it's ambiguous whether they mean sort-only vs. also-fix, or all vs.
pick-one, **ask** — the two differ by whether real PRs get opened.

## Dispatching workers

Each issue is processed by its **own** `triage-issue-worker` run, on its own
branch, in its own per-issue worktree (keyed by issue number). Because the
worktree, branch, and scratch dir are all keyed by issue number, any number of
workers run concurrently without fighting over the one checkout — that's what
makes parallel sweeps safe, and it's why the session you typed into stays free.

You have **two dispatch mechanisms**. Both run workers in parallel; pick by what
the situation needs.

### A. Subagent dispatch (default)

The simplest and most reliable: spawn the worker as a **subagent** with the Agent
tool (`subagent_type: general-purpose`), one per issue. Launch several in a single
message and they run concurrently. The subagent's final message is the worker's
result — read it and relay it. Tell each subagent to **run the
`triage-issue-worker` skill**, threading the mode flags through verbatim, e.g.:

```
Run the triage-issue-worker skill for GitHub issue #354. Process it exactly as
that skill specifies: classify it into one of the four categories, label and
comment, and — only if it's auto-fixable AND I did not pass --triage-only — fix
it on a fix/issue-354 worktree branch, run the mandatory review, and open a PR.
Flags for this run: --triage-only = (YES / NO), --no-review = (YES / NO).
Return the worker's standard two-or-three-line result summary (category, what you
did, PR link if any).
```

This is the right default for almost every run — the worker's own worktree
isolation keeps parallel subagents from colliding.

### B. Headless process dispatch (isolation / large fan-out)

When you want full OS-process isolation per issue — a large `all` sweep, or runs
that survive independently — launch each worker as a headless `claude -p` process
in the background.

> **CRITICAL — `claude -p "/triage-issue N"` does NOT work.** A `-p` prompt is
> read as a plain user message, not a skill trigger, so the spawned session just
> answers it conversationally (or, worse, acts like another orchestrator and
> reports a worker it never launched) and the flow never runs. This is the single
> most common way this dispatch breaks — and the exact bug that prompted splitting
> the worker into its own skill. You must (1) name the **worker** skill, not this
> orchestrator, and (2) force the skill to actually run via
> `--append-system-prompt`. Use this exact shape:

```bash
ISSUE=354                                  # resolved number, '#' stripped
FLAGS=""                                   # e.g. "--triage-only" and/or "--no-review"
ROOT="$(git rev-parse --show-toplevel)"
LOG="$ROOT/.triage-issue-tmp/issue-$ISSUE"
mkdir -p "$LOG"
claude -p "Run the triage-issue-worker skill for GitHub issue #$ISSUE. Process it per that skill: classify, label, comment, and (only if auto-fixable and not --triage-only) fix, review, and open a PR. Flags for this run: $FLAGS. Return the worker's standard result summary." \
  --append-system-prompt "You MUST invoke the triage-issue-worker skill via the Skill tool to do this. Do not answer conversationally or ask what to do — run the skill now." \
  --allowedTools "Bash,Edit,Read,Write,Glob,Grep,Skill,Task" \
  --output-format json \
  > "$LOG/worker-result.json" 2> "$LOG/worker-err.log"
```

> **The worker knows its own session id from `$CLAUDE_CODE_SESSION_ID`.** That env
> var is set inside every `claude` run (headless or subagent) to the run's real
> session id, so the worker reads it directly when writing the trace comment — you
> don't mint or inject anything here. This is what keeps the trace from saying
> `session: (n/a)` and what makes the later resume path actually have a session to
> `claude --resume`. (Verified: a `claude -p` reports the same value from
> `echo $CLAUDE_CODE_SESSION_ID` as its `--output-format json` `.session_id`.)

Run it with the Bash tool's `run_in_background`. When it finishes, read
`worker-result.json` (`.result`, `.is_error`, `.session_id`) and relay the
outcome + PR link. If `.is_error` is true, the JSON is unparseable, **or
`.result` reads like a conversational non-answer or an orchestrator hand-off**
(e.g. "the worker is running in the background…" — a sign the worker skill didn't
trigger), surface `worker-err.log`, say the worker failed, and either retry the
headless call or fall back to **subagent dispatch (A)** for that issue. Don't
silently run the triage/fix inline yourself.

`Skill` is in `--allowedTools` (so the spawned process can invoke
`triage-issue-worker`) alongside `Task` (so the worker can spawn its review
subagent).

### Sweeping a backlog (`all`) — parallel fan-out

Build the issue list from the open issues, excluding `skip`-labeled ones and —
unless the user said otherwise — those already settled or in flight (`auto-fix` is
still pending work, so it stays IN; `fixed` already has a PR awaiting human review;
`done` is human-approved/final; `fix-submitted` is the legacy `fixed`; `question`
is closed-out discussion):

```bash
ISSUES=$(gh issue list --state open --limit 100 \
  --json number,labels \
  -q '[.[] | select(any(.labels[].name; . == "skip" or . == "fixed" or . == "done" or . == "fix-submitted" or . == "question") | not) | .number] | join(" ")')
echo "처리할 이슈: $ISSUES"     # confirm this list with the user before fanning out
```

(`fixed` issues are excluded from the sweep, but they're still the resume target
when a human posts a "still broken" follow-up — that's handled per-issue by the
worker, not by re-sweeping.)

**Confirm the concrete list before fanning out** — show the count + numbers and
whether you're in `--triage-only` or also-fixing, and get a yes, because the fix
path opens real PRs. Then dispatch one worker per issue (subagent calls in one
message, or the headless loop below), threading the same flags into each:

```bash
ROOT="$(git rev-parse --show-toplevel)"; FLAGS="--triage-only"   # or "" to also fix
for ISSUE in $ISSUES; do
  LOG="$ROOT/.triage-issue-tmp/issue-$ISSUE"; mkdir -p "$LOG"
  claude -p "Run the triage-issue-worker skill for GitHub issue #$ISSUE. Flags: $FLAGS. Return the worker's standard result summary." \
    --append-system-prompt "You MUST invoke the triage-issue-worker skill via the Skill tool. Do not answer conversationally — run the skill now." \
    --allowedTools "Bash,Edit,Read,Write,Glob,Grep,Skill,Task" \
    --output-format json > "$LOG/worker-result.json" 2> "$LOG/worker-err.log" &
done
wait
```

Two real limits, so say so rather than launching 30 blindly: each worktree is a
full checkout (disk), and many concurrent `claude` processes share your API rate
limit. A handful at a time is fine; for a long queue, batch them. For very large
fan-outs, subagent dispatch (A) is usually lighter (no extra OS processes) — prefer
it unless you specifically need process isolation.

## Reporting

Relay each worker's result to the user with the PR link if there is one. For a
sweep, aggregate into a per-category tally — it's the most useful summary:

```
auto-fix=3  needs-decision=1  needs-info=2  question=1  fixed(PR)=2   (+ failures, if any)
```

If a worker errored, say so and surface its `worker-err.log` (headless) or the
subagent's error (subagent) — don't pretend it succeeded, and don't silently
re-run the work inline. The worker already records its own issue comment and
label; you just report.
