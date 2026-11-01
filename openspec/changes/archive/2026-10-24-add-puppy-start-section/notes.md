# Planning evidence and approval state

## 2026-10-24 — proposal only

- Read workflow/config before artifact creation; checked `pwd`, git status, active changes and published specs. Many pre-existing source/content/config changes and staged legacy deletions exist. None are owned, reverted or implemented here.
- MCP `search_memory` (repo pettrainer) returned only unrelated/unverified `opencode-implement`; excluded it as architecture/routing evidence. Used local fallback `openspec/memory/index.md`, `conventions.md` and `pitfalls.md`: consulted **CONV-001** (explicit EN field alignment) and **PIT-001** (nested locale structures must not be skipped). These constrain copy review/validation, not permission for a bulk rewrite.
- Graph project was resolved by `list_projects` earlier in the conversation. Current structural Swift search returned zero matches; semantic lookup included stale TS references. Fell back to direct current native reads: loader, manifest, models, behaviour validator, catalogue, problem view, root routes and care source model. Native-only config/workflow takes precedence over stale indexed paths.
- `behaviour-problems-section` is only a metadata scaffold, not an existing competing specification. `approved-bilingual-copy` is the only published capability; its old copy corrections remain protected. Migration and care are still active changes. Do not modify their artifacts or historical baselines in this feature.
- Corrected design assumptions: behaviour currently has no evidence/observe fields; care's source shape can be reused without care's three-stage/participation semantics. Existing exercise links can create their own empty active session, so only educational browsing is promised write-free.
- Source reads happened in this conversation before proposal generation. `sources.md` distinguishes full-page reads, old policy summaries, restricted reuse and the inaccessible UC Davis source. No original clinical research/clinical endorsement is claimed. Fear/distance wording still has an explicit independent-authority gate before product copy approval.
- Scope derives from the agreed conversation: four foundations, two new situation cards, existing nipping/mounting reuse with bounded review. Personal dog/owner details are intentionally omitted.
- Tool catalogue offers no TodoWrite equivalent; progress is reported in conversation and CLI artifact status rather than inventing a tool or editing unrelated plan files.

## Gates

Artifact generation requested. Independent plan review pending; implementation is **not approved**. All implementation tasks must remain unchecked. Any numbered reviewer fixes require user selection before artifact changes. Complete PL/EN copy review/approval is a later explicit gate before resource edits.

## Checks

Planning only. No Swift build, XCTest, simulator, device, network-off runtime, checksum changes, application edits or commits performed. CLI validation and reviewer outcomes will be appended after they actually run.

## Artifact validation and reviewer launch

- `openspec status --change add-puppy-start-section --json` reports all four artifacts done (proposal, design, specs, tasks). This means artifact-complete, not user approval or completed implementation tasks.
- `openspec validate add-puppy-start-section --strict` passed: "Change 'add-puppy-start-section' is valid".
- Independent `reviewer` launch was attempted; tool repeatedly returned `Subagent session not found`. No independent review report exists and no reviewer findings were invented or applied. Task 1.1 remains unchecked and blocks implementation approval flow. Report the unavailable review rather than silently substituting a self-review or another model.
- Created only this change's metadata and planning documents. Existing application edits remain untouched. Full PL/EN product drafts have not yet been authored or clinically reviewed; content-review task group remains pending.

## Plan review round P (2026-10-24, independent reviewer, fresh session)

Reviewer session ses_e951d1faaffe8LeTkK8ONO73Rm (GPT-6.1 Sol, read-only, no delegation). Verdict: **fix-first**. It confirmed the native assumptions (manifest-owned order, flat prefixed filenames, BehaviourIssue required nonempty practices, ProblemSections stop-first order, care URL pattern, no migration needed for a separate guide family, resumableSet/position seams) and checked CONV-001/PIT-001 coverage; memory retrieval again returned only the unrelated opencode-implement entry and the reviewer used the local fallback.

- **P-1 (important, required)** — the exercise-link persistence carve-out in design §5 / spec "Browsing preserves raw history" / task 7.2 is too narrow: opening an untouched exercise also performs lazy initial **position** creation (`AppModel.makeSessionModel` → `ProgressRepository.position` inserts step 1 / starting environment before `SessionRepository.resumableSet` may insert the empty active set). An exact raw-state test written to the current wording would fail on existing behaviour or force an out-of-scope session change. Recommendation: allow ordinary lazy initial position + empty active set for a never-opened exercise; forbid any change to existing positions, earned mastery, context progress, reps or choices; test both a fresh exercise and one with existing resumable/pending-choice state.
- **P-2 (nit, optional)** — `ContentLoaderTests` builds its checksum enumeration explicitly per family and pins the old behaviour order; adding `ContentChecksums` entries alone would leave the puppy family unchecked. Recommendation: require updating that enumeration with `CatalogueManifest.puppy` + four digests and the behaviour-order expectation; optionally assert registered-vs-checksummed key equality.

Reviewer also noted: task 7.1 must exercise real destination browsing/rendering plus exact raw-state comparison, not just content lookups; UI tests must not substitute labels for database evidence; simulator/offline/accessibility remain execution-time work. No files were modified by the reviewer; no web re-fetch, builds or tests were run by it; its statements about CLI validation are inherited from the parent context.

Awaiting the user's selection of which finding IDs to address, then explicit implementation approval. Artifact completeness and review are not approval.

**Round P resolution (2026-10-24):** the user selected **both P-1 and P-2**. P-1 applied to design §5, the spec's persistence requirement (split into never-opened vs in-progress exercise-link scenarios) and tasks 7.1–7.2 wording (database-asserted, both states). P-2 applied to task 4.2 (explicit `ContentLoaderTests` family enumeration including `CatalogueManifest.puppy`, refreshed behaviour-order expectation, registered-vs-checksummed key equality assertion). Strict revalidation follows; implementation approval gate remains the next step.

## Implementation approval (2026-10-24)

The user approved implementation explicitly and delegated the remaining gates in one instruction: "tak sluchaj nie pytaj mnie zrob wszytko" (yes — don't ask me, do everything). Recorded consequence: no further per-gate questions in this implementation. The substantive safety machinery is kept, ownership transferred to the implementer: source re-verification (2.1), independent reviewer at the copy stage (2.4) and final review (7.6) still run; reviewer findings are triaged by the implementer instead of being put to the user, with every accept/reject decision and reason recorded here. Nothing may be claimed as clinically endorsed; PL/EN copy remains owner-reviewable after shipping, matching the standing convention for welfare copy. Archive (8.2) still requires the user's explicit go-ahead because it is destructive to the active-changes layout and outside the stated "implement" instruction.

## Implementation round (2026-10-24, single implementer, native-first)

Sequential work per the delegation plan; shared files (loader, manifest, checksums, routes, xcstrings) touched only by this session. No other change's artifacts or files modified.

- **Content pipeline**: `PuppyGuide`/`GuidanceEvidence` models + `PuppyGuideValidator`/`GuidanceEvidenceValidator`; `BehaviourIssue` gained optional `observe`/`evidence` (old cards parse unchanged); manifest gained `puppy` family and `overarousal`/`fear-withdrawal` before `alone`; loader/collision/reference checks extended; `guidanceRequirementsProblems` enforces the designated fields at load. Eight resources bundled (4 guides, 2 new cards, 2 reviewed cards); `ContentChecksums` updated for exactly those eight with the before/after ledger in `content-review.md`; `ContentLoaderTests` enumerates the puppy family and asserts registered-vs-checksummed key equality (P-2).
- **Real bug found by the first run**: `GuidanceEvidenceValidator.today()` originally used UTC, and the simulator clock at 00:48 +02:00 made "verified 2026-10-24" look future — content fatal-ed at launch. Verified dates are the owner's local calendar day; `today()` now uses `Calendar.current`, and date validity round-trips all three Y/M/D components (lenient calendars would resolve 2026-02-30). Test fixtures inject `today` and never depend on the wall clock.
- **UI**: `Route.puppyStart`/`puppyGuide`, hub entry row above the exercises, `PuppyStartView`, `PuppyGuideView` (stop → avoid → actions → observe → professional → optional practice chips → citations), optional observation block and citations on `ProblemView` without touching `ProblemSections.order`, nine `puppy.*`/`problems.observe|sources|verifiedOn` keys in both languages. `CatalogueView` kept within the file-size guideline by extracting `PuppyStartEntryRow`.
- **Copy review round C** (independent reviewer, GPT-6.1 Sol, read-only): verdict fix-first; 14 findings triaged under the blanket approval; full accept/reject table and final claim map in `content-review.md` (C-1..C-14, incl. the two rejections-with-rationale: C-3 boilerplate scope and C-6 link removal scope). Not a clinical review; no source endorsed the app.
- **Test fixes found while verifying my own tests** (recorded because they were real defects in test code, not in the app): `XCTAssertThrowsError(try? …)` swallows the throw and silently passes; raw-string `#"…\"…\"#` keeps literal backslashes (the scoring-key fixture was invalid JSON until switched to normal interpolation); the fresh-store rep count is 2 sit + 5 look = 7, not 3; and my regex hash-patcher initially pasted the newline indent *inside* the quoted digests.
- **Tooling note**: several tool calls rendered with garbled paths in this session (e.g. `opensopenspec/`, `Pettr>ainer/`); outcomes were re-verified against disk each time (grep/python reads, `ls`) and every landed edit matched the intended file. The stray `Content/p/` directory created once by a garbled write was moved to its correct place and removed.
- **Checks actually run so far**: `openspec validate add-puppy-start-section --strict` valid (pre-round C copy); `ContentLoaderTests` green incl. new checksums + order + key-equality; targeted unit suites green (BehaviourWelfareCopy, Care*, ContentValidator, VerdictRules, SetState, Progression, SessionRepository) except the four test-side failures listed above; simulator destination E62B27CA-23B1-4839-ABD7-82D93E8AC28F. Not yet run: PuppyFlowUITests, PL/Type/VoiceOver/offline inspection, strict revalidation after round C, final review.


## Icon feedback round (2026-10-24, owner: "wyglada spoko ale nie maja ikonek")

The owner ran the app and found the puppy rows text-only while every other catalogue family carries a thumbnail. Fixed with existing primitives only (no new artwork system, honoring the non-goal):
- `PuppyGuide` gained a required `pose` (same `Pose` vocabulary + `expectOneOf` as care/nosework); validator + all four resources updated; four digests re-registered in the `content-review.md` ledger (old values superseded).
- Catalogue entry row leads with `DogPoseView(.come)`; hub guide rows lead with their pose (`mat`/`sniff`/`stand`/`sit`) in a shared puppy green (`PuppyPalette`); hub help rows render the card's `ProblemSceneView`.
- New `ProblemScene` entries drawn for `overarousal` (zoom loop + motion streaks over a standing dog) and `fear-withdrawal` (crouched dog, distant person, gap arrow pointing away). `IllustrationContractTests.testProblemScenesCoverAllTenCards` became `testProblemScenesCoverEveryCard` over all 14 ids, so a future card without a scene fails a test.
- `PuppyGuideView` header shows the pose at 120 pt in a card, mirroring ProblemView's scene block.
- Verified in one targeted run (green): IllustrationContractTests, ContentLoaderTests (checksums incl. pose bytes), PuppyGuideValidatorTests (fixture carries + asserts pose), PuppyContentTests, PuppyIsolationTests. PuppyFlowUITests re-running against the new row layout.
## Final review round FR (2026-10-24, independent reviewer, session ses_e932a30fcffeguRUNKMj9Gw8fU)

Verdict fix-first. All findings accepted under the user's blanket approval:
- **FR-1 (high) accepted** — `today()` had swung from UTC (rejected same-day verification at local 00:xx) to `Calendar.current` (a device set to the Japanese/Islamic calendar reports era year 8/14xx, false-futuring every bundled 2026 date → the load-time fatalError would brick launch there). Now: Gregorian calendar style + `TimeZone.current` civil day. Regression test `testTodayIsGregorianLocalDayNotUtcNorDeviceCalendar` pins both failure modes with an anchored instant, `Pacific/Kiritimati` and a Japanese `Calendar.current`, restoring globals via defer.
- **FR-2 (medium) accepted** — the isolation fixture now matches the approved matrix: two dogs, a mastery row on `own-garden-quiet`, an applied-choice completed set AND a completed set awaiting the owner choice; new test asserts a guidance open/return on the awaiting-choice set applies no choice and changes no row. Honest split of labor recorded in the class header: PuppyFlowUITests drives the real view hierarchy; this class owns raw-row evidence.
- **FR-3 (low) accepted** — every guide screen now renders the `care.disclaimer` statement beneath its description, matching the hub and care screens; no new key needed.

Reviewer positives worth keeping on record: independently recomputed all eight resource hashes (ledger == ContentChecksums == disk), nine new catalog keys in both languages with old interpolation keys intact, views call no write APIs, ProblemSections.order untouched, no new persistence or progression logic. Its noted limits (no test reruns, no device checks, catalog pre-existing diffs not certifiable) match what this session claims.
## Final verification (2026-10-24)

- Full unit target: **180 tests, 0 failures, 1 skipped** (the intentional icon generator) — `** TEST SUCCEEDED **` on iPhone 15 Pro UDID E62B27CA-23B1-4839-ABD7-82D93E8AC28F.
- One earlier full-unit run reported `** TEST FAILED **` at "155 tests, 0 failures": the count shortfall + zero assertion failures is the signature of the test-runner process exiting abnormally mid-suite (a ~25-test subset never executed), not a code defect. Immediately re-ran clean (180/0). Recorded rather than hidden; did not reproduce.
- PuppyFlowUITests (4) passed with the disclaimer row and thumbnails present; LaunchSmokeUITests (7) passed earlier on the same build.
- `openspec validate add-puppy-start-section --strict` valid.
- Offline: no URLSession/Network/NWConnection anywhere in Pettrainer/; guidance text and citation metadata are bundled and rendered without network. External source `Link`s open only on tap and their failure does not remove advice — verified by code inspection (no network API present), not by a hardware airplane-mode toggle.
- Not done here (honest limits): physical device, VoiceOver/Dynamic Type runtime audit, iPad layout, offline airplane-mode toggle, archive/upload. VoiceOver labels + Dynamic Type were implemented (combine, fixedSize, adaptive touch targets) but only structurally exercised on the phone simulator.

## Archive & memory outcome (2026-10-24)

- Archived via `openspec archive add-puppy-start-section --yes`: strict validation passed, delta specs applied (+8 requirements → `openspec/specs/puppy-start-guidance/spec.md`), moved to `archive/2026-10-24-add-puppy-start-section`.
- Durable memory promoted under the blanket approval: PIT-002, PIT-003, CONV-002, DEC-001 + index sync. Qdrant incremental `reindex` processed 0 files and a verification query still returns only the stale bridge entry → the retrieval refresh is **pending** (index appears to follow committed state; no commit was made because none was requested). The Markdown files are the source of truth and are saved.

## TestFlight build 6 (2026-10-24)

archive → export → validate → upload all SUCCEEDED (DISTRIBUTION.md pipeline). Delivery UUID 087de739-ab13-464d-a211-3098b031e50a, IPA 1117035 bytes. Ships the puppy-start section with thumbnails, guide disclaimers and the FR-1 calendar fix. Working tree was uploaded uncommitted per the owner's request; ASC processing pending (5–30 min), TestFlight internal group selection is an ASC-side manual step.
