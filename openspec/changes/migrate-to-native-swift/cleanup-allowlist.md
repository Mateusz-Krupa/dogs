# Deletion allowlist — retiring the JavaScript runtime (task 9.1)

Status: **EXECUTED 2026-10-24.** The 130 listed paths were removed with `git rm -f`
(forced because the byte-identical copies in native Resources were uncommitted — the
src↔bundle parity was re-proven 50/50 immediately before deletion; nothing else
uncommitted was touched). Together with `verify_parity.py` earlier that day, 131
deletions are staged. Untracked caches (`ios/Pods`, `build*`, `node_modules`) and the
protected `src/content/copy-welfare.test.ts` remain on disk pending separate explicit
path approval. Rollback: `git checkout HEAD -- <path>` per file while this state is
uncommitted.

Inventory refresh anchor: HEAD `6dd81b6` on 2026-10-23 (not a claim that independent review
has run). Working tree still carries the copy-owner's uncommitted edits and checksum changes —
implementation is now **complete and verified per that change's own artifacts** (byte parity
50/50, 140/140 Jest, 33/33 native XCTest, FR-001–006 closed); only its archive step remains.
The safest sequence is a user-approved commit of the copy round before the `git rm` commit;
do not rely on this snapshot — recheck status and ownership immediately before review and
deletion.

## Previously recorded evidence — rerun against the final handoff

The results below were recorded before the current copy work; they are not a new test run
or proof that physical-device/update gates passed.

| Check | Result |
| --- | --- |
| `grep -c "assets/" Pettrainer.xcodeproj/project.pbxproj` | 0 — the native app ships `Pettrainer/Assets.xcassets` |
| `grep -c "../ios\|ios/Pods\|node_modules" Pettrainer.xcodeproj/project.pbxproj` | 0 |
| `grep -rln "src/" Pettrainer PettrainerTests PettrainerUITests` | only `// port of src/...` provenance comments in illustration files |
| `xcodebuild test` with no npm/Metro/Pods running | 140 unit tests green (1 intentional skip) |

## Group A — tracked JS/Expo application runtime

- `App.tsx`
- `app.json`
- `eas.json`
- `index.ts`
- `package-lock.json`
- `package.json`
- `src/content/behaviour.ts`
- `src/content/catalogue.ts`
- `src/content/data/behaviour/alone.json`
- `src/content/data/behaviour/bark-door.json`
- `src/content/data/behaviour/bark-window.json`
- `src/content/data/behaviour/bed.json`
- `src/content/data/behaviour/bolting.json`
- `src/content/data/behaviour/jumping.json`
- `src/content/data/behaviour/mounting.json`
- `src/content/data/behaviour/nipping.json`
- `src/content/data/behaviour/noise.json`
- `src/content/data/behaviour/reactivity.json`
- `src/content/data/behaviour/stealing.json`
- `src/content/data/behaviour/traffic.json`
- `src/content/data/care/care-bath.json`
- `src/content/data/care/care-checks.json`
- `src/content/data/care/care-coat.json`
- `src/content/data/care/care-nails.json`
- `src/content/data/care/care-paw-rinse.json`
- `src/content/data/care/care-teeth.json`
- `src/content/data/care/care-towel.json`
- `src/content/data/environments.json`
- `src/content/data/exercises/come.json`
- `src/content/data/exercises/down.json`
- `src/content/data/exercises/drop.json`
- `src/content/data/exercises/handling.json`
- `src/content/data/exercises/leash.json`
- `src/content/data/exercises/leave.json`
- `src/content/data/exercises/look.json`
- `src/content/data/exercises/mat.json`
- `src/content/data/exercises/name.json`
- `src/content/data/exercises/sit.json`
- `src/content/data/exercises/stay.json`
- `src/content/data/exercises/wait.json`
- `src/content/data/mistakes/come.json`
- `src/content/data/mistakes/down.json`
- `src/content/data/mistakes/drop.json`
- `src/content/data/mistakes/handling.json`
- `src/content/data/mistakes/leash.json`
- `src/content/data/mistakes/leave.json`
- `src/content/data/mistakes/look.json`
- `src/content/data/mistakes/mat.json`
- `src/content/data/mistakes/name.json`
- `src/content/data/mistakes/sit.json`
- `src/content/data/mistakes/stay.json`
- `src/content/data/mistakes/wait.json`
- `src/content/data/nosework/cups.json`
- `src/content/data/nosework/find-person.json`
- `src/content/data/nosework/find-toy.json`
- `src/content/data/nosework/scatter.json`
- `src/content/data/nosework/snuffle.json`
- `src/content/data/nosework/track.json`
- `src/content/environments.test.ts`
- `src/content/environments.ts`
- `src/content/exercises/sit.test.ts`
- `src/content/exercises/sit.ts`
- `src/content/exercises/steps.ts`
- `src/content/load.test.ts`
- `src/content/load.ts`
- `src/content/mistakes.ts`
- `src/content/nosework.ts`
- `src/content/schema.test.ts`
- `src/content/schema.ts`
- `src/content/schema/behaviour.test.ts`
- `src/content/schema/behaviour.ts`
- `src/content/schema/care.test.ts`
- `src/content/schema/care.ts`
- `src/content/schema/checks.ts`
- `src/content/schema/environments.ts`
- `src/content/schema/exercise.ts`
- `src/content/schema/mistakes.ts`
- `src/content/schema/nosework.ts`
- `src/db/migrate.test.ts`
- `src/db/migrate.ts`
- `src/db/schema.ts`
- `src/domain/progression.test.ts`
- `src/domain/progression.ts`
- `src/domain/verdict.test.ts`
- `src/domain/verdict.ts`
- `src/features/catalogue/ExerciseList.tsx`
- `src/features/nosework/NoseworkScreen.tsx`
- `src/features/problems/ProblemScreen.test.tsx`
- `src/features/problems/ProblemScreen.tsx`
- `src/features/problems/problemSections.ts`
- `src/features/session/SetScreen.tsx`
- `src/features/session/setMachine.test.ts`
- `src/features/session/setMachine.ts`
- `src/i18n/i18n.test.ts`
- `src/i18n/index.ts`
- `src/i18n/locales/en.ts`
- `src/i18n/locales/pl.ts`
- `src/ui/DogPose.tsx`
- `src/ui/Gear.tsx`
- `src/ui/GearRow.tsx`
- `src/ui/ProblemScene.tsx`
- `src/ui/SetupScene.tsx`
- `src/ui/StepDiagram.tsx`
- `src/ui/lureStages.ts`
- `tsconfig.json`

The listed manifests (`package.json`, `package-lock.json`, `tsconfig.json`, `app.json`,
`eas.json`) make `npm run test`/`typecheck` and `expo run` exist. After this group the app has
no JS/Node runtime or npm build scripts. Repository tooling such as OpenSpec is separate and
may still use Node; `.nvmrc` is retained for it. AGENTS/OpenSpec application-check guidance
must move to native commands through task 9.2 in an authorized implementation context.

## Group B — generated Expo iOS project (19 paths)

- `ios/.gitignore`
- `ios/.xcode.env`
- `ios/Podfile`
- `ios/Podfile.lock`
- `ios/Podfile.properties.json`
- `ios/pettrainer.xcodeproj/project.pbxproj`
- `ios/pettrainer.xcodeproj/xcshareddata/xcschemes/pettrainer.xcscheme`
- `ios/pettrainer.xcworkspace/contents.xcworkspacedata`
- `ios/pettrainer/AppDelegate.swift`
- `ios/pettrainer/Images.xcassets/AppIcon.appiconset/App-Icon-1024x1024@1x.png`
- `ios/pettrainer/Images.xcassets/AppIcon.appiconset/Contents.json`
- `ios/pettrainer/Images.xcassets/Contents.json`
- `ios/pettrainer/Info.plist`
- `ios/pettrainer/PrivacyInfo.xcprivacy`
- `ios/pettrainer/SceneDelegate.swift`
- `ios/pettrainer/SplashScreen.storyboard`
- `ios/pettrainer/Supporting/Expo.plist`
- `ios/pettrainer/pettrainer-Bridging-Header.h`
- `ios/pettrainer/pettrainer.entitlements`

Produced by `expo prebuild`; `Pettrainer.xcodeproj` is the hand-maintained shipping project and
is **not** in this group.

## Group C — Expo-only image assets (6 paths)

- `assets/android-icon-background.png`
- `assets/android-icon-foreground.png`
- `assets/android-icon-monochrome.png`
- `assets/favicon.png`
- `assets/icon.png`
- `assets/splash-icon.png`

## Explicitly NOT deletable (checked, kept)

- `Pettrainer/`, `PettrainerTests/`, `PettrainerUITests/`, `Pettrainer.xcodeproj/` — the product.
- `openspec/` including `baseline/` — requirements, the frozen 41-file JS parity snapshot and
  `parity-data.json`; they are provenance, not runtime.
- `AGENTS.md`, `.opencode/`, `.claude/`, `opencode.json`, `DISTRIBUTION.md` — agent/tooling and
  the shipping runbook.
- `build/`, `build-native/`, `node_modules/`, `Pods/` — untracked build output: **not** deleted
  by this change (task 9.1 forbids broad untracked deletion; cache cleanup needs its own
  explicit path approval).
- `.gitignore`, `.nvmrc` — retained; `.nvmrc` pins repository tooling, not the native app.
- `src/content/copy-welfare.test.ts` — was protected pending an owner retirement decision.
  **2026-10-24: retired by explicit owner order** („usuń to też”). Its welfare stop-line/cue
  assertions exist natively (`BehaviourWelfareCopyTests` et al.); the JS-only typography sweep
  was verified once by hand (approved-copy task 5.3: zero `„…"` pairs) and is not re-automated
  natively — future copy changes rely on the reviewer checklist for quotes.

## Required order (recoverability)

The seven care source JSONs and two care schema files are now tracked. Their current copy edits,
and other uncommitted work, are not protected merely by being tracked. Require the owning copy
change to finish implementation and verification and record a recoverable handoff, including
approved before/after content evidence and source/native byte parity. Preserve all unrelated
changes; do not commit, stash or reset on the user's behalf. Neither archive nor an automatic
commit is a prerequisite imposed by this plan; committing still needs separate user approval.

Refresh the inventory for newly added tests, review parity and all 8.x gate evidence, and obtain
independent review plus explicit approval of the exact deletion list. Only then remove listed
paths in the authorized implementation context. Broad `git rm -r src` or recursive cache
deletion is not authorized. Any changed ownership or new file invalidates the affected inventory
until reviewed again. No deletion occurs during planning.

## Consequences accepted (and why they are safe)

1. **Content canon moves.** The inventory comprises 50 source JSON files (43 baseline/extension
   files plus 7 care files). Do not assume parity while concurrent copy edits are in flight:
   prove all current source/native pairs match at handoff. Validate approved changes through
   `approved-content-delta.md` (now under `archive/2026-10-23-correct-approved-polish-copy/`)
   and current native checksum expectations, without rewriting the historical migration
   snapshot. After Group A the native resources become the single canonical copy, guarded by
   the `ContentChecksums.swift` assertions in `ContentLoaderTests` (they run on every test).
   `verify_parity.py` was **deleted 2026-10-23 by owner decision** (it duplicated the native
   checksum guard, was unsatisfiable against the deliberately frozen baseline, and its
   src-side checks died with Group A); resolving PC-002 this way means nothing to retire at
   deletion time — the native tests are the verifier.
2. **`baseline/gen_manifest.py` stops working** (it reads `src/content/data/`). It is a
   provenance generator for a snapshot that must never be regenerated from a different runtime
   anyway; it stays in the tree with a header note, unchanged in behaviour.
3. **Node verification commands disappear.** `npm run test`, `npm run typecheck` and
   `npx jest` stop existing. Task 9.2 must retarget `AGENTS.md` §6 and `openspec/workflow.md`
   to `xcodebuild test` / `xcodebuild build`, otherwise the working instructions lie. That edit
   is part of this step and needs the same authorization.
4. **Progress data is untouched.** Deletion removes source files only; no migration is edited,
   no schema changed, no `user_version` bump, nothing in the app container. The SQLite file at
   `Library/Application Support/pettrainer.sqlite` is what carries owner history, and Group A/B/C
   never wrote to it.
