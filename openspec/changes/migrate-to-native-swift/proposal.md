## Why

Replace the Expo/React Native application with a fully native Swift/SwiftUI iOS app while keeping all existing training content and interactions. Deliver a small, extensible codebase and durable on-device progress without servers or accounts.

## What Changes

- Port catalogue, five-rep sessions, owner-selected progression, nosework, behaviour cards, diagrams, equipment, and PL/EN localization to native SwiftUI.
- Preserve bundled JSON content and stable IDs; use typed configuration for catalogue ordering and diagram bindings rather than a generic rendering engine.
- Connect local SQLite persistence for raw repetitions, unfinished sessions, per-dog/exercise/environment progress, and nosework progress. This is new runtime behaviour: the current shell only uses memory, although a database schema exists.
- Preserve installed-app identity and test update-in-place data preservation; never require uninstalling or resetting the database.
- **BREAKING:** Retire Expo/React Native, JavaScript/TypeScript application code, Node build dependencies, CocoaPods integration, and Android/web targets after native parity verification. The delivered product is iOS-only; preserve existing iPhone/iPad support and iOS 16.4 minimum.
- Keep files focused, normally 100–200 lines and at most 250 non-generated production lines unless a documented exception is reviewed.
- Non-goals: backend, accounts, cloud sync, guaranteed backup, export, new training content, redesign, custom framework, or plugin system.

## Capabilities

### New Capabilities

- `native-training-parity`: Native screens, training rules, content, diagrams, bilingual behaviour and welfare parity.
- `local-training-storage`: Offline SQLite persistence, interrupted sessions, context isolation, safe migrations and app updates.
- `native-project-cutover`: Native project structure, bounded configuration, repeatable verification, and safe retirement of JS tooling.

### Modified Capabilities

None; no existing capability specs are present.

## Impact

Replaces `App.tsx`, `index.ts`, `src/`, the generated Expo project under `ios/`, and JS-specific manifests/tooling with a Swift app, native tests, and bundled resources. Preserve `com.mateuszkrupa.pettrainer`, icons, relevant privacy declarations, signing identity/entitlements, content IDs, OpenSpec history, and user data. Cleanup must not remove unfamiliar untracked `build/` or unrelated configuration. Stack-specific repository instructions need an explicit implementation-time authorization gate; planning only edits OpenSpec.
