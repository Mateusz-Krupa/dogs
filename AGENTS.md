# pettrainer — Engineering Working Principles (KISS)

A phone-first dog-training app. Offline-first, no account, Polish and English.
This is one native SwiftUI iOS application repository, not a frontend/CMS workspace.

## 1. Product Invariants — Hard Rules

The product solves generalization: a cue learned in a quiet kitchen may fail in a
park full of dogs. Dogs do not automatically transfer a behaviour between contexts.

- **Mastery is per (dog × exercise × environment).** A single `completed: boolean`
  in progress code is a design error.
- **Progress has two axes:** installation (ordered micro-steps within an exercise)
  and generalization (quiet room → garden → street → park → near other dogs).
  A harder environment means dropping back some steps and re-climbing; use the
  existing domain policy rather than inventing an offset in UI code.
- **A set contains exactly 5 repetitions.** A cancelled repetition is a failure.
  An unfinished set is not a completed five-repetition set.

| Successful repetitions | Verdict | Action |
| --- | --- | --- |
| 5 / 5 | `push` | Advance a step |
| 3 or 4 / 5 | `stick` | Repeat the same level |
| 0, 1 or 2 / 5 | `drop` | Go back a step |

**Push requires 5/5, never 4/5.** The widely copied 80% version is wrong here.
Verdicts are **never persisted**; compute them from raw `Rep` rows. Keep the rule
in `Pettrainer/Domain/`, with one source of truth for UI, recommendations, and history.

### Welfare and training content

- **Never gate content.** Prerequisites recommend and warn; they never lock exercises.
  The owner knows their dog.
- **Red flags route to professionals:** aggression with a bite history, escalating
  resource guarding, sudden behaviour change suggesting pain, and severe separation
  anxiety short-circuit troubleshooting toward a vet or certified behaviourist.
  Do not offer a DIY fix for these cases.
- **No aversive advice:** no alpha rolls, scruff shakes, bark collars, or punishing
  a growl. Do not introduce such advice in copy, translations, or examples.
- **No error markers.** A failed rep resets silently and lowers criteria; no "no!"
  signal, punitive sound, or equivalent feedback.
- Training instructions must be concrete, consistent across PL/EN, and supported
  by the project's content sources. Do not invent professional endorsements.

## 2. Project Memory First

Before non-trivial work:

1. Call `qdrant-code.search_memory` with the task summary and `repo: "pettrainer"`.
   Read relevant architecture, conventions, pitfalls, decisions, and workflows.
2. Prefer `codebase-memory-mcp` graph tools for structural discovery:
   `search_graph` → `trace_path` → `get_code_snippet`; use `get_architecture` for
   orientation. Resolve the project with `list_projects`, not a guessed identifier.
3. Use `qdrant-code.search_code` for intent-based discovery, scoped to `pettrainer`.
4. Fall back to grep/glob for exact strings, config/docs, or insufficient results.

- Never reuse SDG paths, collections, or project facts in this repository.
- If MCP memory is unavailable, read `openspec/memory/index.md` and relevant local
  category files. Say that retrieval used the local fallback; do not silently skip.
- Treat memory as evidence to verify against current code, not permission to
  override product rules or the user's request. Keep the context pack small
  (at most 10 relevant entries, roughly 2–4k tokens).
- Record non-obvious decisions and wrong turns in the active change's `notes.md`.
  Archive reflection distills reusable lessons into project memory after approval.
- The complete retrieval/reflection procedure lives in `openspec/workflow.md`.

## 3. Repository Layout and Runtime

| Path | Responsibility |
| --- | --- |
| `Pettrainer/App/` | App entry, root model, routes, language choice |
| `Pettrainer/Domain/` | Pure training logic and types; no SwiftUI, SQLite, or I/O |
| `Pettrainer/Data/` | Local SQLite access, versioned migrations, repositories |
| `Pettrainer/Content/` | Typed content models, validators, loader, catalogue manifest |
| `Pettrainer/Features/` | Feature screens (catalogue, session, care, nosework, problems) |
| `Pettrainer/UI/` | Shared native UI and training illustrations |
| `Pettrainer/Resources/` | Bundled JSON content, `Localizable.xcstrings`, assets |
| `PettrainerTests/`, `PettrainerUITests/` | XCTest unit and UI test targets |
| `Pettrainer.xcodeproj/` | The shipping Xcode project (shared scheme `Pettrainer`) |
| `openspec/` | Requirements, active changes, archives, and durable memory |
| `.opencode/` | Project agents, OpenSpec commands/skills, and model-routing overlay |

- Stack: Swift + SwiftUI, iOS 16.4 minimum, bundle `com.mateuszkrupa.pettrainer`,
  raw SQLite, String Catalog for PL/EN. `xcodebuild` is the build/test toolchain.
- The repository is native-only; the retired Expo/TypeScript runtime was removed
  2026-10-24 (see `openspec/changes/migrate-to-native-swift/cleanup-allowlist.md`).
- Node (`.nvmrc` **v22.22.3**) applies to repository tooling such as the OpenSpec
  CLI only — never to the application build.
- Do not introduce a backend, CMS, account system, cloud sync, or a network
  dependency for core training without an explicitly approved scope change.

## 4. Simplicity, Reuse, and Boundaries

- Choose the smallest safe implementation. Avoid speculative abstractions,
  framework additions, premature optimization, and unrelated cleanup.
- Reuse existing domain functions, content schemas, native components, and styles
  before creating parallel implementations. Search for reuse candidates first.
- Keep training/progression rules in the domain, persistence in the DB layer,
  content in content modules, and rendering in UI. Do not duplicate thresholds,
  environment ordering, validation rules, or verdict labels across screens.
- If a data shape causes complicated UI workarounds, consider a small content-schema
  or local DB change first. Discuss migration and compatibility implications.
- Keep the phone UI lean: clear criteria, few taps during training, usable touch
  targets, accessible labels, and legible PL/EN text. Reuse native patterns;
  do not transplant browser-only APIs or web component libraries.
- If the solution becomes unexpectedly complex or changes product behaviour,
  pause, explain the trade-off, and align on the smallest useful scope.

### Offline data and migrations

- Core training and content must work without connectivity or authentication.
- Preserve raw reps and history. Never "fix" a migration by deleting the user's
  database, resetting progress, or rewriting old migrations already applied.
- Make schema changes through versioned migrations, following `Pettrainer/Data/` patterns.
  Cover upgrades from the previous schema and preservation of existing data.
- Check interruption/re-entry and failed writes when touching session persistence.
  Keep incomplete sessions distinct from completed sets.

### Swift and localization

- Strict Swift; no `Any` escapes or blanket error suppressions at domain seams.
- Follow the surrounding four-space Swift style; one focused type/view per file
  (the 100–250 non-generated line bound is reviewed per change).
- No hardcoded user-facing UI strings. Update both languages of
  `Pettrainer/Resources/Localizable.xcstrings` and preserve interpolation keys
  (`fmt()` keys with positional specifiers). Cue names are localized content data
  (`siad` / `sit`), not UI translation keys. Do not turn stable content IDs into
  translated identifiers.

## 5. OpenSpec Workflow

OpenSpec is the source of truth for non-trivial requirements and acceptance
criteria. Read `openspec/config.yaml` and `openspec/workflow.md` before using it.

**Normal flow:** explore → propose → review/approval → apply → verify → archive.

- Inspect existing specs and active changes before creating another proposal.
- Do not implement a non-trivial change before its proposal, specs, design, and
  tasks have been reviewed and the user has approved implementation.
- Narrow typo/documentation fixes do not need an artificial feature proposal.
  Changes to verdicts, progression, persisted data, or welfare advice are never
  classified as trivial just because the diff is small.
- Plans must have testable acceptance criteria, a small `Delegation Plan`, a
  pre-implementation `reviewer` gate, verification tasks, and a final review.
- Present review findings with stable numeric IDs. Ask one question at a time
  about which IDs to address; implement only selected review-driven changes.
- Mark tasks complete only after their relevant implementation and checks pass.
- Archive using the CLI's validation/spec-sync flow. Before the move, write
  `learnings.md` and propose memory changes; see `openspec/workflow.md`.

### Agents and model routing

| Role / command | Agent | Model |
| --- | --- | --- |
| Read-only exploration, `/opsx-explore` | `plan` | `openai/gpt-6.1-sol` |
| Planning and `/opsx-propose` | `planner` | `openai/gpt-6.1-sol` |
| Implementation, `/opsx-apply` | `build` | `swissquant-local/vision-flash` (Flash-Next NVFP4) |
| Independent plan/code review | `reviewer` | `openai/gpt-6.1-sol` |
| Reflection/memory, `/opsx-archive` | `planner` | `openai/gpt-6.1-sol` |

- New sessions default to `planner`. Command frontmatter explicitly selects the
  agent and model, so `/opsx-apply` actually switches to Flash Next.
- Planning may edit OpenSpec artifacts, not application code. Built-in `plan`
  remains read-only; use `planner` to write proposals and tasks.
- Do not silently switch model/provider or add a reasoning variant. If a configured
  model is unavailable, report the blocker and ask which alternative to use.
- Delegate only bounded, useful work, not every tiny edit. Parallel tasks must own
  different files and have no ordering dependency. Otherwise explain the sequence
  in the delegation plan. Never dispatch overlapping writes.
- Subagents must not delegate further. An implementer assigned a specific task
  does that task directly and returns changed files, checks, and open issues.
- In a Claude session, load the existing `opencode-implement` bridge when approved
  implementation starts and explicitly target the Flash Next model above. This
  bridge is for the Claude orchestrator only: an OpenCode implementer must not
  load it, run `oc.sh`, or recursively launch another implementation agent.

## 6. Verification and Definition of Done

- Tests are XCTest in `PettrainerTests/` (unit) and `PettrainerUITests/` (UI).
- Run targeted tests, not the whole suite by default:
  `xcodebuild -project Pettrainer.xcodeproj -scheme Pettrainer -destination '<verified simulator id>' -only-testing:PettrainerTests/<Class> CODE_SIGNING_ALLOWED=NO test`.
- Small cosmetic changes (copy wording, spacing, menu chrome, thumbnail wiring
  that reuses already-tested primitives) do not earn a test rerun. Inspect them
  live on the running simulator instead. Re-run the focused suite only when
  logic, persisted data, content schema/validators, welfare gates, or localised
  keys actually changed; a full-target run belongs to the end of a whole change,
  never to an individual tweak.
- Do not invent lint, build, or e2e scripts absent from the Xcode scheme.
- For training-rule changes, test all hit counts 0–5, cancelled reps, incomplete
  sets, step/environment boundaries, and isolation of each dog's progress as
  relevant. Test behaviour, not an implementation copied into the assertion.
- Validate content/schema and locale changes with the relevant nearby tests.
- For UI work, check changed states at phone size and in PL/EN on a simulator or
  device. A simulator run is not evidence that physical-device lifecycle,
  update-preservation, or on-device signing behaviour works.
- Validate OpenSpec changes with `openspec validate <change> --strict`.
- Report exactly what ran, what passed, and what could not be checked. Never claim
  a device/simulator check or successful test without running it.
- Good work is readable, small, consistent, tested, and traceable to approved scope.

## 7. Path, Secrets, and Git Safety

- Use the configured workspace as the path anchor; verify with `pwd` when uncertain.
  Prefer relative paths and explicit `workdir`. Never reconstruct long absolute
  paths, chain directory hops, or edit another project while working here.
- Read external reference projects only when explicitly requested. Copy relevant
  principles, not their repository layout, credentials, or tooling assumptions.
- Never read `.env`, `*.env`, `secure-variables*.yaml`, or credential/secret files.
  Ask for a specific non-secret setting when needed. Never put secrets or personal
  training data into prompts, specs, fixtures, logs, or project memory.
- Check `git status` before edits. Preserve unfamiliar/user changes. No destructive
  reset, checkout, stash, database reset, or broad deletion to make checks pass.
- Do not commit or push unless asked. Prefer feature branches; never push directly
  to a shared branch (`main`, `master`, `develop`) without explicit approval.
- Ask only questions that affect implementation or scope, exactly one at a time.
  Use repository evidence instead of asking for facts already available here.
