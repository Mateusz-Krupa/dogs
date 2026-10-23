# Decision and evidence log

## 2026-10-22 — Initial planning artifacts only

- Read `AGENTS.md`, `openspec/config.yaml` and `openspec/workflow.md` first; verified repository anchor with `pwd` and checked git status before artifact creation. Existing untracked `behaviour-problems-section/` and `exercise-content-structured-copy-and-diagrams/` were preserved. No application, content JSON, dependency, agent configuration or other change's baseline was edited.
- Used CLI-generated spec-driven artifact instructions/status, plus live `migrate-to-native-swift` proposal/design/baseline conventions. `openspec/archive/` is absent; actual `openspec/changes/archive/` contains only `.gitkeep`. Therefore no completed archive shape was available to inspect; reflection/archive structure comes from `workflow.md`.
- Retrieval: project-scoped Qdrant memory returned an unrelated generic `opencode-implement` skill with stale routing, not useful pettrainer architecture. Do not apply its SDG/videofactory/Claude routing. Consulted **local fallback** `openspec/memory/index.md` and all five category files; they contain templates only. Memory impact: no relevant durable entry IDs retrieved. Current repository workflow/model routing takes precedence.
- Resolved graph project with `list_projects`, used `search_graph` for nosework/vocabulary/gear/navigation discovery; supplemented with direct reads for precise evidence. Qdrant intent-based search was requested scoped to pettrainer; direct source reads, not retrieved snippets, settled decisions.
- Honoured supplied independent review outcomes: **C-1** furthest stage tried, never mastery/detailed log; **C-2** dedicated schema with required PL/EN urgent/professional and stage stop-lines before instructions, no procedure-completion requirement; **C-3** canonical single authoring plus mechanical native mirror and explicitly reviewed additive migration baseline/checksum update. This plan does not claim a fresh reviewer run; parent must obtain artifact review and user selection/approval before apply.
- Verified `NoseworkRepository.swift` stores max ordinal, not a dated log. `Migrations.swift:177–183` has dog FK but no activity FK: namespaced care IDs can reuse existing participation storage with no new table/migration. Add care validation/facade and separate UI state; do not propagate completion vocabulary or swallowed write failures from existing nosework orchestration.
- Native resources are currently flat (`ContentResource` maps logical family/path to family-prefixed filename), so care mirror uses `care-care-*.json`; logical paths remain `care/care-*.json`. Avoid inventing a new bundle-directory loader.
- Verified native language menu exists, app-wide About does not in inspected catalogue/root routes, JS has no corresponding menu. Disclaimer key is reused at both section/routine surfaces plus native menu; no new About route. Full menu layout still needs device/simulator verification.
- Current migration baseline says 41 resources/10 behaviour cards while native manifest/resources now include two further behaviour cards. This is pre-existing drift, not authority to silently regenerate all checksums. Task 1.3 inventories it; task 6.1 requires reviewed additive provenance and preservation of old hashes. No cutover/JS deletion in care scope.
- `handling.json` still ends with tool contact without cutting. Keep bytes unchanged; care advice links to it without prerequisites/gating. Existing scored five-rep thresholds and dog/exercise/environment progress remain untouched.
- Source summaries were supplied by the parent; this subagent did not independently fetch source pages. Toothpaste evidence is a moved-page snippet and paw/road-salt evidence is practice/groomer level: both remain explicit pre-authoring gates, not verified clinical claims. Eye/oral/towel safety details also need authoritative confirmation before copy. No vet approval/endorsement is asserted.

## Approval state

Proposed; no application implementation approved or performed by this subagent. All implementation/review/verification tasks remain unchecked. Parent handles independent artifact review and user selection of any further numbered fixes, then explicit implementation approval. Apply only through `/opsx-apply add-hygiene-care-section` with Flash Next; planning/review remain GPT-6.1 Sol. No recursive delegation from this subagent.

## Validation / limitations

- OpenSpec CLI is available at `/opt/homebrew/bin/openspec`; `list`, `status` and artifact instructions ran successfully. After artifact creation, **`openspec validate add-hygiene-care-section --strict` passed** (“Change 'add-hygiene-care-section' is valid”). CLI status reports 4/4 artifacts complete; this is not implementation approval or task completion. Checklist contains 29 unchecked tasks and the spec has 10 requirements.
- Initial shell Node was v26.7.0, not the pinned v22.22.3. Sourcing nvm emitted an initial default-alias “N/A” warning; explicit `nvm use 22.22.3` then succeeded and `node --version` confirmed **v22.22.3** before strict validation. No runtime installation or dependency changes were needed.
- No Jest, typecheck, Swift build/tests, browser/simulator/device checks, baseline regeneration, byte mirroring or clinical source re-fetch ran during this planning task; they belong to the approved implementation/verification phase. Do not treat scenario definitions as test evidence.
- Before CLI archive, run workflow reflection, write `learnings.md` and request approval of any durable memory operations; never promote these unverified source details or one-off planning facts into memory.

## Review round A (artifacts, 2026-10-23)

Independent `reviewer` reviewed the planning artifacts: verdict **fix first**, findings A-1/A-2 important, A-3 nit. It also confirmed: nosework storage reuse is technically sound (PK `(dog_id, activity_id)`, max ordinal, no activity FK — `Migrations.swift:177–183`), C-1/C-2/C-3 honoured, disclaimer surfaces consistent across the four artifacts, all five gear IDs genuinely absent from both vocabularies, weak sourcing gated before authoring, and `git status` matches the planning-only claim. It independently re-ran `openspec validate add-hygiene-care-section --strict` (passed). Not checked by it: Jest/typecheck/Swift/UI/simulator, clinical pages, generated parity output.

User answer: address **all recommended** (A-1 + A-2 + A-3). Implementation approved for this change ("dobra ogólnie zróbmy open spec" → "ok spoko dawaj to robimy" → "no wszystkie rekomendowane").

- **A-1 resolved** — verified in code first: `AppModel.swift:111–123` → `SessionRepository.resumableSet` really inserts a `'active'` session with zero reps when none exists (`SessionRepository.swift:72–79`). Design decision 5 now states a narrower, checkable invariant instead of the false "history untouched" promise: care writes only the namespaced participation row; the advisory link behaves exactly like the catalogue route (at most `handling`'s own empty pending set at the current position, no rep/verdict/movement); back navigation records nothing. New task 5.6 tests it from a fresh state and requires the honesty note. Read-only duplicate screen rejected as needless surface.
- **A-2 resolved** — design decision 1 now declares care a separate collection that never enters `CATALOGUE` / `TrainingContent.catalogue`, `ContentSeeder` exercise/step seeding, Today recommendation or mastery/rungs rollups; spec requirement "Existing scored training remains unchanged" gained the "Care stays out of scored surfaces" scenario; new task 4.4 requires JS+native integration assertions (domain tests alone insufficient).
- **A-3 resolved** — design gained decision 6.1 with the concrete source contract (1–5 routine-level `{title,url}`, https-only, dotted hostname, no whitespace/credentials, no duplicates, per-stage sources rejected) and matching negative fixtures in both validators; spec + tasks 2.1/2.2 updated.

Evidence gate update: the human-toothpaste/xylitol hazard now has a full-page authoritative read (Pet Poison Helpline "Xylitol": toothpaste listed among xylitol products; life-threatening hypoglycaemia possibly within 10–15 minutes, acute liver failure). The dog-specific enzymatic-paste recommendation and the road-salt/lukewarm paw-rinse advice remain gated; search integration returned no results for institutional winter-paw sources, so the gate is unresolved rather than silently downgraded.

Checks actually run this round: `openspec validate add-hygiene-care-section --strict` → "Change 'add-hygiene-care-section' is valid" (CLI `/opt/homebrew/bin/openspec`, Node v22.22.3). No code, content JSON, or baseline touched.

## Runtime focus correction (2026-10-23, user instruction)

The user declined further TypeScript work and stated the priority plainly: this is a Swift application. Recorded consequence for the rest of this change: the native runtime (`Pettrainer/`, `PettrainerTests/`) is where the care feature is built and verified; the TS side keeps only what already exists so the repo still typechecks (care types in `src/content/schema.ts`, parser `src/content/schema/care.ts`, exports, gear vocabulary and icons) and gets no new tests or screens from here. The stray `src/ui/Gear.test.ts` written moments earlier was deleted rather than left half-working. Section 5 (JS `CareScreen.tsx`, catalogue wiring) is therefore parked pending an explicit decision after the native migration closes — the spec's care requirements stay satisfied by the native implementation; the JS reference simply does not gain the screen yet.

Done so far, native-primary: `Pettrainer/Content/Models/CareRoutine.swift`, `Pettrainer/Content/Validators/CareValidator.swift` with 13 targeted tests green (`CareValidatorTests`), gear vocabulary `brush/toothbrush/dog-toothpaste/dog-shampoo/styptic` in `Vocabulary.swift` + drawn icons in `GearIconView.swift` + PL/EN labels in `Localizable.xcstrings`. TEST BUILD SUCCEEDED.

## Implementation round (native-first), 2026-10-23

Scope note: the user directed Swift-first work ("nie wiem, po co sprawdzasz ts — budujemy aplikację swift"). Implemented natively; the TS reference keeps only the already-written contracts (types, parser, exports, gear vocabulary, icons) and gets no screens. Tasks left open on purpose: 3.5 (JS loader registration), 4.2 (`CareStateTests` for the failed-write/retry branch), 4.3 + 5.2 + 5.3 (JS participation and screens), 4.4/6.2 JS halves, 5.1's JS keys, 6.1 (baseline diff awaits independent review), 7.3 (iPad/VoiceOver/Dynamic Type pass), 7.4 (final review). Nothing here is claimed as done without a run behind it.

What exists now:
- `Pettrainer/Content/Models/CareRoutine.swift`, `Validators/CareValidator.swift`; 13 `CareValidatorTests` assert error strings verbatim against the JS parser's messages, so the two validators cannot drift silently.
- Seven canonical routines in `src/content/data/care/` mirrored byte-identically to `Pettrainer/Resources/Content/care-care-*.json`; 8 `CareContentTests` pin browse order, catalogue exclusion, bilingual stop-line presence, professional routing, three unscored stages, resolvable practice links, source URLs, and a copy ban on „opanowane/mastered/zaliczone/ukończone".
- `Pettrainer/Data/CareRepository.swift` facade (7 `CareRepositoryTests`: max-only, per-dog/per-routine isolation, refused ids/stages leave no row, scored tables untouched, survives reopening the file). `CareIsolationTests` asserts care ids are absent from catalogue + seeded `exercise` rows and that `user_version`, `session`, `rep`, `context_progress` counts do not move when care is written.
- `CareView.swift` (screen + card row), `Route.care`, `RootView` destination, catalogue section above nosework, `care.*` keys ×9 in `Localizable.xcstrings`, five drawn gear icons in `GearIconView.swift` + `Gear.tsx`.
- `CareFlowUITests` (5): seven rows openable, disclaimer + stop section before instructions, stage 3 selectable out of order, reading writes nothing (verified across a relaunch), mark-tried shows „Furthest stage tried: 1/3" and survives relaunch, PL copy check, and the reviewer A-1 advisory-route invariant.

Evidence actually run: `PettrainerTests` 137 tests, 1 skipped (the intentional icon generator), 0 failures; `LaunchSmokeUITests` + `CareFlowUITests` 12 tests, 0 failures (~5 min); `npx jest` targeted 130 tests across care/schema/load/verdict/progression/setMachine; `npm run typecheck` clean; `openspec validate add-hygiene-care-section --strict` → valid. Simulator: iPhone 15 Pro (E62B27CA…), derivedData `build-native`. Not run: iPad, VoiceOver/Dynamic Type audit, physical device, archive/upload, full JS Jest suite.

Test-infrastructure fix found on the way (real, not cosmetic): adding the care section lengthened the catalogue and `LaunchSmokeUITests.testProblemFlow…` began failing. Diagnosis by temporary probe showed the problem row reported `isHittable` with frame y=834 on an 852 pt screen — the tap centre fell off-screen. `isHittable` does not mean „visible enough to tap". `PettrainerUITests/UITestScroll.swift` now scrolls in small controlled drags until the row's centre sits inside the readable band, in both directions (a full `swipeUp` moves ~510 pt while a row is ~85 pt tall, which let rows jump over the band and ping-pong). The welfare assertion in the smoke test is unchanged; the probe file was deleted.

Copy gates, resolved without inventing evidence:
- xylitol/human-toothpaste hazard: full-page Pet Poison Helpline read; cited in `care-teeth` sources.
- Paw rinsing: the road-salt/chemical-burn claim could not be confirmed from an institutional source (search integration returned nothing; guessed URLs 404'd), so the authored copy makes no salt claim at all — it teaches the habit (station → damp contact → brief lukewarm rinse, dry, inspect) and stops at cracks/pain/irritation → veterinarian. `parity-data.json → care.provenance` records that care hashes prove src↔bundle parity, not 2021 JS parity.
- Dog-specific enzymatic toothpaste: unconfirmed, so stage copy routes product choice to the veterinarian instead of recommending a product type.


## Final review round (7.4) and the fixes it forced

The independent review returned **fix first**. What was actually wrong, and what the fix was:

- **V-1 (welfare, blocking)** — `care-nails` stage 3 taught an anatomy recipe I had invented
  („a dark dot appears in the middle”) and the urgent block had drifted to letting *someone else*
  trim. Both are unsafe. Now: the veterinarian shows where the limit sits in *this* dog’s nails
  and how *this* tool works, only one nail at a time, and no one — groomer or quick vet visit —
  is asked to trim while the cooperative-care training is unfinished. Very long nails: the
  veterinarian sets the plan, not force.
- **V-2 (welfare, blocking)** — the withdrawal rule was partial. Every one of the seven routines
  now states it inside the visible safety block: a dog that withdraws, stiffens or walks away
  ends the contact *now* (let go, give space, easier practice another day), and growling, a
  teeth-snap or bite history is routed to a behaviour professional with a veterinarian first for
  a sudden change.
- **V-3 (welfare, blocking)** — removed the endurance framing (`„kilkadziesiąt pociągnięć”`,
  „pies wytrzymuje”), which measured tolerance instead of participation; the coat stage is now a
  short section while the dog stays by choice. Paw drying is gentle removal with a towel, not
  „obij łapy z brudu”; „niemokra mata” is now *mata antypoślizgowa*; „daje się odklepać” is
  *pozwala delikatnie osuszyć*; the invented „mokre buty” cue is gone. Bath and rinse `watchFor`
  text no longer says „zostaje do spłukania” — withdrawal means the water goes off even if
  rinsing is incomplete.
- **V-4** — `care-checks` no longer implies a hand exam the owner should perform: the title is a
  predictable approach the dog may decline, the final stage is a look-over one area at a time,
  and nothing is examined inside an ear or under an eyelid; anything noticed is material for a visit.
- **V-5** — the brush is introduced as its own earlier meeting rather than a hidden precondition
  of stage 3, and the unsupported fluoride/sodium-pyrophosphate claims are gone; the hazard
  sentence is the verified one: some human toothpastes contain xylitol, which is toxic to dogs.
- **V-6 (Polish editorial)** — „Nic jeszcze nie próbowane” → „Jeszcze nie próbowaliśmy”,
  „Kreda krwawostopowa” → „Proszek tamujący krwawienie”, plus the calques and agreement errors
  the fixes introduced themselves (two garbles survived the first pass and were caught by a
  grep over the written files, not by luck).
- **V-7** — the failed-write branch had no test because `AppModel` could not be built against a
  temporary database. Added a `CareRecording` protocol (implemented only by `CareRepository`), a
  test-only `databaseURL` on `AppModel`, and `installCareStoreForTests`. `CareStateTests` (new)
  drives a real injected failure: publish only after commit, never downward, failure returns
  false and keeps the last committed maximum, retry works and stays idempotent, and a freshly
  built model reads the maxima back off disk.
- **V-8** — the isolation test compared row counts over empty history, so it could pass
  vacuously. It now seeds *populated* history through production APIs (a partial set with two raw
  reps, an earned `look` mastery via `applyOwnerChoice`, nosework level 2), asserts that history
  is visible, and then compares **exact** positions, mastery, nosework maxima and
  `recommendedExerciseId` before and after care writes and after reopening the file. The UI
  invariant no longer accepts `"Rep "` (which a set with recorded reps would also match); it
  asserts the exact `Rep 0 of 5`.
- **V-9** — the honest gap: the Swift parity test reads only bundled bytes, so editing the
  canonical copy could not fail it. Rather than claim coverage that did not exist,
  `openspec/changes/migrate-to-native-swift/baseline/verify_parity.py` now checks canonical↔bundled
  bytes, missing files on either side, and that every digest agrees with *both* `parity-data.json`
  and `ContentChecksums.swift`. Its value was tested by breaking a canonical file on purpose:
  exit 1 with `canonical and bundled bytes differ`, then exit 0 after restoring.
- **V-11** — `parity-manifest.md` overstated the care extension (nine resources, JS locale keys,
  `StringsTableTests` coverage). Rewritten: seven resources, native-only strings, coverage
  attributed to `CareFlowUITests`, and the parity limitation stated in the open.

After the copy change, the full UI suite failed three `CareFlowUITests` cases: they still expected
the old „Nothing tried yet” wording that V-6 replaced with „Not tried yet”. Fixed the assertions
(not the catalogue) and re-ran.

Evidence for this round: `PettrainerTests` 140 tests, 1 skipped (the intentional icon generator),
0 failures; `npx jest --runInBand` 189 tests passed; `npm run typecheck` clean;
`verify_parity.py` → `parity ok: 50 resources, canonical == bundled == both inventories`;
`openspec validate --strict` valid for both `add-hygiene-care-section` and
`migrate-to-native-swift`. `CareFlowUITests` re-run after the wording fix is reported in
tasks/verification; `LaunchSmokeUITests` was green (7/7) in the same full run.

## Tooling wrong turn (recorded because it burned real time)

A `path-guard` plugin existed at `~/.config/opencode/plugins/path-guard/` and had **never
loaded**: it imported `@opencode/plugin` (the package is `@opencode-ai/plugin`) and used a
`Plugin.define(... ctx.tool.hook(...))` API that does not exist. The log holds 32
`message="failed to load plugin" ... Cannot find package '@opencode/plugin'` lines, which is why
garbled paths and truncated tool calls kept reaching the shell this session. Rewritten against
the real API (`export const PathGuard: Plugin` + `tool.execute.before`, single named export like
the working plugins), with the rules moved to `guard.ts` so they are unit-testable: 13 behaviour
checks pass, plus an adapter test that imports the module, builds the hook and asserts in-place
repair, abort on a garbled argument key, and a pass-through for healthy calls. Two holes from
this session are closed deliberately: `/private/**` is no longer skipped wholesale (a mistyped
scratch UUID used to create stray directory trees — writes now require an existing parent), and
unknown argument *keys* are rejected instead of silently unvalidated. The selftest lives in
`~/.config/opencode/tools/`, not under `plugins/`, because that directory is scanned at startup
and the file calls `process.exit`. Activation needs an OpenCode restart; `PATH_GUARD_DISABLE=1`
turns it off and `plugins/path-guard/guard.log` records repairs and rejections.


## Shared-file reconciliation with `correct-approved-polish-copy` (hygiene task 1.3)

The approved Polish copy audit (`openspec/reviews/2026-10-23-polish-copy-audit.md`, IDs 001–126,
approved by the user with „spoko popraw wszytko") owns wording in the same files this change
rewrote: `care-*.json` and `Localizable.xcstrings`. A mechanical disposition check of all 126 rows
against the live tree is recorded in
`openspec/changes/correct-approved-polish-copy/implementation-notes.md`: **108 rows are NOT
APPLIED** (audited sentence still shipping) and **18 rows are CONFLICT/PAUSED** (the field was
rewritten, by the earlier copy round or by hygiene V-1…V-6, in wording that differs from the text
the user approved). Of the care block 081–110, thirteen rows are still untouched:
082, 084, 086, 088, 089, 090, 091, 093, 096, 097, 098, 099, 109. (Numbers corrected after a
probe-length bug in the first count; the ledger records the method and both figures.)

Consequences, stated rather than glossed:

- The welfare fixes in this change are *stricter* than the audited text where they overlap
  (V-1 removes an invented anatomy recipe and forbids asking anyone to trim; V-2/V-3 make
  withdrawal an immediate stop and remove endurance framing). None of the care rows left
  unapplied is *weakened* by what hygiene did; several audited defects (094, 101, 110) are fixed
  by hygiene in different words.
- Where both texts address the same sentence, the spec of the copy change governs: the row is
  recorded as a conflict and paused, and someone must decide per row whether to keep the hygiene
  wording (and amend the audit record) or restore the approved wording. This change does not make
  that decision.
- **This blocks nothing in the native app** — build 5 already ships copy from a tree where 103
  audited corrections had not landed. That is a documentation/approval-trail fact, not a
  regression introduced here.
- JS deletion is held until the user chooses the order, because retiring `src/content/data/`
  changes where the remaining 103 rows would be applied.
