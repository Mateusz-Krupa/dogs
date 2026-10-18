---
name: opencode-implement
description: Delegate implementation tasks that can be written as a complete, checkable spec to the locally installed opencode CLI (default model: the user's local swissquant-local/vision-flash; any opencode model can be chosen per run) instead of Claude subagents, to save Claude tokens; design-heavy, vague, repo-wide or high-risk work stays in Claude. Use it whenever implementation starts in this repo (AGENTS.md rule), whether or not the user mentions opencode; its routing decides per task between opencode and a Claude subagent.
---

# Implementation via opencode

## When to use

Load this skill whenever implementation starts (see `AGENTS.md`). The user doesn't need to name
opencode. The routing below still decides, task by task, whether the work goes to opencode or to
a Claude subagent.

## Routing

You always split the work into tasks, write the prompts, review every diff, run the checks,
apply the result and report to the user. Then route each task, even when the user said
"opencode". The rules come from the benchmark in `bench/` (evidence in `bench/RESULTS.md`) and
from the features built with this skill since. By 2026-10-04 about 30 real opencode tasks had
almost all passed review first time. Review found small things: indentation drift, stale
comments, copy, a test that asserted too little, invented fixture values. The serious bugs were
caught by the final Opus review, in Claude-written code as well.

The deciding question isn't how complex a task is, but **whether you can hand it over as a
complete spec with a concrete check.** Judge that after the plan's contract
(`plan/<feature>/implementation.md`) is written: the contract settles most design questions.

| Task | Goes to |
|---|---|
| A complete spec within one area, with specific tests or a build as the definition of done | **opencode**, `vision-flash` at the default level |
| UI whose layout, wording and states the prompt spells out (tables, cards, forms, badges, pickers, links) | **opencode**; you check it live in the browser before applying |
| Review fixes with a reproduction or a precise expected behaviour; test updates after a behaviour change, by a clear rule | **opencode**; the reproduction or the rule is the check |
| Design work or vague requirements: the spec can't be written even with the contract | Claude, Opus at high effort |
| The core of a change that needs broad knowledge of this repo (pipeline orchestration in `domain/pipeline` or `domain/runs`, staleness, creation paths, stage behaviour) | Claude, Opus at high effort, with the mechanical rest carved out for opencode (see below) |
| No strong check possible: UI whose look or interaction is still being worked out, LLM prompt or content quality | Claude |
| Security, auth, provider credentials, publishing flows, migrations of real stored data, byte-identical stored-data rules | Claude: the risk is too high even when the model could do it |
| Reviews | Claude, Opus at high effort |
| Everything else that stays in Claude | Claude, Sonnet at high effort |

**opencode is fine** for work `vision-flash` has handled at the same level as Claude, as long as
the spec is complete:
- precisely specified functions, pattern-following features across a few files, bug fixes;
- debugging from clear symptoms, even when the cause isn't known yet;
- asyncio concurrency, speed rewrites that must keep exact behaviour, and a feature across the
  API, service and storage layers of one area;
- UI with a spelled-out layout: about 20 such tasks by 2026-10-04, each needing only small
  review fixes;
- tasks bigger than the benchmark's 10 files, when they stay in one area and mostly follow
  existing patterns. The 10-file bound came from the benchmark tasks, not from a failure: the
  asset-progress core (shared core, restyle port, endpoint; 117 steps) passed review.

**Claude subagents** use the lean agent types in `.claude/agents/`. They pin model and effort and
carry only the tools a coder needs:
- `impl-sonnet-high`: the default for implementation that stays in Claude;
- `impl-opus-high`: the Opus rows above;
- `review-opus-high`: reviews, read-only apart from scratch reproduction tests. For a big
  feature, run one per area (for example backend and frontend) instead of one reviewer that
  spawns its own;
- a plain `general-purpose` or `claude` subagent used about 4x the tokens for the same result.
  Use one only when the task needs a tool the lean types lack (the browser, MCP tools, spawning
  agents). If the Agent tool doesn't offer a lean type yet, fall back to `claude` with a `model`
  override;
- use extra-high or max effort only when the user asks: it showed no quality gain, at about
  1.7x the tokens.

**Splitting and taking work back:**
- **Tie-breaker:** if you're unsure where a task belongs and a strong check exists (tests,
  goldens, a build plus a live check), try opencode first. A miss is caught by the check and your
  review, so it costs time, not quality. Without a strong check, keep the task in Claude.
- **Carve Claude tasks down.** For every task headed to Claude, ask which part could be a
  complete spec. Claude (usually Opus) does the core change first. The mechanical rest (passing a
  parameter through call sites, an endpoint over the new function, adapting existing tests) goes
  to opencode afterwards, specified against the core's diff. Golden tests and the final review
  cover the seam.
- Before starting, tell the user in one line per task where it goes and why.
- **When review finds problems in an opencode diff:** specific defects (a missed case, a wrong
  message, a weak test) get one follow-up opencode run in the same worktree, with the findings
  written as a spec. Take the task back into Claude when the design is wrong, the diff leaves
  its files or changes a contract, or the follow-up run fails review too.
- A routing table in a plan written before 2026-10-04 predates these rules (it may send UI or
  test updates to Sonnet, or name the `claude` agent type). Re-check it against this table
  before building.

## Workflow

The script is `.claude/skills/opencode-implement/scripts/oc.sh` (run it from the repo root).
Worktrees and logs live in `~/.cache/videofactory-opencode/`, outside the repo.

1. **Prepare**: `oc.sh prepare <name>`. This creates a worktree from HEAD plus the current
   uncommitted changes and untracked files, then commits that state as a baseline so the result
   diff contains only opencode's work. `backend/.venv` and `frontend/node_modules` are symlinked
   in so tests can run. `.env` is **not** copied.
   - Keep worktrees under the default `~/.cache/videofactory-opencode/`, never in the session
     scratchpad or temp dir: a session's temp dir was wiped mid-build on 2026-10-04, taking
     the task worktrees with it. A plan's runbook that says scratchpad is out of date.
   - Building in a feature worktree: run that worktree's own copy of `oc.sh`. `REPO` comes from
     the script's location, so `prepare` mirrors that worktree and `apply` lands the diff there.
     Prefix the task names (`rv-back`) so they don't clash in the shared cache.
2. **Prompt**: write it to a file in your scratchpad. The opencode model has none of this
   conversation, so the prompt must stand alone:
   - start with: "You are the implementer for this task: do the work yourself; don't load
     opencode-implement, run oc.sh or spawn agents." opencode reads the worktree's `AGENTS.md`
     and once played controller (ran `oc.sh summary`, wrote a routing report, edited a file
     outside its list)
   - the goal, and the exact files or areas to change (plus files **not** to touch)
   - the existing patterns to follow, with file paths
   - the exact behaviour, including edge cases, error cases and ordering or tie-breaking rules
   - constraints: stay inside the working directory; don't read or create `.env` files;
     no git commits; don't touch `backend/data/`; never use `git stash` (the stash stack is
     shared by every worktree and session; to compare with the baseline use `git diff HEAD` or
     a temporary copy). The model did run a bare `git stash` + `git stash pop` twice before
     2026-10-05 prompts carried this line.
   - done when: the specific tests to add or update, and the commands that must pass:
     backend `cd backend && .venv/bin/python -m pytest -q [paths]`, frontend
     `cd frontend && npm run build` / `npm test`. Add "Do not run the whole suite": a run once
     ran the 19,600-test backend suite twice and sat for 20 minutes. Run the full suite yourself
     with `-n 8` after applying.
   - end with a short summary of the files changed and any open issues
   - **Big batches** (test updates across many files): at most about 5 files and 2,500 lines
     per run. Add a "How to work" section: one file at a time, grep for the names you need,
     never read a file over 400 lines in one go. A 13-file batch (19k lines) filled the
     context, compacted and stopped with 1 file done; with these limits 46 batches ran clean.
3. **Run**: `oc.sh run <name> <prompt-file> [model|-] [variant]` with `run_in_background: true`
   (runs can take minutes) and always `timeout: 7200000` on that Bash call: the 30-minute
   default killed a run, and under heavy machine load UI tasks took 20-55 minutes. Watch a long
   run with `Monitor` (an until-loop), not a background `sleep` script: those exited silently.
   Leave out `[model]` (or pass `-`) to use the default; pass it when the
   user names a model. Pass `[variant]` only when the user asks for one. Don't read the raw
   `.jsonl` log.
4. **Summarize**: `oc.sh summary <name>` lists the tool calls, the model's messages and the token
   totals.
   - If it prints `OUTPUT LIMIT HIT`, the run **failed**, even though it exited 0: the model
     stopped mid-answer. Retry once with the same prompt; if that is cut off too, take the task
     back into Claude.
   - A run can also stop early with no `OUTPUT LIMIT HIT`: an empty final `stop` step, exit 0,
     half the spec done. Check that the last TEXT accounts for every step of the spec. Finish
     the rest with a follow-up run in the same worktree that restates the context.
   - Silent stall: the work is done but `run` keeps printing "still running, Ns since last
     event" for many minutes, with no child process. When `summary` shows the final checks
     already ran, review `oc.sh diff`, re-run the checks yourself in the task worktree, then
     `kill` the `opencode run` pid. `run` exits 143 and `apply` works as usual.
   - `summary` cuts each TEXT to 600 characters and `cleanup` deletes the `.jsonl`. When you
     need the run's full last message (lists of stuck or topic-only items), save it before
     cleanup with a tiny script that prints the last `"type":"text"` part of `<name>.jsonl`.
   - If `summary` prints `GIT STASH USED`, or `run` printed `STASH CHANGED`, don't apply yet.
     Look at `git stash list`: an entry the run left behind holds work that is missing from the
     diff. Identify it by its message and files before you touch it, restore it with
     `git stash apply <sha>` in the task worktree (not `pop`, which takes the top entry,
     whoever made it), then drop that entry. `STASH CHANGED` can also come from another
     session's stash during the run; then the run's own diff is fine.
5. **Review**: `oc.sh diff <name> --stat`, then `oc.sh diff <name>`. Read it the way you would a
   subagent's work: correctness, matching the surrounding style, scope creep.
   - Re-run the tests yourself inside the worktree. The model's "all green" isn't proof.
   - For algorithmic or edge-case-heavy code, **get independent tests before applying**:
     randomised or property checks against a simple reference, not only the model's tests. In the
     benchmark, a run whose own tests were green still crashed on some inputs. Write them
     yourself or with `impl-sonnet-high`, from the spec, without showing it the implementation.
   - **Trial, not proven yet (2026-10-04):** a second opencode run can write those tests instead.
     Prepare its worktree before the implementation is applied and give it only the spec and the
     interface. Copy its tests into the implementation worktree, then plant 3-5 bugs in the
     implementation yourself and check that the tests fail on each. Both runs use the same
     model, so they can misread the spec the same way: review the test's reference and input
     generator. The first time, run it next to Claude-written tests and compare before relying
     on it, then record the result here.
6. **Iterate if needed**: small fixes you can make yourself in the worktree. For bigger ones, run
   again with a follow-up prompt (same worktree; opencode starts a fresh session, so restate the
   context).
7. **Apply**: `oc.sh apply <name>` puts the diff onto the main working tree (it checks first).
   - If the patch doesn't apply (for example another session changed one of the files), `apply`
     writes nothing, prints `apply FAILED`, keeps the patch at
     `~/.cache/videofactory-opencode/<name>.patch` and exits 1. Check the exit code, not only
     the last line of output.
   - Then run the relevant tests in the main tree.
   - **Checkpoint** each reviewed task before moving on, so a lost worktree costs nothing:
     pin the tree in a hidden ref, built through a throwaway index **inside a subshell**:
     ```
     ( export GIT_INDEX_FILE=$(mktemp -u); git read-tree HEAD
       git add -A -- . ':(exclude)backend/.venv'
       c=$(git commit-tree "$(git write-tree)" -p HEAD -m "<feature> <task>")
       git update-ref refs/<feature>-checkpoints/<task> "$c" )
     ```
     Run it in the worktree that holds the reviewed state. The exclude keeps a symlinked
     `backend/.venv` out (`.gitignore`'s `.venv/` doesn't match a symlink); `git add` exits 1
     when an ignore rule already covers it but stages the rest. Hidden refs survive `gc`.
     Restore with `git checkout refs/<feature>-checkpoints/<task> -- backend`. Delete the refs
     once the feature is committed. Never `export GIT_INDEX_FILE` outside a subshell: on 2026-10-16 it
     leaked into the next `oc.sh prepare`, and that worktree's own index was never written
     (every file showed as a staged delete plus untracked; the work was intact).
     `env -u GIT_INDEX_FILE git read-tree HEAD` in that worktree rebuilds the index.
8. **Cleanup**: `oc.sh cleanup <name>`.

## Parallel tasks

Give independent tasks separate names and worktrees, and split them by files so the diffs don't
overlap (the same file split used for subagents). Apply them one at a time and run the tests after
each.

Parallel runs can be launched together. Two opencode processes starting in the same second used
to fail ("database is locked", or "unknown model" from two `opencode models` checks at once), so
`oc.sh run` now takes a start lock (`<root>/.start.lock`, shared by every `oc.sh` on that root)
for the model check and the first few seconds of opencode. The next run prints `waiting for
another opencode start...` and goes once the previous start settles (`OC_START_GAP`, default 5 s;
`OC_START_MAX`, default 30 s). A lock left by a killed `oc.sh` is broken when its process is gone
or it is older than 120 s. After changing `oc.sh`, run `scripts/test_oc.sh`; it uses a fake
opencode and takes about 25 s.

## Reporting

Tell the user:
- which tasks went to opencode and which stayed in Claude, and why;
- the token totals per run (from `summary`) and any run that hit the output limit;
- what you fixed or redid yourself, and the tests you added during review;
- the test results.

If opencode fails a task twice, stop delegating that task, do it yourself, and say so.

## Settings

- **Model:** the default is `swissquant-local/vision-flash`, the user's own GPU server
  (Tailscale), so it costs no Claude tokens or hosted-key credits.
  - Precedence: the `run` argument, then `OC_MODEL`, then the default.
  - A bare name like `vision-power` means `swissquant-local/vision-power`. Other providers take
    the full `provider/model` form, e.g. `phoenics/inference-kimi-k3` or `opencode-go/glm-5.3`.
  - The script checks the name against `opencode models` before it runs.
- **Which model to use:** the one the user names in the request. If the default is down (the
  local server's proxy answers but the model gives connection errors), tell the user and ask
  which model to use. Don't quietly switch to a hosted one.
- **Output limit:** `vision-flash` needs `"limit": { "output": 32768 }` in
  `~/.config/opencode/opencode.json`.
  - With 8,192, runs were cut off while the model was still thinking, and opencode reported them
    as successful. The largest step seen at 32,768 was about 18k tokens.
  - If runs start hitting the limit, check that setting before anything else.
- **Reasoning variant:** the default is none, meaning the model or server decides; `OC_VARIANT`
  or the 5th `run` argument sets one. `high` works with the 32k limit but showed no benefit, so
  use it only when the user asks. Valid values depend on the provider (for example
  `low`/`medium`/`high`/`max`), and opencode passes them through without checking.
- **Permissions:** `--auto` approves every tool call opencode makes. The worktree plus the prompt
  constraints are the only guardrails, so keep the scope explicit.
