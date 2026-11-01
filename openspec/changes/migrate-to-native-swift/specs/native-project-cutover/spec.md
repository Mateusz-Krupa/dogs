## ADDED Requirements

### Requirement: Focused native architecture with bounded configuration
The project SHALL separate pure domain rules, typed content/validation, local data access, feature orchestration and shared native UI. Existing content variants SHALL be expressed through bundled JSON and a typed ordered manifest, without a generic screen engine or runtime scripting. Production files SHALL normally be 100–200 lines; files over 250 non-generated lines require a documented reviewed justification.

#### Scenario: Extend a supported exercise
- **WHEN** an exercise using existing schema and illustration primitives is added
- **THEN** its content and manifest registration suffice without modifying catalogue/session rendering or duplicating training rules.

### Requirement: Native build and platform identity
The delivered app SHALL build/test using Xcode and Apple frameworks without npm, Metro, Expo, React Native, CocoaPods or a JS bundle. It SHALL retain bundle ID `com.mateuszkrupa.pettrainer`, iOS 16.4 minimum, iPhone/iPad support, relevant icons, privacy metadata and authorized signing/entitlements.

#### Scenario: Clean native verification
- **WHEN** the final checkout is built from a clean native build directory using the shared Pettrainer scheme
- **THEN** simulator tests and release compilation succeed without Node or Pods; a signed-device update is separately verified without uninstalling.

### Requirement: Gated removal of obsolete implementation
The old implementation SHALL remain frozen as a reference until parity tests, offline/interruption/update checks and independent pre-cleanup review pass. Cleanup SHALL remove only inventoried obsolete JS/Expo application and build files, preserving native resource copies, OpenSpec, user data, git history and unrelated user changes.

#### Scenario: Cleanup authorization
- **WHEN** cleanup is proposed
- **THEN** an explicit file allowlist and parity evidence are reviewed and user approval is recorded before deletion; unknown untracked `build/` is not removed.

#### Scenario: An active change still edits legacy sources
- **WHEN** approved copy or care work still owns changes in both legacy sources and native resources
- **THEN** cleanup waits for a stable owner handoff with relevant implementation/review checks complete, current source/native parity and approved content-delta/checksum evidence; it preserves unfamiliar work and does not require those changes to be archived.

#### Scenario: The deletion inventory predates new source files
- **WHEN** tracked care files or a newly created JS test are absent from the old deletion list
- **THEN** the list is refreshed and independently reviewed before explicit user approval; unknown untracked files are protected, no directory-wide delete is inferred, and `.nvmrc` remains available for repository tooling without making Node an application runtime requirement.

#### Scenario: Current approved copy differs from the historical snapshot
- **WHEN** approved content corrections have changed resource bytes since the original migration capture
- **THEN** current source/native parity and native-only checks use the reviewed content deltas and current checksum expectations, while the historical snapshot remains unchanged and cannot be regenerated merely to make checks pass.

#### Scenario: A required pre-cleanup check is unavailable
- **WHEN** visual/device/update verification or independent review is missing or cannot run
- **THEN** the result remains blocked or not-run, TestFlight or simulator evidence is not substituted for device/update checks, and source deletion does not start solely because the user approved addressing the findings.

#### Scenario: Final review and handoff
- **WHEN** native cutover is complete
- **THEN** an independent reviewer examines the final diff and verification evidence, findings have stable numeric IDs, only user-selected fixes are applied, and any unavailable device/signing checks are reported as blockers rather than passed tests.
