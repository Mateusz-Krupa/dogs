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
user-facing copy. Both runtimes must receive corrections byte-identically: apply changes to
`src/content/data/` and the Expo locale catalogues, then mirror each content file byte-for-byte
to `Pettrainer/Resources/Content/` and apply native-only UI keys to
`Pettrainer/Resources/Localizable.xcstrings`. Tasks 2.x name `src/` files as the authoritative
source; task 3.1 mirrors to native. This is the two-runtime contract, unchanged by the native
cutover in progress. Do not transfer this change's tasks to `migrate-to-native-swift` 9.2.

## Reviewer gate result (2026-10-23)

Independent pre-implementation review completed (ses_e9735c4e4ffe6620yDXefk28KY).
- RV-001 (blocker): notes.md previously directed tasks to native-only under migrate 9.2,
  contradicting the two-runtime proposal/spec/tasks contract. **Fixed** in this revision.
- RV-002 (should-fix): `implementation-notes.md` prefix-match ledger is preliminary triage only,
  not acceptance evidence. Apply must replace it with exact field-level results per ID and EN
  disposition per the design.
- RV-003 (note): welfare-referral IDs 045, 049, 089, 094 added to task 3.3 assertion list.

Task 1.1 can now be checked. Task 1.2 is satisfied by the user's message "dobra popraw" in this
session, which directly follows the artifact summary and instructs implementation to proceed.
All three reviewer findings target this change's own artifacts only (not new application wording);
they are fixed as part of this gate pass.

## Implementation results (2026-10-23)

**Applied:** findings 001–091, 093–100, 102–126 (including typography 124: 19 quotation-pair
instances normalized across all PL content fields; 125: one explicit example applied; 126: snapping
distinction preserved, no global substitution). 40 content files changed in both runtimes. 50/50
native copies verified byte-identical. Nonlocalized structure (IDs, ordinals, counts, gear, links)
unchanged in all files. No EN fields accidentally modified.

**Conflicts (care concurrent work, add-hygiene-care-section):**
- 092 (care-nails urgent.pl 2nd sentence): concurrent care welfare review already replaced the
  "łagodny lek" guarantee with "plan ustala weterynarz, a nie siła" — welfare intent (vet decides,
  no medication guarantee) preserved. Row paused; not overwritten.
- 101 (care-teeth urgent.pl 1st sentence): concurrent care work already replaced "zawarty w niej"
  with "część z nich zawiera" — the over-broad factual claim was fixed by care's own V-1 review.
  Row paused.
- 105 (care-teeth stages[1].pl.stop 2nd sentence): concurrent care work already replaced "Dziąsła
  krwawiące… idą do weterynarza" with "Jeśli dziąsła krwawią przy dotyku — zadzwoń do weterynarza"
  which conveys the same welfare instruction. Row paused.

**Checks run:**
- `npx jest src/content/load.test.ts src/content/schema.test.ts src/content/schema/behaviour.test.ts
  src/content/schema/care.test.ts src/i18n/i18n.test.ts --runInBand`: 77/77 passed.
- `npx jest src/content/copy-welfare.test.ts --runInBand`: 15/15 passed (new file).
- `npm run typecheck`: clean.
- `npx jest src/domain/verdict.test.ts --runInBand`: 37/37 passed; domain untouched.
- `xcodebuild test … ContentLoaderTests StringsTableTests CareContentTests CareValidatorTests`:
  33/33 passed, TEST SUCCEEDED. Migration baseline `parity-data.json` unchanged.
- `openspec validate correct-approved-polish-copy --strict`: valid.

**Not independently checked:** 5.5 manual phone-size PL/EN UI layout — requires user with device.

## Final reviewer result (2026-10-23, ses_e97265432ffe7Jx3yECgihHqLc)

Reviewer found 2 blockers and 4 should-fix findings (FR-001–FR-006). All resolved:
- **FR-001 (blocker, EN welfare):** `mistakes/drop.json en.fix`, `behaviour/nipping.json en.urgent+professional`,
  `nosework/snuffle.json level 3 en.how+watchFor` — EN corrected to match approved PL welfare meaning
  (resource-guarding: stop independent attempts; nipping: attempted bites + escalation; snuffle: supervised,
  paper ingestion stop). Checksums and native copies updated.
- **FR-002 (blocker, EN criteria):** `exercises/drop.json step 4 en.criterion` and
  `exercises/mat.json step 4 en.criterion` — EN criteria aligned with instructed task (treat shown for drop;
  self-initiated approach for mat). Checksums and native copies updated.
- **FR-003 (should-fix):** `behaviour/bed.json urgent.pl` — finding 126 explicit replacement applied.
- **FR-004 (should-fix, typography):** `walk_and_fix` function had incomplete recursion for PL dicts nested
  under the `pl` key (strings at sub-keys like `instruction`, `note` were skipped). Re-run fixed remaining
  50 `„…"` pairs across 20 content files. Native copies updated.
- **FR-005 (should-fix):** `bed.json work.pl[0]` — typo `na miejsca` → `na miejsce`. Native copy updated.
- **FR-006 (should-fix, test coverage):** `copy-welfare.test.ts` extended from 15 → 26 assertions:
  EN welfare/criteria regression guards for 045, 068, 120, 024, 036; stronger 092 referral assertion;
  FR-004 typography suite (parameterised across all content subdirectories); FR-005 cue-name assertion.

## Final verification (post-FR corrections)

- 7 targeted Jest suites: 140/140 passed (copy-welfare.test.ts: 26/26).
- `npm run typecheck`: clean.
- `openspec validate correct-approved-polish-copy --strict`: valid.
- `xcodebuild test … ContentLoaderTests StringsTableTests CareContentTests CareValidatorTests`:
  33/33, TEST SUCCEEDED.

