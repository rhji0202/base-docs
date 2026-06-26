---
name: triage-issue-worker
description: >-
  The worker half of triage-issue: process ONE GitHub issue — classify it into
  auto-fix / needs-decision / needs-info / question, label it, comment, and (only
  if auto-fixable and not --triage-only) fix it on a per-issue worktree branch,
  run the mandatory review, open a PR, and transition the label. Invoked by the
  `triage-issue` orchestrator (as a subagent or a headless `claude -p` process),
  or directly when you already know the single issue number and want the full
  triage flow without the dispatch layer. Takes real actions (labels, comments,
  branches, PRs) so invoke deliberately.
---

# triage-issue-worker

Process exactly **one** issue end-to-end. You are already an isolated worker (the
`triage-issue` orchestrator spawned you, or you were invoked directly for a single
issue). Classify the issue, label it, leave a human-sounding comment, and — for an
auto-fixable issue when `--triage-only` was not passed — take it all the way to an
opened PR. The four labels form a small state machine, so re-running this on an
issue is safe and converges.

> You process one issue. If you find yourself trying to handle several, stop —
> that's the orchestrator's fan-out, not yours.

## Flags

- `--triage-only` — classify, label, and comment, then **stop** (no branch, no
  PR), even for an auto-fixable issue. The orchestrator threads this through for a
  "sort the inbox" sweep.
- `--no-review` — skip the pre-PR subagent review on a fix. Only for trivial,
  obviously-safe fixes; **ignored when the diff touches auth, payment, wallet, or
  user data** — those always get the security review regardless.

## Setup (run once at the start)

```bash
ISSUE=337                                  # the issue number, strip any '#'
TMP="$(git rev-parse --show-toplevel)/.triage-issue-tmp/issue-$ISSUE"   # ABSOLUTE + per-issue
mkdir -p "$TMP"
gh issue view "$ISSUE" --json number,title,body,labels,comments,state,author,url > "$TMP/issue.json"
TITLE=$(jq -r .title "$TMP/issue.json")    # reused in PR title, commit, and the notification
```

`$TMP` is **absolute** (rooted at the repo top) so it keeps pointing at the same
scratch dir even after the Fix flow does `cd "$WT"` into a worktree. Per-issue, so
concurrent workers never share scratch. Fetch once and read everything (title,
body, labels, comments) from that file — don't call `gh issue view` repeatedly.

> **Per-issue isolation — clean up only your own path, never the parent.** Both
> `$TMP` and the fix worktree (`…/.triage-issue-worktrees/issue-$ISSUE`) are keyed
> by issue number, because workers run concurrently on the same repo. Both trees
> are git-ignored, so `git add -A` never commits them. The rules:
> - Remove a worktree with `git worktree remove "$WT"` (best-effort). For an
>   orphaned leftover dir git no longer tracks, `rm -rf "$WT"` on that **single**
>   path is the fallback (see Fix-flow step 1).
> - **Never `git clean` the worktree area** — it treats all of
>   `.triage-issue-worktrees/` as one unit and would wipe a sibling worker.
>   Single-path `rm -rf "$WT"` is the only safe scoped delete.
> - Never delete the parent `.triage-issue-worktrees/` or `.triage-issue-tmp/`
>   roots.

> **Each Bash tool call is a fresh shell — `ISSUE`, `TMP`, `TITLE` do NOT survive
> between snippets.** Re-establish whichever you need at the top of every later
> snippet (`ISSUE` from the argument;
> `TMP="$(git rev-parse --show-toplevel)/.triage-issue-tmp/issue-$ISSUE"`; `TITLE`
> with `jq -r .title "$TMP/issue.json"`). The snippets below omit that boilerplate
> for readability — add it, or combine steps into one Bash invocation. This skill
> assumes `jq`, `gh`, `curl`, and `git` are on PATH; if `jq` is missing, stop and
> tell the user.

Read the body AND existing comments — prior discussion often holds the repro or
the decision, and **comments override the body**: a body that looks clear may have
been overruled by a later "let's hold this until Monday" / "결정 후 진행" comment.
Note the title verbatim; you'll reuse it.

**Always inspect attached images — don't skip this.** On this tracker many issues
are a single screenshot with little text, so the bug (or the error column, or the
screen in question) is often *in the picture*. An issue that looks like
`needs-info` from the text alone often becomes `auto-fix` once the screenshot makes
the problem concrete. GitHub attachment URLs need auth — use the `gh auth token`
header trick:

```bash
TOKEN=$(gh auth token) || { echo "gh not authenticated — cannot fetch images"; exit 1; }
i=0
jq -r '[.body, (.comments[].body // empty)] | join("\n")' "$TMP/issue.json" \
  | grep -oE 'https://(github\.com/user-attachments/assets|user-images\.githubusercontent\.com)/[^ )"'"'"']+' \
  | while read -r url; do
      i=$((i+1)); out="$TMP/img-$i"
      if curl -fsSL -H "Authorization: token $TOKEN" "$url" -o "$out"; then
        echo "downloaded: $out"
      else
        echo "FAILED to download: $url"
      fi
    done
```

The regex covers the legacy `user-images.githubusercontent.com` host and stops at
`)`, `"`, `'`, or space so it captures the full URL out of `![](...)` or
`<img src="...">`. Files save as `img-N` (no extension — fine, Read detects the
type). Then Read each one. If a download fails or an image is unreadable, say so
and ask rather than guessing — `curl -fsSL` returns non-zero on HTTP errors instead
of silently saving an error page.

**Bail out early if it's `skip` or `done` — check this FIRST.** Both are
human-owned "leave it alone" states:
- `skip` — someone decided it's out of scope / duplicate / won't-fix.
- `done` — a human reviewed the PR and marked the issue settled. **`done` is
  human-only and final**: the bot never applies it and never re-touches a `done`
  issue, even if there's a newer "still broken" comment. If a fix really fell
  short, the person removes `done` and re-applies `fixed` or `auto-fix` by hand —
  *that* is the signal to work it again. Re-processing a `done` issue on our own
  would reopen something a human deliberately closed out.

If either label is present, stop and return — don't re-classify, comment, or
branch — just report which one it is. (These win even over a `fixed` label or an
in-flight branch.)

**Did a prior run already touch this issue? Resume its session.** Before
classifying from scratch, check whether *you've been here before* — any prior
`triage-issue ·` / `fix-issue ·` (or legacy `issue-fixer-completed`) trace comment,
a `fixed` label (or legacy `fix-submitted`), or an open `fix/issue-<number>` PR. If
so, a prior session already analyzed this issue, and **continuing from its
reasoning beats re-deriving it cold.** Don't branch fresh or open a second PR.
Instead read **`references/resume-background.md`** now and follow it — it parses
the trace, picks the owner-state case, and `claude --resume`s the prior session.
The two shapes this covers:

- **Fix in flight** (`fixed` label / open PR) + a newer "still broken" comment →
  resume on the existing branch/PR (resume-background.md **case 1**).
- **Non-fix outcome resolved** — the issue was parked at `needs-decision` or
  `needs-info`, and a **human comment newer than your trace** now supplies the
  missing decision or info ("A로 가주세요", "주문번호는 …", "이렇게 하기로 했어요").
  Resume the session that wrote up the options/questions so it acts on the answer
  with full context, rather than re-reading the thread cold (resume-background.md
  **case 0**). This is the path that carries your earlier analysis forward.

If none of those signals is present, classify fresh below.

> **The "fixed인데 아직 문제 있다"는 케이스 — 이어받기가 기본이다.** A `fixed`
> issue (bot opened a PR, not yet human-reviewed) with a **newer comment than the
> trace** reporting the fix didn't work ("아직 안 돼요", "여전히 같은 문제",
> "추가확인 필요", a review rejection) is the single most important resume case.
> Don't re-classify it as a fresh `auto-fix` and branch from scratch — that throws
> away the prior fix and risks a duplicate PR. Instead: pull the `session:<id>` and
> `branch:` out of the latest trace comment and **resume that exact session**
> (`claude --resume <id>`) so you continue with the prior run's full reasoning, on
> its existing branch/PR. Keep the label at `fixed` (don't promote to `done` — a
> human still does that). This is `resume-background.md`'s **case 1**, the default
> for the follow-up-complaint pattern, not an optional optimization. Only fall back
> to a fresh branch if the prior session id is gone (pruned) or the old PR was
> merged/closed for a genuinely new reason (case 3). (A `done` issue never reaches
> here — it bailed out above.)

## The decision: four categories

After reading the issue (body + comments + images), classify it into exactly one
category. Decide and act — don't ask the user to confirm the label. These four are
the **only** labels this skill manages; never touch labels a human applied (`bug`,
`enhancement`, area tags…).

| Category | When | Label | Then do |
|---|---|---|---|
| **auto-fix** | Clear, in-scope bug or small change with a definite repro/expected behavior and **no open decision** — you could implement and verify it now | `auto-fix` (→ `fixed` after PR; never `done`) | Run the **Fix flow**, unless `--triage-only` |
| **needs-decision** | You know *what* to change, but a product/spec call must come first (behavior could go several ways, policy undecided, body conflicts with code) | `needs-decision` | Comment the options + tradeoff, ask the owner to decide, stop |
| **needs-info** | Can't classify/fix even after looking at the images — repro steps, expected behavior, or the target screen aren't pinned down | `needs-info` | Comment asking for the specific missing pieces, stop |
| **question** | Not a code change — a usage question, discussion, or external dependency ("waiting on the vendor") | `question` | Comment the answer/pointer, stop |

**Confidence gate for auto-fix.** Only choose `auto-fix` when you're genuinely
confident you could implement *and verify* it without a human weighing in. If
you're hedging — "probably fixable, but the expected behavior is a bit fuzzy" —
that hedge is the signal: drop to `needs-info` (text/repro unclear) or
`needs-decision` (behavior is a judgment call). A false `auto-fix` wastes a fix
attempt and may open a wrong-headed PR; a conservative `needs-info` just asks one
question. When torn between the two non-fix categories, ask: *is the missing piece
information (→ needs-info) or a decision (→ needs-decision)?*

**A "one-line text change" is not automatically auto-fix — check for ripple
first.** A user-facing string that looks like a trivial copy edit can actually be
an **i18n key** or a shared constant: changing it then ripples across every locale
file and caller, which is a multi-file refactor, not a one-liner. Before committing
to `auto-fix` on a text change, grep the string — if it's a translation key (lives
in `locales/*.json`, `i18n/lang/*.ts`, etc.) or appears in many files, either scope
the fix correctly (change the *value*, not the key) or treat the broader rename as
`needs-decision`. A hardcoded literal in one component is the clean auto-fix case.

**Re-triage is idempotent and may flip a label.** An issue labeled
`needs-decision` whose latest comment supplies the decision should flip to
`auto-fix` next run; one labeled `needs-info` that got its repro should too. When
you apply a new category, remove the *other* triage label you're replacing — but
only ever the four this skill owns:

```bash
gh issue edit "$ISSUE" --add-label "<new>" \
  $(for L in auto-fix needs-decision needs-info question; do
      [ "$L" != "<new>" ] && printf -- '--remove-label %s ' "$L"; done)
```

`--remove-label` on an absent label is a harmless no-op, so this is safe every run.
For **needs-decision / needs-info**, also leave (or update) the guidance comment —
see [Commenting](#commenting). For **question**, comment the answer. Then, unless
this is `auto-fix` *and* not `--triage-only`, you're done — stop here.

## Fix flow (auto-fix issues, when not `--triage-only`)

> Skip this entire section if `--triage-only` was passed, or if the category was
> anything other than `auto-fix`. The label + comment above is then the whole job.

1. **Work in a per-issue worktree, not the main checkout.** Even as an isolated
   worker, the repo has one shared working tree — so branch/commit in your own
   worktree to avoid disturbing the main checkout (and any sibling worker). Branch
   off the QA base (this repo flows feature → master-qa → master):
   ```bash
   ROOT=$(git rev-parse --show-toplevel)
   WT="$ROOT/.triage-issue-worktrees/issue-$ISSUE"   # per-issue → concurrent runs never collide
   git fetch origin

   # Recover from a prior run's leftovers before adding. A cancelled cleanup can
   # leave the dir on disk but unregistered in git; a plain `worktree add` then
   # dies "already exists". Prune stale metadata, then clear ONLY this dir with
   # `rm -rf "$WT"` — NOT `git clean` (which treats the whole ignored
   # .triage-issue-worktrees/ as one unit and would wipe a sibling worker).
   git worktree prune
   if [ -e "$WT" ] && ! git worktree list --porcelain | grep -qF "$WT"; then
     rm -rf "$WT" 2>/dev/null || true
   fi

   if git show-ref --verify --quiet "refs/heads/fix/issue-$ISSUE"; then
     git worktree add "$WT" "fix/issue-$ISSUE"          # resume/retry
   else
     git worktree add "$WT" -b "fix/issue-$ISSUE" origin/master-qa
   fi

   cd "$WT" || { echo "worktree cd failed — aborting, NOT working in the main checkout"; exit 1; }
   ```
   **The `cd` guard is load-bearing:** if the worktree couldn't be created, do NOT
   fall through and fix in the main checkout — that's how the main branch gets
   clobbered. Bail instead. Do all edits, tests, commit, and push from inside `$WT`.
2. **Find the root cause, not the symptom.** The issue names a symptom; grep the
   callers of the function you're about to touch and fix where all paths route
   through. Match surrounding style. Keep the diff minimal and in scope — if you
   discover the fix actually needs a product decision, stop, flip the issue to
   `needs-decision` (comment the options), and skip the rest of this flow rather
   than guessing.
3. **Verify.** Run the relevant tests (`uv run pytest ...` for backend — Python is
   uv-only here). If you wrote new logic, leave one runnable check behind.

   > **Frontend caveat in a worktree.** A fresh worktree has no `node_modules`
   > (copying/symlinking one is often broken), so `admin`/`web` builds, ESLint,
   > Prettier, and Node-based pre-commit hooks may fail on environment, not on your
   > change. Two ways out: run the frontend build/lint from the **main checkout**
   > (which has a working `node_modules`) against your branch, or `git -C "$ROOT"`
   > the toolchain there — then commit with `--no-verify` since the hook can't run
   > in the worktree. Say in your summary that you verified via the main toolchain
   > and why, so it's not mistaken for skipping checks.
4. **Review (mandatory unless `--no-review`).** Before committing the PR, spawn a
   subagent to review the diff — a fresh agent catches what the author misses,
   which is why this isn't skippable on a hunch in a money/auth codebase. Spawn a
   `general-purpose` subagent (the named `security-reviewer`/`code-reviewer`
   personas aren't resolvable agent types here — give the rubric inline). Pass it
   the full `git diff origin/master-qa...HEAD` and this prompt:

   ```
   Review this diff as a {security reviewer | code reviewer}. Report findings by
   severity using the project's scale: CRITICAL (security/data-loss — BLOCK),
   HIGH (bug or significant quality issue), MEDIUM, LOW. Check specifically:
   hardcoded secrets, missing input validation, SQL injection, auth/authz
   bypasses, silent error swallowing, and whether the fix addresses the root
   cause vs the symptom. Be concrete: file:line + why. End with a one-line
   verdict: APPROVE / WARN / BLOCK.
   ```

   Choose the lens by what the diff touches: anything under auth, payment, wallet,
   or user data → "security reviewer"; otherwise "code reviewer". Address every
   CRITICAL and HIGH before continuing. If the verdict is BLOCK, fix and re-review —
   do not open the PR over a CRITICAL.
5. **Commit & push** (scratch is git-ignored, so `git add -A` won't stage the
   downloaded images):
   ```bash
   git add -A
   git commit -m "fix: resolve #$ISSUE - $TITLE"
   git push -u origin "fix/issue-$ISSUE"
   ```
6. **Open the PR** against `master-qa`:
   ```bash
   gh pr create --base master-qa --head "fix/issue-$ISSUE" \
     --title "fix: resolve #$ISSUE - $TITLE" \
     --body "<root-cause summary + test plan + Closes #$ISSUE>"
   ```
   Include a closing `Closes #$ISSUE` so the merge auto-closes the issue.
7. **Comment + transition the label.** Leave the human-facing comment (see
   [Commenting](#commenting)), then move the issue out of the work queue: remove
   `auto-fix`, add `fixed`. This transition is what stops the next sweep from
   re-processing an issue that already has a PR — so if the `gh` call fails, retry
   it.
   ```bash
   # Ensure the `fixed` label exists (the repo may not have it yet — unlike
   # `done`/`auto-fix` which already exist). Without this the --add-label below
   # silently fails and the issue is stuck on `auto-fix`, so a later sweep redoes it.
   gh label list --json name -q '.[].name' | grep -qx "fixed" \
     || gh label create "fixed" --color 1d76db --description "봇이 수정 PR 생성, 사람 리뷰 대기"
   gh issue edit "$ISSUE" --remove-label auto-fix --add-label "fixed"
   ```
   **Stop at `fixed` — never apply `done`.** `fixed` means "bot opened the PR,
   awaiting human review." `done` is a **human-only** label: a person applies it
   after reviewing/merging the PR, and it takes the issue permanently out of this
   skill's reach (see the `done` bail-out in Setup). If the bot promoted to `done`
   itself, it would mark its own unreviewed work as final.
8. **Clean up the worktree (best-effort, optional).** Commits are pushed, so `$WT`
   is disposable — remove it with git's own command, never `rm -rf`:
   ```bash
   cd "$ROOT" && git worktree remove "$WT" --force 2>/dev/null || true
   ```
   On Windows/Git-Bash this often fails with `Permission denied` (a process still
   holds the dir), leaving the folder on disk while git's metadata is pruned — an
   unregistered leftover. That's expected and harmless: `.triage-issue-worktrees/`
   is git-ignored, and step 1's recovery block clears exactly this leftover next
   time the issue is processed. Don't fight it with `rm -rf` here.

## Commenting

The comment is the human-facing record. Write it the way a teammate would in the
issue thread — natural, first-person, conversational. Not a status dump, not
bullet-point robot-speak. Say what you found, what you did, and what happens next.

**For a fix:**

> 확인해보니 결제 합계가 안 맞은 건 행 단위로 `item_amount` 스냅샷을 안 쓰고
> 매번 단가×수량으로 다시 계산하고 있어서였어요. 그 부분을 스냅샷 기준으로
> 바꿨고, 단가가 중간에 바뀐 케이스도 테스트로 막아뒀습니다. PR 올려뒀으니
> 리뷰 한 번 봐주세요 🙏

**For needs-decision** — state the concrete options and the tradeoff, and name
what you need decided. Don't ask "어떻게 할까요?" in the abstract:

> 이거 고치는 방향이 두 갈래라 먼저 정해주셔야 할 것 같아요. (A) 품절 시 주문을
> 자동 취소하고 환불, (B) 재고 들어올 때까지 보류. A는 고객 대기시간이 짧지만
> 부분환불 정산이 복잡하고, B는 정산은 깔끔한데 언제 들어올지 모르는 재고를
> 기다리게 돼요. 어느 쪽으로 갈지 알려주시면 바로 작업할게요.

**For needs-info** — ask for exactly what's missing, not "more detail" generically:

> 재현을 못 해봐서 그런데, 어떤 주문번호에서 발생했는지랑 그때 결제 상태가
> 뭐였는지 알 수 있을까요? 그거 있으면 바로 들여다볼게요.

**For question** — answer it or point to the relevant place, and say it's not a
code change so nobody waits on a PR.

### The trace line (session + branch)

End **every** comment with one HTML comment. It's invisible in GitHub's rendered
view but survives in the raw markdown so the work is traceable and a later run can
resume it:

```
<!-- triage-issue · session: <SESSION_ID> · branch: <branch or (none)> · <anchor> -->
```

- `<SESSION_ID>` — **your own session id, read from the `$CLAUDE_CODE_SESSION_ID`
  environment variable** (`echo "$CLAUDE_CODE_SESSION_ID"`). It is set inside every
  `claude` run to that run's real session id, so use it verbatim — getting it right
  is what makes the resume path work: when a `fixed` issue later gets a "still
  broken" comment, the next run reads this id and `claude --resume`s **this exact
  session** to continue with your reasoning (see `references/resume-background.md`).
  Only if `$CLAUDE_CODE_SESSION_ID` is genuinely empty, write `session: (n/a)` —
  but don't default to that, and never leave the literal `<SESSION_ID>` placeholder
  in a posted comment. Resolve it like the SHA: read the value first, then paste it
  into the quoted heredoc below.
- `<branch>` — `fix/issue-<number>` for fixes, `(none)` for non-fix outcomes.
- `<anchor>` — for a fix, the short commit SHA (`git rev-parse --short HEAD`). Omit
  for non-fix outcomes.

Post with a **quoted** heredoc (`<<'EOF'`) so the body — which may contain `$`,
backticks, or `<...>` — survives byte-for-byte. Because the heredoc is quoted, **no
`$variable` inside it expands**: compose the final text first (resolve the SHA, fill
in the real branch/session) and paste literal values in. Do NOT write
`$SHA`/`$BRANCH` inside the heredoc — they'd ship unexpanded.

```bash
gh issue comment "$ISSUE" --body "$(cat <<'EOF'
<comment text>

<!-- triage-issue · session: <real id or (n/a)> · branch: fix/issue-339 · a1b2c3d -->
EOF
)"
```

Re-triage shouldn't pile up duplicate guidance comments. Before commenting on a
`needs-decision`/`needs-info` issue, check whether your own prior trace comment
already says the same thing; if the situation is unchanged, skip the comment.

## Notify the team

After acting, send a team notification (currently WeCom / 기업위챗) for outcomes
that need attention — a PR opened/updated (the `fixed` transition), or a
`needs-info`/`needs-decision` label. Skip the ping for `skip`, `question`, or a
`fixed` issue you didn't change this run (already had its PR, nothing new —
re-pinging is just noise), unless the user asks for it. The channel config, encoding defenses, and exact send
command are in **`references/notify.md`** — read it when ready to send. If no
channel is configured, skip the notification (don't fail the run) and say so.

## Output

Your final message is what the orchestrator (or user) reads back, so make it a
clean two-or-three-line summary: the category you chose, what you did (label,
comment, PR link if any), whether the notification was sent, and anything the user
must now do (review the PR, make the product decision…). Don't narrate every gh
command — just the result.
