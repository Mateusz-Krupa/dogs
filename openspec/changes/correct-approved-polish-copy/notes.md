# Evidence and decisions

- 2026-10-23: User approved every audit finding 001–126: “spoko popraw wszytko”. This is approval of the stated replacements, including J/S/M findings, not permission for unlisted rewrites or domain changes.
- Retrieved project memory again before planning. The only result was an unverified implementation-bridge skill unrelated to this planning task. Local memory category files contain templates only; no reusable entry was relied on. Current AGENTS/workflow routing governs implementation.
- Concurrent uncommitted work exists in native migration and hygiene care, including the resource catalog and checksum fixtures. No application edits were made by the planner. Recheck live values before replacements and preserve unrelated work.
- Migration parity manifest is a frozen historical snapshot. Copy corrections must not regenerate it as if the new text had been present at migration capture. Use this change's before/after ledger for approved content evolution and keep current checksum tests meaningful.
- Item 125 itself requires showing any additional metaphor rewrites before implementation; “all” therefore selects its explicit example, not an unspecified global editorial rewrite. Item 124 explicitly allows typography-only normalization throughout Polish fields.
- Independent audit review previously failed to start; it was not performed. A fresh independent plan-review gate remains required before apply. No reviewer findings are pre-approved merely because all audit IDs were selected.
- 2026-10-23 plan gate attempt: reviewer tool returned `Subagent session not found`; no independent assessment was produced. Task 1.1 remains unchecked and application edits are blocked until the gate can actually run.
- Artifact verification: using Node v22.22.3, `openspec validate correct-approved-polish-copy --strict` passed. CLI status reports proposal/design/specs/tasks artifacts complete; this means artifact completeness only, not implemented tasks or reviewer approval. No application tests or application edits were performed during planning.


## Live-tree disposition (2026-10-23) — the approval does not match the shipped app

`implementation-notes.md` records a mechanical check of all 126 audited IDs against the working
tree (103 corpus files: JS canon, native bundle, both locale catalogues). Result: **0 rows
implemented verbatim, 103 rows NOT APPLIED, 23 rows CONFLICT/PAUSED**. Matcher soundness was
probed in four independent ways before the numbers were trusted.

Two causes, both real:

1. `add-hygiene-care-section` rewrote overlapping care fields (its welfare review V-1…V-6). Per
   this change's own spec scenario "Live content changed during another feature", those rows are
   recorded and paused, not overwritten back.
2. The earlier copy round fixed ~23 fields in its own words rather than the approved words
   (`Kalec` → `Kaganiec` is in the tree; the audit's sentence is not).

Also relevant: this change and TestFlight build 5 are already out of sync — build 5 ships copy
from a tree where these corrections had not landed. Anything still `NOT APPLIED` here is live
user-facing copy, and after the native cutover the only place to apply it is
`Pettrainer/Resources/Content/` + `Pettrainer/Resources/Localizable.xcstrings`; the tasks in
sections 2–3 that name `src/` files become native-path work under `migrate-to-native-swift` 9.2.
