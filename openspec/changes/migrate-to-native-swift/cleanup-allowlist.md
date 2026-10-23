# Deletion allowlist — retiring the JavaScript runtime (task 9.1)

Status: **proposal, awaiting gate 8.5 (independent pre-cleanup review) and explicit user
approval.** Nothing here is deleted before both exist. Every entry is `git`-tracked, so
`git checkout HEAD -- <path>` is the rollback for the whole set while the commit is local.

Repository at review time: HEAD `2869749`,
working tree clean except untracked `openspec/changes/better-views` and
`openspec/changes/slow-dog-fast-food` (user-owned, never touched here).

## Evidence that the native product does not depend on any of this

| Check | Result |
| --- | --- |
| `grep -c "assets/" Pettrainer.xcodeproj/project.pbxproj` | 0 — the native app ships `Pettrainer/Assets.xcassets` |
| `grep -c "../ios\|ios/Pods\|node_modules" Pettrainer.xcodeproj/project.pbxproj` | 0 |
| `grep -rln "src/" Pettrainer PettrainerTests PettrainerUITests` | only `// port of src/...` provenance comments in illustration files |
| `xcodebuild test` with no npm/Metro/Pods running | 140 unit tests green (1 intentional skip) |

## Group A — JS/Expo application runtime (97 paths)

- `.nvmrc`
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

The last five entries (`package.json`, `package-lock.json`, `tsconfig.json`, `app.json`,
`eas.json`) are what makes `npm run test`/`typecheck` and `expo run` exist at all; after this
group the repository has no Node toolchain, so the AGENTS/OpenSpec command guidance must move
to native commands in the same pass (task 9.2), or the documentation instructs commands that
no longer exist.

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
- `.gitignore`, `.nvmrc` — kept if present as tracked: `.nvmrc tracked`

## Required order (recoverability)

The seven care canonical files and every other hygiene artefact are still **untracked**. `git rm`
only protects tracked content, so the hygiene change is committed first (making the canonical
copies tracked and recoverable), and only then does the deletion land as its own commit. No file
in Groups A–C may be untracked at the moment of deletion; the deletion commit is therefore
`git rm`-only and adds nothing.

## Consequences accepted (and why they are safe)

1. **Content canon moves.** 50 JSON files under `src/content/data/` (43 tracked baseline files
   + 7 care files, currently untracked) are the authored canonical copies today and are
   byte-identical to the 50 bundled resources
   (`baseline/verify_parity.py` proves it at the moment of deletion). After Group A the native
   bundle is the single canonical copy; the recorded digests keep guarding its bytes, and
   `verify_parity.py` gets its src-side checks retired in the same commit so it degrades to
   digest-vs-bundle instead of failing.
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
