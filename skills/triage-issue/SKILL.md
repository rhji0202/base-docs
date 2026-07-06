---
name: triage-issue
description: >-
  Orchestrate triaging GitHub issues: resolve which issue(s) to process, dispatch
  a triage-issue-worker run per issue (in parallel for many), and report the
  per-state results. Command-only — invoke ONLY when the user explicitly runs
  `/triage-issue` (with a number, with `all` to sweep every open issue, or with
  `--triage-only` to label without fixing). Use this when the
  user wants to LABEL/CLASSIFY a backlog (sort issues into doing = fixable /
  pending = blocked on a human) and optionally fix the fixable ones. Do NOT
  auto-trigger from phrases like "fix the bug" or "what's wrong with this issue";
  this dispatches work that takes real actions (labels, comments, branches, PRs)
  so it must be deliberately invoked.
---

# triage-issue (orchestrator)

You are the **orchestrator**. Your entire job is three steps:

1. **Resolve** which issue number(s) to process (from the argument, or by listing
   open issues and letting the user pick) and which mode (sort-only vs. also-fix).
2. **Dispatch** one `triage-issue-worker` run per issue — in parallel for many.
3. **Report** the results back, as a per-state tally for a sweep.

> **The label state machine (so you read the sweep filter correctly).** The worker
> drives three labels — `doing` (it's actively working it / fixable), `pending`
> (blocked on a human: decision, info, or a question), `fixed` (PR open, awaiting
> review) — and two are human-only: `approved` (human-approved, awaiting master merge) and `skip` (out of
> scope). You never apply labels; you just resolve targets and read them to decide
> the sweep set.

That's all. You do **not** read the issue body, decide its state, branch, edit
code, run tests, review, or open a PR — every one of those belongs to the worker
(`triage-issue-worker` skill). If you catch yourself about to `gh issue view` an
issue's body or open a source file, stop: that's the worker's job, dispatch it
instead. The only substantive thing you do is resolve the target and mode.

## Arguments

```
/triage-issue <number> [--triage-only]
/triage-issue all       [--triage-only]
```

- `<number>` — the issue number. `337`, `#337`, or a full URL all work. Strip the
  `#` before passing it on.
- `all` — process every open issue (one worker each). See **No number given?**.
- `--triage-only` — passed straight through to the worker, which then classifies,
  labels, and comments but **stops before fixing** (no branch, no PR). This is the
  "sort my inbox" mode.

(There is no `--no-review` — the worker's pre-PR code review always runs. It's a
cheap second look and this is a money codebase.)

**No number given?** If the user invokes the skill without a parsable issue number
(e.g. `/triage-issue 백로그 정리해줘`), don't guess. List the open issues:

```bash
gh issue list --state open --limit 30 --json number,title,labels,updatedAt \
  --template '{{range .}}#{{.number}}  {{.title}}  [{{range .labels}}{{.name}} {{end}}]{{"\n"}}{{end}}'
```

Show the list (drop ones already labeled `skip` or `approved` — both human-owned:
`skip` is out of scope, `approved` is signed off and queued to merge), then offer
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

**There is exactly ONE dispatch mechanism: headless `claude -p`.** Every worker —
whether it only triages or also fixes, whether you run one or sweep `all` — is
launched as its own headless `claude -p` OS process. Do **not** dispatch workers as
subagents (the Agent tool / `subagent_type: general-purpose`). This is a hard rule,
not a preference.

> **HARD RULE — issue processing is headless-only. Never dispatch a worker as a
> subagent.** A subagent worker runs in the **parent's process and environment**, so
> its `$CLAUDE_CODE_SESSION_ID` is the *orchestrator's* id, not a fresh per-worker id
> (verified: a subagent sees `CLAUDE_CODE_CHILD_SESSION=1` and inherits the parent's
> `$CLAUDE_CODE_SESSION_ID`), and there's often no top-level `.jsonl` to resume at
> all. So a subagent-dispatched issue can't be individually resumed: a later "still
> broken" follow-up has no per-issue session for `claude --resume` to land on. This
> bit us in the wild — fixes dispatched as subagents left `session: (subagent)`
> traces and a half-done `doing` + "재디스패치하겠다" comment instead of a PR.
>
> A headless `claude -p` worker is its own OS process with its own **real** session
> id, which the orchestrator reads from the run's `--output-format json` `.session_id`
> (the `issue-fixer/scripts` pattern) and stamps into the final trace — so the trace
> is uniquely resumable. That property is required for *every* run, not just fixes —
> even a `--triage-only` classify benefits from a real trace — so there's no carve-out:
> **always headless.**
>
> Note the worker no longer self-checks whether it's a subagent (the old
> `CLAUDE_CODE_CHILD_SESSION` guard is gone): session identity now comes from the
> result JSON the orchestrator reads, not from an env var the worker inspects. So the
> guarantee rests entirely here — **the orchestrator must always dispatch via
> `claude -p`, never as a subagent.**

### Headless process dispatch (the only mechanism)

Each worker is its own OS process with its own **real session id**, so its trace
comment is uniquely resumable — which is what makes the "fixed인데 아직 문제 있다"
follow-up resume actually land on the worker's reasoning. It also gives full
OS-process isolation per issue (a large `all` sweep, or runs that survive
independently). Launch each worker as a headless `claude -p` process in the
background.

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
FLAGS=""                                   # e.g. "--triage-only"
ROOT="$(git rev-parse --show-toplevel)"
LOG="$ROOT/.triage-issue-tmp/issue-$ISSUE"
mkdir -p "$LOG"
claude -p "Run the triage-issue-worker skill for GitHub issue #$ISSUE. Process it per that skill: decide fixable (doing) vs blocked (pending), label, do the fix work and open a PR if fixable and not --triage-only, and post ONLY the start-trace claim — do NOT post the final issue comment yourself; return it in your summary for me (the orchestrator) to post. Flags for this run: $FLAGS. Return the worker's standard summary (the OUTCOME/KIND/BRANCH/SHA/PR header line + the human-facing prose body)." \
  --append-system-prompt "You MUST invoke the triage-issue-worker skill via the Skill tool to do this. Do not answer conversationally or ask what to do — run the skill now." \
  --allowedTools "Bash,Edit,Read,Write,Glob,Grep,Skill,Task" \
  --output-format json \
  > "$LOG/worker-result.json" 2> "$LOG/worker-err.log"
```

> **The orchestrator owns the session id, from the result JSON** (`.session_id` in
> `--output-format json`, the `issue-fixer/scripts/lib/common.sh` pattern — verified
> equal to the run's own `$CLAUDE_CODE_SESSION_ID`). The *why* is the HARD RULE above;
> here is just the source.

**After the run finishes, extract the session and post the final trace yourself.**
The worker did the work, applied labels, and posted only its start-trace *claim*; the
human-facing comment + resumable trace is the orchestrator's to post:

```bash
SESSION_ID=$(jq -r '.session_id // empty' "$LOG/worker-result.json"); SESSION_ID="${SESSION_ID:-(n/a)}"
RESULT=$(jq -r '.result // empty' "$LOG/worker-result.json")
HEADER=$(printf '%s\n' "$RESULT" | head -1)         # line 1 = machine fields
PROSE=$(printf '%s\n' "$RESULT" | tail -n +2)       # line 2+ = the comment body
# HEADER carries: OUTCOME KIND BRANCH SHA PR NOTIFIED SUPPRESS_COMMENT (key=value, space-sep).
# Pull each (e.g. BRANCH from `grep -oE 'BRANCH=[^ ]+'`), then post ONE final comment
# = PROSE + trace, UNLESS SUPPRESS_COMMENT=yes (then refresh the trace alone):
#   <!-- triage-issue · session: $SESSION_ID · branch: $BRANCH · kind: $KIND · $SHA -->
# (for a pending outcome BRANCH/SHA are (none); for a fix, KIND is (none)).
```

Compose the final comment with a **quoted** heredoc (prose may contain `$`/backticks)
and paste the resolved session/branch/kind/sha literals in — the trace-line spec in
the worker skill's [The trace line](triage-issue-worker) defines the field rules. This
is the single resumable trace a later "still broken" / "decision arrived" follow-up
resumes from. **Honor `SUPPRESS_COMMENT=yes`** (a duplicate `pending` re-triage):
skip the comment body, just refresh the trace. The worker sets that flag because it
read the thread — you don't re-read it (that stays the worker's job, per the boundary
above).

Run the worker with the Bash tool's `run_in_background`. When it finishes, read
`worker-result.json` (`.result`, `.is_error`, `.session_id`), post the final comment
above, and relay the outcome + PR link. If `.is_error` is true, the JSON is
unparseable, **or `.result` reads like a conversational non-answer or an orchestrator
hand-off** (e.g. "the worker is running in the background…" — a sign the worker skill
didn't trigger), surface `worker-err.log`, say the worker failed, and **retry the
headless call** for that issue. Never fall back to subagent dispatch — that's the
hard rule. Don't silently run the triage/fix inline yourself either.

`Skill` is in `--allowedTools` (so the spawned process can invoke
`triage-issue-worker`) alongside `Task` (so the worker can spawn its review
subagent).

### Sweeping a backlog (`all`) — parallel fan-out

Build the issue list from the open issues. Exclude only the two human-owned states
the bot must never touch — `skip` (out of scope) and `approved` (human-approved,
awaiting master merge). Everything else stays IN, because the worker is idempotent
and converges (and, critically, **the worker — not this filter — decides per-issue
whether there's actually work to do**, so an in-flight or already-handled issue is a
cheap no-op rather than a duplicate):

- **unlabeled** — never triaged; classify fresh.
- **`pending`** — blocked on a human; the worker re-checks whether a newer comment
  now supplies the decision/info and, if so, transitions it to `doing` and works it.
  (If still blocked, it's a cheap no-op.)
- **`doing`** — *usually* means a worker is actively on it. The worker decides
  per-issue: it backs off if a live worker is genuinely mid-run, or reclaims a
  zombie (the owning run died). Don't filter `doing` out here, or a crashed run's
  issue would never get picked up again.
- **`fixed`** — has a PR awaiting human review. **Stays IN** so a "still broken"
  follow-up gets picked up automatically: the worker resumes it (case 1) only when
  the latest human comment is *newer than its trace*; otherwise it reports the PR
  and stops (a no-op). Filtering `fixed` out here is what would strand a follow-up
  until someone manually re-ran `/triage-issue <n>` — so keep it in and let the
  worker's newer-than-trace check be the gate.

```bash
ISSUES=$(gh issue list --state open --limit 100 \
  --json number,labels \
  -q '[.[] | select(any(.labels[].name; . == "skip" or . == "approved") | not) | .number] | join(" ")')
echo "처리할 이슈: $ISSUES"     # confirm this list with the user before fanning out
```

> **A `fixed` issue with no new comment is a no-op, not wasted work** — the worker's
> first move on it is the newer-than-trace check (cheap: one `gh issue view` already
> done in Setup). It opens no branch and pushes nothing unless there's a real
> follow-up. So including `fixed` costs a quick re-read per quiet PR, and in exchange
> never strands a "still broken" report. That trade is the whole point of C1's fix.

**Confirm the concrete list before fanning out** — show the count + numbers and
whether you're in `--triage-only` or also-fixing, and get a yes, because the fix
path opens real PRs. Then dispatch one worker per issue with the headless loop
below, threading the same flags into each. (Headless is the only mechanism — the
same loop serves both `--triage-only` and also-fixing sweeps.)

```bash
ROOT="$(git rev-parse --show-toplevel)"; FLAGS="--triage-only"   # or "" to also fix
for ISSUE in $ISSUES; do
  LOG="$ROOT/.triage-issue-tmp/issue-$ISSUE"; mkdir -p "$LOG"
  claude -p "Run the triage-issue-worker skill for GitHub issue #$ISSUE. Flags: $FLAGS. Post only the start-trace claim; return the final comment in your summary for me to post. Return the worker's standard summary (header line + prose)." \
    --append-system-prompt "You MUST invoke the triage-issue-worker skill via the Skill tool. Do not answer conversationally — run the skill now." \
    --allowedTools "Bash,Edit,Read,Write,Glob,Grep,Skill,Task" \
    --output-format json > "$LOG/worker-result.json" 2> "$LOG/worker-err.log" &
done
wait
# After the wave, post the final trace comment for each issue from its result JSON
# (identical extract-session + head-1/tail-+2 + honor-SUPPRESS_COMMENT step as the
# single-dispatch block above).
for ISSUE in $ISSUES; do
  LOG="$ROOT/.triage-issue-tmp/issue-$ISSUE"
  SESSION_ID=$(jq -r '.session_id // empty' "$LOG/worker-result.json"); SESSION_ID="${SESSION_ID:-(n/a)}"
  RESULT=$(jq -r '.result // empty' "$LOG/worker-result.json")
  # HEADER=head -1; PROSE=tail -n +2; post PROSE+trace unless SUPPRESS_COMMENT=yes.
done
```

Two real limits, so say so rather than launching 30 blindly: each worktree is a
full checkout (disk), and many concurrent `claude` processes share your API rate
limit. A handful at a time is fine; for a long queue, **batch the headless workers**
(e.g. run them in waves of 4–6 with a `wait` between waves) rather than launching
the whole list at once. Do **not** reach for subagent dispatch to dodge the process
limit — there is no subagent path; batch the headless loop instead. A subagent's
result JSON wouldn't carry a per-worker `.session_id` for the orchestrator to stamp,
so its issues would end up non-resumable — the exact failure the hard rule forbids.

## Reporting

Relay each worker's result to the user with the PR link if there is one. For a
sweep, aggregate into a per-state tally — it's the most useful summary. Break
`pending` out by its `kind` since that's what tells the team what's needed:

```
fixed(PR)=2  doing=1  pending:decision=1  pending:info=2  pending:question=1   (+ failures, if any)
```

If a worker errored, say so and surface its `worker-err.log` — don't pretend it
succeeded, and don't silently re-run the work inline. The worker applied the label
and posted its start-trace claim; **you** posted the final comment + session trace
(above) from its result JSON. So report the outcome, and note any issue where the
final comment couldn't be posted (e.g. `.session_id` missing → trace stamped `(n/a)`).
