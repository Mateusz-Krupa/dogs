---
name: openspec-archive-change
description: Archive a completed change in the experimental workflow. Use when the user wants to finalize and archive a change after implementation is complete.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.3.0"
---

**Project workflow (mandatory):** Read `openspec/workflow.md` before these steps.
Before the archive move, write `learnings.md`, deduplicate candidate memories,
and show the memory diff for user approval. Apply only approved durable updates;
archive through the CLI and refresh retrieval afterward. Use `/opsx-archive` for
GPT-6.1 Sol routing. Shared project rules override generated defaults.

Archive a completed change in the experimental workflow.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **If no change name provided, prompt for selection**

   Run `openspec list --json` to get available changes. Use the **AskUserQuestion tool** to let the user select.

   Show only active changes (not already archived).
   Include the schema used for each change if available.

   **IMPORTANT**: Do NOT guess or auto-select a change. Always let the user choose.

2. **Check artifact completion status**

   Run `openspec status --change "<name>" --json` to check artifact completion.

   Parse the JSON to understand:
   - `schemaName`: The workflow being used
   - `artifacts`: List of artifacts with their status (`done` or other)

   **If any artifacts are not `done`:**
   - Display warning listing incomplete artifacts
   - Use **AskUserQuestion tool** to confirm user wants to proceed
   - Proceed if user confirms

3. **Check task completion status**

   Read the tasks file (typically `tasks.md`) to check for incomplete tasks.

   Count tasks marked with `- [ ]` (incomplete) vs `- [x]` (complete).

   **If incomplete tasks found:**
   - Display warning showing count of incomplete tasks
   - Use **AskUserQuestion tool** to confirm user wants to proceed
   - Proceed if user confirms

   **If no tasks file exists:** Proceed without task-related warning.

4. **Assess delta spec sync state**

   Check for delta specs at `openspec/changes/<name>/specs/`. If none exist, proceed without sync prompt.

   **If delta specs exist:**
   - Compare each delta spec with its corresponding main spec at `openspec/specs/<capability>/spec.md`
   - Determine what changes would be applied (adds, modifications, removals, renames)
   - Show a combined summary before prompting

   **Prompt options:**
   - If changes needed: "Sync now (recommended)", "Archive without syncing"
   - If already synced: "Archive now", "Sync anyway", "Cancel"

   Record the user's sync choice for the CLI archive operation below. The core
   profile does not install a separate sync skill; do not invoke a missing one.

5. **Reflect and propose project memory before the move**

   Follow section 3 of `openspec/workflow.md`: gather scoped evidence, write
   `learnings.md`, classify lessons, evaluate memory impact, and deduplicate
   candidate memories with `search_memory` (or the local fallback). Show the
   proposed diff and ask `Apply these memory changes? [yes / edit / no]`.
   Write durable memory only after approval. If nothing is worth promoting,
   still write `learnings.md` and report `no project-memory changes`.

6. **Perform the archive and refresh retrieval**

   Generate target name using current date: `YYYY-MM-DD-<change-name>`

   **Check if target already exists:**
   - If yes: Fail with error, suggest renaming existing archive or using different date
   - If no: Use the CLI to validate, sync delta specs, and archive

   ```bash
   openspec archive "<name>" --yes
   ```

   Use `--skip-specs` only if the user chose not to sync. Stop on failure; do not
   claim success or bypass validation. After approved memory updates, refresh
   Qdrant and verify retrieval as described in section 4 of `openspec/workflow.md`.

7. **Display summary**

   Show archive completion summary including:
   - Change name
   - Schema that was used
   - Archive location
   - Whether specs were synced (if applicable)
   - Note about any warnings (incomplete artifacts/tasks)

**Output On Success**

```
## Archive Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** ✓ Synced to main specs (or "No delta specs" or "Sync skipped")

All artifacts complete. All tasks complete.
```

**Guardrails**
- Reflection (step 5) runs before the move and is never skipped silently. If nothing is worth promoting, still write `learnings.md` and report "no project-memory changes".
- Memory promotion is gated by the user (`Apply? [yes/edit/no]`) — never auto-commit memory changes without showing the diff.
- Always prompt for change selection if not provided
- Use artifact graph (openspec status --json) for completion checking
- Don't block archive on warnings - just inform and confirm
- Preserve .openspec.yaml when moving to archive (it moves with the directory)
- Show clear summary of what happened
- Never skip reflection or promote durable memory without showing the diff and approval
- Sync through `openspec archive`, not an unavailable skill or a manual move
- If delta specs exist, always run the sync assessment and show the combined summary before prompting
