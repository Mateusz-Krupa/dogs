## 1. Approval and independent review gates

- [ ] 1.1 Obtain independent `reviewer` pre-implementation assessment of the audit, proposal, design, specs and this task list. Record actual outcome in notes; if the reviewer tool is unavailable, stop application edits and report the blocker.
- [ ] 1.2 Confirm the user's recorded approval of audit IDs 001–126 and approval of this bounded implementation plan before apply. Present any NEW reviewer findings with stable numeric IDs and obtain selection before changing artifacts or wording. Do not treat the earlier “all” as approval of new findings.
- [ ] 1.3 At `/opsx-apply` start retrieve memory, verify git status, coordinate ownership of shared care/migration files, and create `implementation-notes.md` with all 126 IDs plus live source/native locations. Record conflicts/already-correct fields without overwriting unfamiliar work. Capture before-hashes for touched content into `approved-content-delta.md` before copy edits.

## 2. Approved Polish and corresponding English content

- [ ] 2.1 Apply UI findings 001–015 in `src/i18n/locales/pl.ts`, the existing inline catalogue copy and `Pettrainer/Resources/Localizable.xcstrings`; update only corresponding EN meaning where necessary. For 012 fix the equivalent Expo count label if present, preserving its interpolation. Check all placeholder names/types and the three native-only care labels.
- [ ] 2.2 Apply exercise findings 016–024 in `src/content/data/exercises/{come,down,drop}.json`; 024 changes criterion text to match the current task, not scoring or step topology. Compare EN for every edited sentence and record disposition per ID.
- [ ] 2.3 Apply exercise findings 025–033 in `exercises/{handling,leash,leave,look}.json`, preserving cue/content IDs, references and existing steps; retain already-correct EN waiting-time meaning.
- [ ] 2.4 Apply exercise findings 034–041 in `exercises/{mat,stay,wait}.json`; 036 describes the currently trained approach rather than adding a new command-only stage. Record EN alignment.
- [ ] 2.5 Apply troubleshooting findings 042–048 in `src/content/data/mistakes/{come,drop,leave,stay}.json`; keep professional referral, avoid unsafe item-return advice and preserve all links. Record EN alignment.
- [ ] 2.6 Apply behaviour findings 049–063 in `src/content/data/behaviour/{alone,bark-door,bark-window,bed,bolting,jumping}.json`. Preserve urgent-first presentation and distinguish distress, guarding and safe training advice. Record EN alignment.
- [ ] 2.7 Apply behaviour findings 064–080 in `behaviour/{mounting,nipping,noise,reactivity,stealing,traffic}.json`, including both nipping warning fields. Do not add medical claims or unapproved guidance; record EN alignment.
- [ ] 2.8 Apply care findings 081–090 in `src/content/data/care/{care-bath,care-checks,care-coat}.json`. Preserve voluntary participation and vet-first stop-lines; record EN alignment.
- [ ] 2.9 Apply care findings 091–100 in `care/{care-nails,care-paw-rinse}.json`. No new nail-cutting protocol, added stage or change to attempted-stage semantics; record EN alignment.
- [ ] 2.10 Apply care findings 101–110 in `care/{care-teeth,care-towel}.json`; implement 106's approved brush-familiarization setup in the existing stage without claiming it was introduced in stage 1. Record EN alignment.
- [ ] 2.11 Apply nosework/environment findings 111–123 in `src/content/data/nosework/` and `environments.json`, preserving all activity/environment IDs, ordering, minutes and level counts. Record EN alignment.
- [ ] 2.12 Apply the explicit replacements in 125–126 and typography scope of 124. Normalize only Polish quotation pairs throughout user-facing copy; do not perform unlisted payment-metaphor rewrites or blanket snapping-to-biting substitutions. Check overlap with earlier sentence replacements to avoid reintroducing old text.

## 3. Cross-runtime integration and regression coverage

- [ ] 3.1 Mirror every edited content source byte-for-byte to its existing `Pettrainer/Resources/Content/` counterpart; compare parsed nonlocalized structure against the starting content to prove IDs, ordinals, counts, links, gear and environment ordering remain unchanged.
- [ ] 3.2 After agreeing shared-file ownership, record after-hashes and audit IDs in `approved-content-delta.md` and update only changed entries/comments in `PettrainerTests/ContentChecksums.swift`. Keep the frozen migration baseline unchanged and keep checksum assertions enabled. Accurately describe current-vs-historical expectations in the nearby checksum test if its wording requires it.
- [ ] 3.3 Add focused assertions to nearby content/i18n tests for high-risk accepted wording (look timing, drop/mat criteria, nipping referrals, GPS limits, teeth setup, paper ingestion, care attempted labels), valid interpolation and Polish quotes. Verify actual native values rather than replacing meaningful assertions with snapshots of arbitrary current text.

## 4. Delegation Plan

Planner owns these OpenSpec artifacts only. Independent plan/final review belongs to `reviewer` (GPT-6.1 Sol). All implementation tasks belong to `build` through `/opsx-apply correct-approved-polish-copy` (Flash Next); no bridge or recursive implementer delegation is needed.

Use sequential small batches in task order: UI → exercises → troubleshooting → behaviour → care → nosework/common fixes → mirrored resources/checksums/tests. This avoids overlapping writes in shared String Catalog, mirrored resources and checksum fixtures while another feature is active. Do not delegate further. Return changed files, precise checks and open issues after each implementation batch. A completed artifact or a failed reviewer launch is not a passed gate.

## 5. Verification and final review

- [ ] 5.1 Activate Node v22.22.3 from `.nvmrc`; run targeted `npx jest src/content/load.test.ts src/content/schema.test.ts src/content/schema/behaviour.test.ts src/content/schema/care.test.ts src/i18n/i18n.test.ts --runInBand` and `npm run typecheck`. Run any newly added focused test files explicitly; do not run the whole suite by default.
- [ ] 5.2 Run `npx jest src/domain/verdict.test.ts --runInBand`; review its coverage of hit counts 0–5, cancellation and incomplete sets without changing the domain. Verify the scoped diff does not touch persistence/progress/session logic, IDs or historical records; record any coverage limitation rather than inventing evidence.
- [ ] 5.3 Verify source/native byte parity for every content file and unchanged nonlocalized structure, all 126 completion-ledger rows, PL/EN semantic review for edited fields, placeholder validity, and immutable historical baseline. Every unavailable/conflicting audit row remains incomplete.
- [ ] 5.4 Discover an installed simulator with `xcodebuild -project Pettrainer.xcodeproj -scheme Pettrainer -showdestinations`; run targeted `ContentLoaderTests`, `StringsTableTests`, `CareContentTests` and any changed content/localization tests via the existing scheme with `-only-testing:PettrainerTests/<class>` and the verified destination. Do not infer native correctness from Jest alone.
- [ ] 5.5 Check changed states at phone size in PL and EN: catalogue level counts, long progress/place-change labels, verdict explanation, look/drop/mat instructions, behaviour warnings and care labels/stages. Check large text and offline bundled-content access; identify simulator versus physical-device evidence explicitly.
- [ ] 5.6 Run `openspec validate correct-approved-polish-copy --strict`. Request independent final `reviewer` assessment of the scoped copy/test diff and evidence. Present NEW findings with stable IDs for user selection; do not silently implement them. Report exactly what passed, failed or was not checked.
- [ ] 5.7 Before a separately requested archive, write `learnings.md`, propose only verified reusable memory updates for approval, and follow reflection/spec-sync/CLI archive procedure. Do not archive this change merely because copy was edited.
