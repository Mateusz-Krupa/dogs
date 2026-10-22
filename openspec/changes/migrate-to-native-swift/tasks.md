## 1. Review and implementation gates

- [x] 1.1 Run independent read-only `reviewer` plan review of all artifacts against current sources; present findings with stable numeric IDs and ask which IDs to address. Record outcome in notes.md; do not apply unselected findings.
- [x] 1.2 Obtain explicit user approval of the resulting proposal/specs/design/tasks before implementation. Start only through `/opsx-apply migrate-to-native-swift` selecting Flash Next; report unavailable routing rather than substitute another model.

## 2. Baseline and native skeleton

- [x] 2.1 Capture source commit and parity manifest under this change: 41 JSON paths/checksums, entry order/IDs, environment count/order, locale keys/interpolations, diagram bindings, SQL seed mapping, all user actions/states, and (F-4) inline bilingual feature-screen copy with disclosure states — the session "About this exercise" block, per-mistake expand/collapse, default dog label and bar text. Inspect actual deployed storage metadata without reading personal data; pause if legacy storage needs a compatibility design.
- [x] 2.2 Activate Node v22.22.3 before baseline checks. Run targeted Jest tests for verdict, progression, setMachine, schema/load/environments, behaviour and localization plus `npm run typecheck`. Capture catalogue/session/nosework/problem reference states in PL/EN; report unavailable runtime capture honestly.
- [x] 2.3 Create `Pettrainer.xcodeproj`, shared `Pettrainer` scheme, app/unit/UI test targets and folders from design.md. Keep iOS 16.4, bundle ID and iPhone/iPad support. Preserve icons/privacy declarations and relevant entitlements; verify installed simulator destinations with `xcodebuild -showdestinations` and smoke-build an empty native root.

## 3. Pure domain and content contracts

- [x] 3.1 Port `Domain/Verdict.swift` and `SetState.swift`; XCTest all hit counts 0–5, cancelled, 0–4 unfinished reps, decided-but-incomplete sets, sixth-rep prevention, empty undo and fifth-rep undo.
- [x] 3.2 Port `Domain/Progression.swift`; test every environment adjacency, step bounds, harder-entry ceil(0.6 * count), easier rollover, one-step ladders, fully generalized boundaries and invalid inputs.
- [x] 3.3 Add typed content-family models, ordered manifest and loader under `Content/`; copy all 41 JSONs to native resources and assert byte checksums, catalogue order, full environment list, and preserved IDs against baseline.
- [x] 3.4 Port validators in family-sized files and `ContentTests`: exercise ladders/optional fields, duplicate IDs, prerequisites/references, PL/EN presence, environment ordering, mistakes, nosework, welfare cards, gear/pose/motion values. Test errors name source/field.

## 4. SQLite and durable progress

- [x] 4.1 Implement serialized `SQLiteDatabase` with bound statements and `MigrationRunner`; port immutable initial migration and seed stable content IDs. Test empty install, prior-v1 upgrade with seeded raw history, rerun idempotence, foreign keys, rollback and newer-version refusal using real temporary SQLite files.
- [x] 4.2 Add numbered native migration(s) for explicit lifecycle, current positions/per-context current progress, session-linked applied-choice idempotency and per-dog nosework progress. Specify columns/constraints in notes before coding; implement the F-3 legacy classification table (5 reps with/without `ended_at`→completed, 0–4 with→abandoned, 0–4 null→active with only latest active per dog × context) and test fixtures for every combination plus structurally inconsistent rows; existing IDs/reps/mastery remain unchanged and historical references survive content refresh.
- [x] 4.3 Implement `ProgressRepository`/`NoseworkRepository` with idempotent default dog and explicit dog IDs. Test two dogs × two exercises × two environments, current versus historical mastery, down/up moves, and unscored nosework restart persistence. Per F-2, mastery increases only on push 5/5 at that step: test final-step entry without training ≠ mastered, owner-chosen advancement after stick/drop earns nothing, and a later drop never erases earned mastery.
- [x] 4.4 Implement `SessionRepository`: commit-before-ack reps/undo, atomic fifth-rep completion and fifth-rep reopening, duplicate-safe owner choice with lazily created successor set (F-1), and abandonment. Test failed writes, double taps/retries, resumed partial sets, no persisted verdicts, no post-choice historical undo, and kill/relaunch immediately after the fifth rep AND immediately after a committed choice.
- [x] 4.5 Wire a stable Application Support database path, localized recovery errors and resume/abandon presentation; recovery surfaces both active sets and completed-awaiting-choice sets (F-1). Verify launch twice, failed/corrupt/newer database without reset, and committed-state/UI consistency after injected failures.

## 5. Native illustrations and localization

- [x] 5.1 Implement `UI/Theme.swift`, shared controls and native PL/EN String Catalog with matching keys/interpolation and Polish fallback; map every F-4 inline feature-screen string from the parity manifest into the catalog. Test empty/unsupported/preferred language resolution and missing-key prevention.
- [x] 5.2 Port dog poses and equipment drawings into focused `UI/Illustrations/` files; compare every supported variant at the original logical coordinates and phone size.
- [x] 5.3 Port step diagrams and lure/empty-hand/verbal stage policy, including per-step pose/motion/sound overrides. Verify each binding against the baseline inventory; preserve still diagrams without hands or animation.
- [x] 5.4 Port setup and problem scenes in separately focused files; capture visual checks for every scene family and label in PL/EN.

## 6. Native feature integration

- [x] 6.1 Implement `Features/Catalogue/` with focused cards/sections, current recommendation, environment/context progress, advisory prerequisites and links to every content family. Verify all items open offline without gating.
- [x] 6.2 Implement `Features/Session/` using pure domain + repositories: structured setup/repetition/note, criterion, five rep controls/undo, recommendation/owner choices, environment-change explanation, resume and error states, and the existing "About this exercise" plus per-mistake expand/collapse disclosures (F-4). Verify content/motion matches every step and thumb controls remain available.
- [x] 6.3 Implement `Features/Nosework/` with level selection, setup scene and durable participation completion without hit/miss scoring; test restart and highest-level retention.
- [x] 6.4 Implement `Features/Problems/` with PL/EN section parity, professional stop-lines, illustrations and related-exercise navigation; test every red-flag family and unrestricted access.
- [x] 6.5 Complete `App/RootView.swift` and route enum, localized default dog label and storage composition. Verify back/re-entry does not silently lose partial sessions; test phone/iPad layouts, VoiceOver labels, Dynamic Type and minimum touch targets.
- [x] 6.6 Behaviour problem list rows show their scene thumbnail (user request 2026-10-22; scenes already exist for all 10 issues)
- [x] 6.7 Two new behaviour cards: mounting on leg + sleeping in the bed (user request 2026-10-22) — content JSON (PL/EN), manifest, checksums, scenes

## 7. Delegation Plan

- [x] 7.1 At apply start, report bounded Flash Next assignments and owned paths. Sequence project → domain/content → persistence → illustrations → feature integration. Once shared contracts exist, `Data/` and `UI/Illustrations/` may be separate disjoint assignments; one owner integrates project registrations/navigation/locales. No overlapping writes or subagent redelegation.
- [x] 7.2 Require each assignment to return changed files, exact checks/results and open issues. Planner/reviewer remain GPT-6.1 Sol; implementer remains Flash Next. Keep notes.md updated and all task checkboxes unchecked until relevant code and checks pass.

## 8. Verification and pre-cleanup approval

- [x] 8.1 Run targeted XCTest groups via `xcodebuild -project Pettrainer.xcodeproj -scheme Pettrainer -destination '<verified simulator destination>' test -only-testing:PettrainerTests/<relevant test class>`; record actual classes/destinations. Run native UI smoke tests for the four feature flows and validate every manifest/resource binding. Do not invent successful checks or rely on JS tests as Swift evidence.
- [ ] 8.2 Inspect empty/partial/complete/undo/resume/error states in PL/EN at phone size and on iPad, including every diagram family and welfare card. Record screenshot/parity checklist results and reviewed file-length exceptions.
- [ ] 8.3 On a physical device, verify airplane-mode core use, background/kill/relaunch, resume/abandon and failed-write handling. Test native build A → build B (new migration) without uninstall: assert exact synthetic raw-history/IDs/context state plus unfinished set survive. Separately test Expo → native update with same identity and no sandbox deletion; do not use personal data as fixtures.
- [x] 8.4 Verify Release build/archive with authorized signing, matching app identity and entitlements. Distribution/submission is not authorized by this task; missing device/signing access blocks cutover approval and is reported.
- [ ] 8.5 Run independent reviewer pre-cleanup parity/data-safety review. Present numbered findings; ask which IDs to address, implement only selected fixes, rerun affected checks and record explicit user cleanup approval with an exact deletion allowlist.

## 9. Retire JS and verify native-only checkout

- [ ] 9.1 Inventory deletion allowlist: `App.tsx`, `index.ts`, old `src/` only after native resource/test parity, JS manifests/lockfile, TypeScript config, Expo `app.json`/`eas.json`, generated Expo `ios/` project/workspace/Pod integration and proven Expo-only assets. Remove tracked obsolete files only after gate 8.5; do not broadly delete untracked directories, build output, secrets, OpenSpec or agent tooling. Local `node_modules`/Pods cache cleanup requires explicit path approval, not blanket recursive deletion.
- [ ] 9.2 Update stack-specific OpenSpec config/workflow to native paths/checks without weakening domain/welfare/routing rules. Obtain an authorized configuration-edit context for AGENTS/agent integration instructions; if prohibited, report the blocker rather than editing them from the planner or silently leaving misleading requirements. Preserve OpenSpec CLI tooling independently of app npm dependencies.
- [ ] 9.3 From a fresh native build directory, build/test the shared scheme without npm/Metro/Pods; inspect built product and project references for obsolete runtime/resources, compare native JSON checksums with captured baseline, and run `openspec validate migrate-to-native-swift --strict`.

## 10. Final review and archival handoff

- [ ] 10.1 Obtain final independent reviewer diff review for scope, domain rules, data preservation, localization, welfare, focused files and removal completeness. Present stable numbered findings and implement only user-selected fixes, with rerun evidence.
- [ ] 10.2 Report exact test/build/device results and blockers, changed/deleted files, native run/archive instructions and supported rollback limitations. Do not claim TestFlight submission or device checks without running them.
- [ ] 10.3 Before requested archive, write learnings.md and propose durable memory operations using workflow.md; ask for memory approval, then run CLI archive/spec sync only after the separate archive decision. Do not promote guesses or empty-memory retrieval noise.
