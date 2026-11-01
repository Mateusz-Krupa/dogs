## Context

The app has four feature screens (catalogue, session, nosework, problems), pure verdict/progression functions, a set reducer, vector illustrations, and bilingual JSON content. `App.tsx` currently holds progress in memory; `src/db/schema.ts` and `migrate.ts` are not connected to runtime storage. That is evidence about this checkout, not proof about every distributed binary or installed sandbox.

Inventory: 12 exercises, 12 mistake files, 6 nosework activities, 10 behaviour cards, and one environments file: 41 JSON resources. Catalogue order is explicit in `src/content/load.ts`, not filename order. Preserve all environment rows, beyond-puppy-scope metadata, sources/comments worth retaining, diagram overrides and optional copy fields. Capture exact counts, keys and bindings in a parity manifest before deleting anything.

Current generated Xcode project uses iOS 16.4, bundle ID `com.mateuszkrupa.pettrainer`, and iPhone/iPad support. Xcode 26.3 is installed. Untracked `build/` is user-owned until proven otherwise.

## Goals / Non-Goals

**Goals:** Fully native iOS runtime, functional/content parity, durable local history and progress, straightforward extension through typed content, focused files, and removal of the obsolete JS application after verification.

**Non-Goals:** Android/web replacement, backend/accounts/cloud sync, export or guaranteed backups, training redesign, new training methods, generalized UI schema, dependency injection framework, or multiple local dog-management screens. Storage supports dog isolation; the first release uses one stable local default dog matching today's anonymous dog label.

## Decisions

### 1. Native project and simple state ownership

Create a committed `Pettrainer.xcodeproj` at the repository root alongside `Pettrainer/`, `PettrainerTests/`, and `PettrainerUITests/`. Keep the old generated `ios/` project temporarily as a reference, never link both projects together. Use SwiftUI, `NavigationStack`, a small route enum, and `ObservableObject`/`@Published` compatible with iOS 16.4. No WebView, React bridge, CocoaPods, or third-party package is needed.

Prefer a committed Xcode project over XcodeGen: no extra generator/toolchain. Use Foundation types in domain only when necessary; no SwiftUI, SQLite or I/O imports there. Native test targets use XCTest so all tests run from Xcode. Shared scheme: `Pettrainer`.

### 2. Bounded modules and configuration

```
Pettrainer/
  App/           PettrainerApp.swift, RootView.swift, Route.swift
  Domain/        RepOutcome.swift, Verdict.swift, Progression.swift, SetState.swift
  Content/       Models/ (one content family/file), ContentLoader.swift,
                 Validators/ (one family/file), CatalogueManifest.swift
  Data/          SQLiteDatabase.swift, MigrationRunner.swift, Migrations/,
                 SessionRepository.swift, ProgressRepository.swift, NoseworkRepository.swift
  Features/      Catalogue/, Session/, Nosework/, Problems/
  UI/            Theme.swift, Components/, Illustrations/
  Resources/     Content/{exercises,mistakes,nosework,behaviour,environments.json},
                 Localizable.xcstrings, Assets.xcassets
```

Views render typed data; small feature models orchestrate repository calls. Explicit construction at the app root; protocols only at storage/testing seams. Split views at meaningful component boundaries, not by arbitrary line chunks. Aim for 100–200 lines/file, review exceptions over 250 non-generated production lines. No giant `Models.swift`, universal repository, or screen factory.

JSON controls copy, steps, prerequisites, environment rows, equipment and existing diagram options. A typed manifest preserves current content order and resource names. A new exercise using supported diagram primitives needs JSON + manifest registration, not edits to screens. New behaviour algorithms or drawing primitives remain explicit Swift code. Fixed five-rep thresholds are domain constants, not remotely configurable switches. Reject unknown IDs/enums, duplicate IDs, missing translations, invalid step order/references and malformed optional fields with source/field diagnostics.

Copy all 41 JSON files byte-for-byte into native resources; compare checksums before removing old copies. During migration the original copies are frozen; do not maintain two independently edited catalogues. Preserve all reference links and attribution. Port SVG coordinates to SwiftUI `Shape`/`Path` or `Canvas` using the same logical coordinate space, including treat-fading stages, sound cues, pose/motion overrides, equipment and setup/problem scenes. Keep still diagrams; do not reintroduce animation or hands.

### 3. Training parity, not blind bug copying

One domain policy defines five reps: 5 hits push, 3–4 stick, 0–2 drop; cancelled is a failure, unfinished is not complete. No persisted verdict or early completion, even when a final band is mathematically decided. Preserve undo and the owner's explicit harder/same/easier choice; do not auto-apply recommendations. Preserve progression boundaries and harder-environment entry at `max(1, ceil(stepCount * 0.6))`. Keep each environment's progress when the current position moves elsewhere; do not carry over the shell's exercise-only map as the storage model.

Nosework records participation/highest visited level without hit/miss verdicts. Behaviour cards preserve professional stop-lines and links to related exercises. Prerequisites advise but never disable access. No aversives, failure markers or punitive feedback.

### 4. Local SQLite and explicit recovery

Use Apple's SQLite3 library with prepared/bound statements, serialized database access and transactions. A stable `Application Support/pettrainer.sqlite` path is owned by a single database service. No server, login, analytics or core network access. Do not place mutable data in the bundle, Caches or temporary directories. iOS backup is dependent on user/device settings and is not promised; deletion of the app may delete local data.

Port the initial SQL schema and migration semantics: contiguous versions, foreign keys per connection, transactional pending migrations, rollback on error, and refuse a newer unsupported `user_version`. Introduce a new numbered migration for native additions rather than editing applied SQL: per-dog/exercise current position, per-context current step (separate from historical highest mastery), nosework progress, and explicit session lifecycle (`active`, `completed`, `abandoned`) while retaining existing row IDs and raw reps. Existing mastery is never silently treated as a current position. Seed referenced exercise/step/environment IDs before writing progress; preserve SQL step IDs and stable associations. The baseline manifest records the seed mapping.

Default dog creation is idempotent and uses a stable ID; future dog selection does not require a storage redesign. Tests use two dogs even though multi-dog management UI is out of scope. All repositories take dog IDs explicitly. Content updates use upserts with stable IDs, never cascade-delete historical references.

Every rep/undo is committed before the UI acknowledges it; failures retain last committed state and show localized retry without duplicate inserts. A fifth rep and completed lifecycle transition commit together. Undoing the fifth rep reopens the set transactionally until a next-step choice has been committed; after that it cannot alter the old set.

F-1 (review): the owner-choice commit updates current position and records the session-linked applied-choice idempotency marker in one transaction. The successor set is NOT pre-created; it is lazily created by the first committed rep after the choice. This removes the crash window between "choice applied" and "next set started" — an interrupted run can only find (a) an `active` partial set or (b) a `completed` set without an applied-choice record, and both are recoverable. Reopening an exercise resolves to its existing resumable or pending-choice set instead of creating a duplicate.

F-1 (review): on relaunch, recovery must surface both kinds — offer resume/abandon for `active` sets and re-present the pending easier/same/harder choice (with fifth-rep undo still available) for `completed` sets lacking an applied-choice record. Abandoning an active set retains its reps but yields no completed-set verdict. Leaving a session view retains it for resumption. Never infer completion from `ended_at` alone or auto-fill missing reps. Test interrupted writes, rapid duplicate taps, kill/relaunch immediately after the fifth rep AND immediately after a committed choice, and failed undo. No deletion/reset on corrupt data or migration failure: retain the file, present a localized recovery message and block unsafe writes.

F-2 (review): historical mastery (`mastery.highest_step_ordinal` per dog × exercise × environment) increases ONLY when a completed five-rep set at that step earned `push` (5/5). Position moves — including an owner choosing "harder" after stick/drop, or entering a later step — never change it; a downward move never erases earned mastery. Current position is separate, seeds at step 1 / starting environment per dog × exercise on first use, and is otherwise driven only by owner choices. The catalogue may describe the position as being at the final step, but any "mastered/learned here" badge or wording SHALL be computed from mastery rows, never from current position alone; the current JS behaviour of labelling the final step mastered purely by position is a parity exception deliberately corrected, not ported.

F-3 (review): v1 legacy `session` rows upgrade by deterministic classification, never rewriting raw reps:

| rep count | `ended_at` | lifecycle | notes |
| --- | --- | --- | --- |
| exactly 5 | non-null | `completed` | no applied-choice evidence exists, so the owner is offered the pending choice; nothing is auto-applied |
| exactly 5 | null | `completed` | same; a missing timestamp never demotes a full set |
| 0–4 | non-null | `abandoned` | reps retained, no verdict |
| 0–4 | null | `active` | resumable; only the most recent such row per dog × context stays `active`, any older ones become `abandoned` |

Migration fixtures must cover every combination; structurally inconsistent rows (duplicate ordinals, unknown step/environment IDs) fail the migration safely without touching data. Legacy `mastery` rows are preserved as historical mastery but are never copied into a current position; the seeded current position follows the F-2 rule above.

Add native tables/columns for these semantics through versioned migrations.

### 5. Localization and native accessibility

Port every UI key/interpolation to a String Catalog with PL and EN; resolve device preferences with Polish fallback matching existing behaviour (including unsupported/empty preferences). F-4 (review): substantial current copy is inline in feature screens rather than in `src/i18n/locales` (e.g. the session "About this exercise" block, per-mistake expand/collapse labels, the default dog label and step/environment bar text); the parity manifest must inventory these inline strings and disclosure states explicitly, and the native port maps each into the String Catalog — no new hardcoded labels. Content cue names remain localized data, not translated stable IDs. Match phone-first hierarchy and thumb actions with native controls; test VoiceOver labels, Dynamic Type and 44pt minimum touch targets. Keep tablet layout usable, orientation and appearance consistent with current product.

## Risks / Trade-offs

- Full rewrite can omit small UI states → source-based parity checklist and screenshots before deletion, including empty/partial/complete sets and every diagram binding.
- Existing deployed binaries might differ from checkout → verify actual installation/storage metadata before claiming no data; if any legacy store exists, stop and design a tested compatibility migration rather than overwrite it.
- Raw SQLite adds boilerplate → narrow statements/repositories, transaction tests; avoid replacing it with SwiftData/Core Data because that complicates schema parity and version control.
- Update identity/signing mismatch can create a separate app → preserve bundle ID, team/app identity and relevant entitlements; test update without uninstalling. Do not inspect credentials or change provisioning silently.
- Git revert does not reverse a database migration → additive migrations, preserve original schema/data and test supported downgrade refusal. Roll forward for incompatible database versions; never claim automatic rollback is safe.
- Tooling instructions currently require Expo/Jest → OpenSpec documents the intended native replacement; application/agent configuration changes require an appropriately authorized implementation context. Do not bypass restrictions to edit AGENTS or routing here.

## Migration Plan

1. Plan review and explicit user implementation approval; capture source commit, inventory, existing UI states and real deployed-storage evidence.
2. Build native project, domain/content tests, storage, illustrations and screens incrementally. Keep JS frozen and runnable as reference; do not ship a hybrid runtime.
3. Run targeted native tests, all-resource validation, localized simulator flows, and physical-device interruption/offline/update checks. Native seed build A → build B with next migration must preserve a known raw-rep history and unfinished set. Also install native over the existing Expo app with the same identity without uninstalling.
4. Independent pre-cleanup review; present numbered findings and apply only user-selected changes. Do not retire the reference until parity, update preservation, release build and approval gates pass.
5. Remove only explicitly inventoried JS/Expo artifacts; keep content in native resources, icons, privacy metadata, OpenSpec, git history and unrelated user files. Fresh native build/test after deletion must work without npm, Metro, Pods or a JS bundle.
6. Final independent diff review and report; TestFlight submission needs separate user authorization. Record learnings and propose memory updates before CLI archive.

## Delegation Plan

Planner owns OpenSpec artifacts only. `reviewer` independently reviews the plan and final code, read-only, without further delegation. Implementation is exclusively `/opsx-apply migrate-to-native-swift` using Flash Next (`swissquant-local/vision-flash`); unavailable routing is a blocker, never a reason for silent fallback.

Sequence: baseline/project → domain + content → persistence → illustrations → screens/integration → parity/update gates → cleanup → final review. Once domain/content contracts are fixed, illustrations (`UI/Illustrations/` only) and database repositories (`Data/` only) can be separate bounded assignments; project-file registration/integration has one owner. Do not dispatch overlapping writes or broad whole-rewrite tasks; each assignment returns changed files, targeted checks and open issues. Feature integration remains sequential because it shares navigation, localization and root wiring.

### Closing dependencies — CUT-001–003 selected on 2026-10-23

The working tree now includes active Polish-copy corrections in both runtimes and committed care content. The original frozen-reference assumption does not authorize deleting their in-progress source edits. First obtain a stable handoff from the copy/care owners: implementation and relevant checks complete, source/native parity proven, current checksums and approved content deltas recorded, and no unresolved overlapping work. Their archive is not a prerequisite. Preserve historical parity snapshots rather than regenerating them to bless new copy.

Refresh the exact cleanup list from current tracked paths; include the seven care JSONs and care schema/test files. Keep `.nvmrc` for repository tooling, not as an application dependency. An untracked new test such as `src/content/copy-welfare.test.ts` is protected, not covered by an old directory-wide cleanup approval; require a later explicit inventory decision after native coverage is verified. Check git status again immediately before removal. No stash/reset, automatic commit or cache wipe is part of this plan.

Sequence one copy-change implementation owner → one migration inventory/evidence owner → read-only independent reviewer → user approval of the exact list → one Flash Next cleanup owner → fresh native verification → final independent review. Shared content, localization, checksum fixtures and documentation must not have overlapping writers. Application implementation starts only through `/opsx-apply`; planner edits remain under OpenSpec. A required agent/configuration edit outside the implementer's authority is a reported blocker, not permission to bypass restrictions.

Retain 8.2 visual/accessibility and 8.3 physical-device/update-preservation gates. Report pass/fail/not-run separately; signed builds and TestFlight delivery do not prove update preservation. An unavailable reviewer, device or required legacy build leaves cleanup blocked. Selecting CUT-001–003 approves addressing these issues, not waiving verification or approving a future deletion inventory. After removal, current resource checks use reviewed content deltas and current checksum expectations; historical baseline bytes remain unchanged. No changes to five-rep verdict thresholds, per-dog/exercise/environment isolation, raw history, localization or welfare policies are introduced.

## Open Questions

No additional product question blocks artifact creation. Real deployed sandbox contents, signing authorization, available simulator/device destinations, and authorization for stack-specific instruction updates are verification/permission gates before the relevant implementation step. If evidence contradicts assumptions, pause rather than expand scope silently.
