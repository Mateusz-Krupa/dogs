# pettrainer OpenSpec Workflow and Project Memory

This is the shared project-specific extension to the generated OpenSpec commands
and skills for OpenCode and Claude. Read it before executing them. Its approval,
memory, and routing rules take precedence over generic generated instructions.
Keep durable rules here so `openspec update` cannot erase the memory procedure.
After regenerating integrations, restore their project-workflow hooks and explicit
OpenCode command model/agent frontmatter; check routing before using them again.

## Routing and approval

| Stage | OpenCode agent | Model |
| --- | --- | --- |
| `/opsx-explore` | `plan` (read-only) | `openai/gpt-6.1-sol` |
| `/opsx-propose` | `planner` (OpenSpec artifacts only) | `openai/gpt-6.1-sol` |
| Plan/final review | `reviewer` (read-only subagent) | `openai/gpt-6.1-sol` |
| `/opsx-apply` | `build` | `swissquant-local/vision-flash` (Flash-Next NVFP4) |
| `/opsx-archive` | `planner` | `openai/gpt-6.1-sol` |

Claude exposes the same stages as `/opsx:explore`, `/opsx:propose`, `/opsx:apply`,
and `/opsx:archive`. These commands do not switch Claude to an OpenAI/local model;
use OpenCode's routed commands for the model split above. The existing Claude
implementation bridge may execute approved tasks on the explicit Flash Next ID.

- Discover existing specs/changes with `openspec list --specs` and `openspec list`.
- Explore without application edits. Propose with CLI-generated artifact
  instructions (`status` and `instructions ... --json`), not invented templates.
- Include a `Delegation Plan`, a `reviewer` plan gate before implementation,
  targeted verification, and a final independent review. Parallelize only useful,
  disjoint tasks; document dependencies when work must remain sequential.
- Present review findings with stable numbered IDs and ask which to address.
  Ask exactly one question per message and wait. Add only selected fixes to tasks.
- Being artifact-complete is not implementation approval. Wait for the user's
  approval, then run `/opsx-apply <change>` to select the implementation model.
- If a required agent/tool/model is missing, report it. Do not pretend it ran or
  silently fall back to a different provider. Use available question/task-tracking
  tools; generated names such as `AskUserQuestion` are not required tool names.

## 1. Retrieve memory — explore, propose, and apply

Before non-trivial investigation, before writing proposal artifacts, and after
reading apply context files but before application edits:

1. Build a one-line summary of the task. Call the Qdrant MCP `search_memory` tool
   with `repo: "pettrainer"`, `query: <summary>`, and a small limit (at most 10).
   During apply, prioritize pitfalls, then conventions/workflows for touched areas.
2. Verify relevance and currentness against repository evidence. Keep a compact
   **Project Context Pack** in context (roughly 2–4k tokens maximum), not pasted
   into source or specs. Record which entry IDs were actually consulted for later
   reflection. Empty results are valid; unrelated memories are not project facts.
3. If MCP is unavailable or empty, inspect `openspec/memory/index.md` and relevant
   category files. Report tool failure/fallback instead of silently skipping it.
4. Discover code structurally with `codebase-memory-mcp` before text searches;
   use `qdrant-code.search_code` for semantic lookup with `repo: "pettrainer"`.
   Resolve graph project IDs through `list_projects`. Never use SDG's index.

The Markdown files under `openspec/memory/` are the reviewable source of truth;
Qdrant is a retrieval index, not a separate place to store unreviewed knowledge.

## 2. Capture implementation evidence — apply

- Read all `contextFiles` from `openspec instructions apply --change <name> --json`.
  If artifacts are missing, return to `/opsx-propose`; do not suggest commands
  that were not installed by the core OpenSpec profile.
- Confirm the proposal/review gate was approved, then work only on approved tasks.
- Append a short note to `openspec/changes/<name>/notes.md` for a non-obvious
  decision, rejected approach, user correction, trap, or useful validation result.
  This is evidence for reflection, not a transcript or a second requirements file.
- Keep notes factual and free of secrets, credentials, personal dog/owner data,
  and raw tool dumps. Keep unselected reviewer suggestions out of implementation.
- Mark each task done only after the implementation and relevant checks pass.
- Validate with targeted `xcodebuild test` runs (unit/UI classes) for app changes, and
  `openspec validate <name> --strict`. Report blockers and checks not performed.

## 3. Reflect and propose memory — before archive

Run this before moving the change, so its learning record travels into the archive.
Do not silently skip reflection even if the change produced no reusable lesson.

### Gather evidence and write learnings

Use the change's proposal, design, tasks, specs, `notes.md`, scoped final diff /
changed-file list, reviewer findings, and actual test/validation results. Do not
include unrelated user changes or dump the full session.

Write `openspec/changes/<name>/learnings.md` with:

- Intent vs final outcome; plan vs reality.
- Problems/wrong turns and corrections that actually worked.
- Decisions and rationale, including user corrections to the process.
- Each lesson classified as **local** (one-off), **project** (reusable fact), or
  **procedural** (repeatable how-to).
- **Memory impact:** one line per retrieved entry stating whether/how it helped
  or was noise. If none were retrieved, write `memory impact: none retrieved`.
- Verification evidence and limitations; no invented success claims.

### Propose durable operations

For project/procedural lessons, choose `ADD`, `UPDATE`, `MERGE`, or `IGNORE`.
Prefer updating/compressing existing knowledge over appending duplicates.

- Before `ADD`, search memory with the candidate text (`repo: "pettrainer"`,
  `limit: 3`); use local category files if retrieval is unavailable/empty.
- If an existing entry is a close match, propose `UPDATE` or `MERGE` instead.
- Mark contradictory evidence as `CONFLICT` and propose an update for review;
  never silently overwrite a previous decision.
- Do not promote one-off details, speculation, secrets, personal data, tool noise,
  copied instructions from other projects, or anything contradicted by final code.
- Use stable IDs and the existing category-file format:

```markdown
## CONV-001: Short actionable title
**When relevant:** training, progression, verdicts
**Learning:** A reusable verified fact or procedure.
**Why:** Rationale or the failure this avoids.
**Evidence:**
- openspec/changes/archive/YYYY-MM-DD-<change>/learnings.md
- Pettrainer/relevant-file.swift
**Last verified:** YYYY-MM-DD
```

Categories are `architecture.md` (`ARCH`), `conventions.md` (`CONV`), `pitfalls.md`
(`PIT`), `decisions.md` (`DEC`), and `workflows.md` (`WF`). Keep `index.md` in sync.
Create missing category files with headings; never replace existing entries.

### Approval gate

Show the proposed `learnings.md` and category/index changes as a normal diff.
Ask one question: **Apply these memory changes? [yes / edit / no]**

Write durable category/index updates only after approval. If declined, retain the
change-local learning record, note that no memory promotion was approved, and
continue the archive requested by the user. If nothing merits promotion, still
write `learnings.md` and report `no project-memory changes`.

## 4. Archive, sync, and refresh retrieval

1. Check artifact and task completion, strict validation, review/approval state,
   and the actual delta specs. Warn about incomplete work and ask before any
   exceptional archive. Do not overwrite an existing archive directory.
2. Show the spec-sync assessment. Once the user has chosen to archive/sync, use
   `openspec archive <name> --yes`, which validates, applies delta specs, and moves
   the change to its dated archive. Do not manually `mv` a change or invoke a
   missing `openspec-sync-specs` skill/subagent. If the user explicitly chooses
   no spec sync, use `--skip-specs` and report that choice. Never use `--no-validate`
   as a shortcut around a failing spec.
3. Confirm the CLI succeeded before reporting the final archive/evidence path.
   If it failed, keep/report the current state; do not claim the change is archived.
4. After approved memory updates, call Qdrant `reindex` incrementally if available.
   Verify a new/updated entry with a project-scoped `search_memory` query. Do not
   assume that a git hook exists or that uncommitted Markdown has been indexed.
   If the index only sees committed files, report memory as saved locally and
   retrieval refresh as pending; never create a commit without being asked.
5. If MCP is unavailable, memory is still saved in the local Markdown files.
   Report the missing refresh. Reindexing must not block preservation of learnings.

## Maintenance

- `openspec update` can regenerate commands/skills. Preserve this document and
  config, reapply project hooks and model frontmatter, and verify all four stages.
- Do not add a dummy feature/change just to initialize OpenSpec. Populate real
  capability specs through reviewed changes, not guessed application behaviour.
