# Notes

- 2026-10-29: Retrieved DEC-001 and PIT-001; verified the existing JSON is nested PL/EN and the session view already renders variable-length troubleshooting lists. CONV-002 is background only: no new navigation is planned. A returned legacy implementation-bridge memory is not applicable to this OpenCode planner; current workflow routing takes precedence.
- Existing worktree has many unrelated staged/unstaged changes, including `exercises-leash.json`, tests and checksum ledger. None were reset or edited during planning. Apply must preserve them.
- Examined active changes and specs. `exercise-content-structured-copy-and-diagrams` has metadata only; this proposal is narrowly scoped, not a rewrite of that change.
- Research supports avoiding retractable leads for loose-lead teaching, not the absolute statement “always pulls”: distinguish unlocked reel tension from a locked lead with slack. No quantitative injury claim is needed.
- Only OpenSpec artifacts have been created. No application implementation, simulator check or XCTest run has taken place.
- `openspec validate expand-loose-lead-guidance --strict` passed; CLI reports all four planning artifacts complete. Independent reviewer invocation failed with `Subagent session not found`; no review was performed and gate 1.1 remains open. No substitute review/model or review-driven application changes were made.
- User approved the proposed content scope and requested implementation plus deployment. This does not waive the pending independent-review gate. A renewed reviewer invocation failed with the same tool error. Implementation must be handed off through `/opsx-apply expand-loose-lead-guidance` to Flash Next; this planner has not edited application files or deployed a build. Deployment destination remains to be clarified; repository history includes TestFlight delivery.
- User subsequently confirmed TestFlight, requested guidance for eating dropped/found items at home and outdoors, and suggested the puppy section. See `puppy-scope-addendum.md`: reuse `puppy-first-exercises` plus canonical `leave`/`drop`, keep four foundations, and reconcile the extended scope into the implementation artifacts before apply. Consulted CONV-002 and DEC-001. Full Dogs Trust training pages were read; additional veterinary source verification remains required for medical claims. No application changes or deployment performed.

## Implementation pass (Flash Next, 2026-10-30)

- Reviewer gate ran on `openai/gpt-6.1-sol`; findings R-1–R-4 recorded in `review.md`, user
  selected all four. Reconciliation landed in proposal/design/tasks plus a second delta-spec
  capability (`specs/puppy-scavenging-guidance/spec.md`); `openspec/specs/puppy-start-guidance/`
  is untouched, four foundations and their IDs preserved.
- Implementation-only application diff: `exercises-leash.json`, `mistakes-leash.json`,
  `puppy-puppy-first-exercises.json`, three `ContentChecksums` entries, additions in
  `ContentLoaderTests.swift` and narrow expectations in `PuppyContentTests.swift`. No
  Domain/Data/session/DB code, no Localizable.xcstrings keys, no Xcode project change, no
  migration, no content gating. Verdict thresholds, per-context progress and raw history are
  untouched by construction (nothing outside bundled JSON + tests changed).
- Ledger discipline: before/after SHA-256 for exactly the three resources in
  `content-review.md`; full 56-entry ledger rescanned against the working tree — zero drift,
  unrelated resources not rebaselined; frozen `migrate-to-native-swift` baseline untouched.
- Copy-integrity decision during implementation: two draft claims were dropped rather than
  shipped unsupported (DIY vomiting instruction; the "afraid dog swallows on the run"
  mechanism). Evidence list finalised at the validator's 5-source cap by citing the RSPCA
  chewing page (load-bearing for two shipped claims) and dropping the Dogs Trust stealing
  page (read, but no shipped claim depends on it). Recorded in `content-review.md`.
- Harness traps hit and cleared: three tool calls carried garbled absolute paths
  (`/Users/mateuszkrup/Users/...`, `mateuszkrupaupa`, `/Users/m/mateuszkrupa/...`) and one
  carried a duplicated fragment inside `oldString`. Each was verified against the real file
  afterwards instead of being trusted; no stray paths or duplicated text exist in the tree
  (`grep` for `2026-2026`, `mateuszkrupaUsers`, `/Users/m/` → none). `plutil -lint` rejects
  these content JSON files even when untouched — use a JSON parser for syntax checks here.
- Release inventory (R-4): tree vs HEAD is 232 files (94 M / 138 D / 20 untracked), so a
  build would package unrelated in-flight work too; the exact list must be approved before
  archive/export/upload. Pipeline documented in `DISTRIBUTION.md` (API key referenced, never
  read here).

## Verification evidence (2026-10-30)

- Targeted unit run (iPhone 16e simulator 4FE22130-A159-4843-997B-FE6132A73C73,
  CODE_SIGNING_ALLOWED=NO): ContentLoaderTests 10, ContentValidatorTests 16,
  PuppyContentTests 14, PuppyGuideValidatorTests 18 = 58 tests, 0 failures.
- The first run of that set failed one assertion (PuppyContentTests:120) against a stale
  incremental test binary; after xcodebuild clean the same class ran 14/14 green. The
  failure was the harness, not the copy, and the assertion now dumps the runtime list.
- Task 4.3 used a temporary UI-test file (TempLooseLeadInspectionUITests: 2 passes, 18
  phone-sized attachments, Got it/Missed never tapped), deleted afterwards with no residue.
  It reached: loose-lead step 1 with the two new setup lines and the extended note, the
  expanded About paragraph, all five troubleshooting cards open in PL, the puppy STOP block
  carrying the new ingestion sentence, and the leave it/drop it chips with the 5-source
  block in EN. No truncation; criteria unchanged ("Trzy kroki z luźną smyczą." / "Three
  steps with a loose lead.") and the bar stayed at 0 z 5 / Rep 0 of 5.
- Offline is structural rather than inferred from a screenshot: no URLSession, Network or
  Safari-services reference exists in Pettrainer/; citations render as bundled text.
  Device lifecycle and update preservation were NOT tested and are not claimed.
- openspec validate --strict passed. Full ledger rescan: 56 entries, 0 digest drift.
  plutil -lint rejects these content JSON files even untouched, so JSON syntax was checked
  with a parser instead.

## Final-review fixes and re-verification (2026-10-31)

- Implemented the user-selected F-1 (guarding short-circuit in `urgent`, PL+EN), F-2
  (safe practice toy returned / dangerous find never returned, PL+EN), F-3 (assertions
  rewritten to quote full safety clauses per locale, no `&&` across locales, before/after
  pickup order, toy-return, force ban, guarding) and the optional EN `avoid[3]` alignment.
- Proved nothing else drifted: a field-level comparison against the previously bundled copy
  showed exactly five changed fields (`urgent.pl/en`, `avoid.en[3]`, `actions.pl[4]/en[4]`).
- Puppy resource re-hashed to `6ab7bb8f813f18b03df10b33aa4d7826986fad8df4efbd8ed19e3e4c1b302975`;
  ledger + `ContentChecksums` updated, both leash entries re-verified unchanged. An
  intermediate ledger line had carried an uncomputed hash and was corrected to the real one.
- Re-ran after `xcodebuild clean`: ContentLoaderTests 10, ContentValidatorTests 16,
  PuppyContentTests 14, PuppyGuideValidatorTests 18 = **58 tests, 0 failures**, exit 0.
- Task 5.1 done: reviewer pass over the implementation diff produced F-1–F-3 + one optional
  item, user selected all, fixes applied and re-verified as above.
- Remaining before release: 5.2 R-4 release-tree approval + TestFlight pipeline, then 5.3.

## R-4 release gate (2026-10-31)

- Inventoried the tree a build would package and presented it as one question: this change
  owns 6 files, while the same build also carries 67 modified app/test/project files,
  131 staged deletions (the retired Expo/JS runtime) and 13 untracked app sources
  (whole `Features/Puppy/`, the other three puppy guides, new behaviour cards, puppy tests,
  `GuidanceEvidenceView`).
- Recorded why a "this change only" build is not achievable here: the puppy views and three
  of the four puppy guides are untracked, and `ContentChecksums` enumerates all 56 bundled
  resources, so building only the six files cannot compile or satisfy the ledger test.
- Version tuple is `1.0.0 (1)` from the uncommitted `project.pbxproj`, a new version line
  relative to TestFlight `0.1.0 (6)`.
- Keychain holds only an Apple Development identity today; no Apple Distribution identity,
  so archive relies on `-allowProvisioningUpdates` minting it, as in builds 2–6. The API key
  file exists at the documented path and was never read by tooling.
- User approved the whole-tree build for TestFlight (one question, answer: "Tak, whole-tree
  build"). Pipeline run and its real exit statuses are recorded below, not assumed.

## TestFlight release (2026-10-31)

Documented pipeline from `DISTRIBUTION.md`, executed from the approved whole-tree working
state with artifacts outside the repository (`…/T/opencode/looselead-release`):

| Step | Result |
| --- | --- |
| `xcodebuild archive` (`generic/platform=iOS`, `-allowProvisioningUpdates`) | **ARCHIVE SUCCEEDED** (exit 0); archive signed `Apple Development: treestram@gmail.com (E9LCPB5QJ5)` |
| `xcodebuild -exportArchive` (method `app-store-connect`, team `G5RD7F6C65`) | **EXPORT SUCCEEDED**; `Pettrainer.ipa` 1 121 280 bytes; app id `G5RD7F6C65.com.mateuszkrupa.pettrainer` |
| `altool --validate-app` | **VERIFY SUCCEEDED with no errors** |
| `altool --upload-app` | **UPLOAD SUCCEEDED with no errors** — Delivery UUID `4363ad62-fd23-4c6b-96e6-2b8fc0e6c2ad` |

- No credential file was read: the `.p8` was referenced by key ID only, opened by `altool`.
- Upload ≠ processing ≠ tester availability. App Store Connect needs ~5–30 min to process
  the binary, then an internal test group must be selected by hand; external groups need
  Beta App Review. None of that was performed or verified from here.
- No Apple Distribution identity existed in the keychain before the run; `-allowProvisioningUpdates`
  handled signing as in builds 2–6, and the export re-signed for App Store Connect.
- Physical-device behaviour (airplane mode, kill/relaunch, in-place update preserving real
  training data) remains **owner-attested only** — this session ran simulator checks and
  never installed or updated anything on the phone.
