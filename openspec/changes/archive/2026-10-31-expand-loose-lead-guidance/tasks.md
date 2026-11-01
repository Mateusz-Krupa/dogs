## 1. Approval gates

- [x] 1.1 Obtain independent `reviewer` assessment of proposal, design, spec and editorial contract; record stable numeric findings in `review.md` without editing application files.
- [x] 1.2 Present findings and obtain user selection before any review-driven amendments; obtain explicit approval of the final scope/copy before implementation through `/opsx-apply expand-loose-lead-guidance`.

## 2. Delegation Plan

Sequential work is intentional: bilingual copy, tests and hash values share one approval boundary and depend on each other. No parallel writers or further subdelegation.

- [x] 2.1 Planner (GPT-6.1 Sol) owns OpenSpec only; after approval hand off to the `/opsx-apply` build agent (Flash Next), which retrieves memory and inspects current dirty-file diffs before editing.
- [x] 2.2 Flash Next owns only the two loose-lead JSON files, the puppy foundation JSON, affected entries in `PettrainerTests/ContentChecksums.swift`, focused additions in existing `ContentLoaderTests.swift`/`ContentValidatorTests.swift` and the narrow `PuppyContentTests` updates named by R-3, and change-local evidence. Reviewer (GPT-6.1 Sol) independently reviews the final scoped diff; no recursive implementation agent or unrelated fixes.

## 3. Bilingual content

- [x] 3.1 Record current-working-tree before hashes and ledger values for the three resources in `content-review.md`; preserve pre-existing modifications and do not rebaseline unrelated content.
- [x] 3.2 Update description, first-step preparation/note, second-step safety note and fourth-step sniffing instruction/note in `exercises-leash.json` to match the approved editorial contract in PL/EN; preserve stable identity, ordinals, criteria and illustration fields.
- [x] 3.3 Revise the two existing cards and add the three specified cards in `mistakes-leash.json`, with equivalent PL/EN causes, actions and health/fear safeguards; record final wording/touched fields in `content-review.md`.
- [x] 3.4 Extend `puppy-puppy-first-exercises.json` with the R-2-reviewed floor-scavenging copy: ingestion/guarding escalation ahead of practice, safe-props and no-punish avoidance items, home management plus `leave`/`drop` trade actions, generalization and non-food-ingestion observations, `practices` extended with `leave`/`drop`, and evidence re-verified on 2026-10-29 with ≤5 sources; keep four foundations and unrelated guides byte-identical.
- [x] 3.5 Inspect the bilingual copy against sources and the specs, then update only the three affected checksum entries and record actual after hashes. Leave frozen migration baselines untouched.

## 4. Verification

- [x] 4.1 Add decoded-bundle assertions in existing content tests covering five bilingual loose-lead cards, equipment advice, safe sniffing/moving-on guidance, refusal/vet escalation and unchanged four-step identity/criteria; add puppy-guide decoded checks for leave-before-pickup versus drop-after-pickup, safe props, home→street difficulty, ingestion referral and guarding short-circuit; narrowly update `PuppyContentTests.swift` changed-guide date/link expectations while preserving other guides' assertions (R-3). Combine assertions with editorial review rather than treating keyword presence as proof of safe meaning.
- [x] 4.2 Verify an available simulator ID and run targeted `ContentLoaderTests`, `ContentValidatorTests`, `PuppyContentTests` and `PuppyGuideValidatorTests` with `xcodebuild -project Pettrainer.xcodeproj -scheme Pettrainer -destination 'platform=iOS Simulator,id=<verified-id>' -only-testing:PettrainerTests/ContentLoaderTests -only-testing:PettrainerTests/ContentValidatorTests -only-testing:PettrainerTests/PuppyContentTests -only-testing:PettrainerTests/PuppyGuideValidatorTests CODE_SIGNING_ALLOWED=NO test`. Record real results, blockers and pre-existing failures; do not broaden the checksum refresh to make tests pass.
- [x] 4.3 Inspect equipment text, all five expanded cards and the extended puppy foundation at phone size in PL/EN on a simulator, offline, without scoring a repetition; confirm readable layout, resolving `leave`/`drop` links and unchanged displayed training criteria. Do not claim this verifies physical-device lifecycle/update preservation.
- [x] 4.4 Run `openspec validate expand-loose-lead-guidance --strict`; record the implementation-only file diff and checks in `notes.md`. Confirm no Domain/Data/session logic or database changes, no gating, and no new UI translation keys.

## 5. Final review, release and archive readiness

- [x] 5.1 Independent reviewer assesses final scoped content/test/hash diff for source support, PL/EN equivalence, welfare, scope and verification. Present stable numeric findings and wait for user selection before implementing any review fixes.
- [x] 5.2 Release gate (R-4): inventory the exact working-tree scope that a build would package, present it to the user for approval, and build/upload to TestFlight only afterwards via the documented archive → export → validate → upload pipeline in `DISTRIBUTION.md`; verify signing/build-number prerequisites without reading credential files, and report upload success separately from App Store Connect processing and tester availability.
- [x] 5.3 Report exactly what passed and what remains unchecked. When archive is requested, write `learnings.md`, propose durable memory operations and obtain memory approval per `openspec/workflow.md` before CLI archive/spec sync.
