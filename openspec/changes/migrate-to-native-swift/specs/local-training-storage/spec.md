## ADDED Requirements

### Requirement: Private on-device durable storage
The app SHALL store raw reps, sessions, current positions, per-context progress and nosework progress in local SQLite in Application Support, without accounts, servers or a network requirement. Verdicts SHALL NOT be persisted. All progress queries and writes SHALL be scoped by dog and relevant exercise/environment or activity IDs.

#### Scenario: Restart and context isolation
- **WHEN** two test dogs train different exercises/environments and the app is terminated and reopened offline
- **THEN** each dog's committed raw history, positions and context progress remain available without data leaking between dogs, exercises or environments.

#### Scenario: Default dog and nosework
- **WHEN** a fresh app starts repeatedly and a nosework level is completed
- **THEN** exactly one stable default dog is reused and its unscored progress survives relaunch without creating duplicate dog records.

### Requirement: Transactional session recovery
The app SHALL acknowledge only committed writes, distinguish active/completed/abandoned sessions, and retain incomplete raw reps. Completed status SHALL require exactly five reps. Undo and next-position choice SHALL be transactional and duplicate-safe. Recovery SHALL surface both resumable active sets and completed sets lacking a committed owner choice, and the successor set SHALL be created lazily by its first committed rep so an interruption can never leave a phantom or duplicate set.

#### Scenario: Interrupted session
- **WHEN** the app is killed after three committed reps and reopened
- **THEN** the owner can resume those three reps or abandon while retaining them, without obtaining a completed-set verdict.

#### Scenario: Killed after the fifth rep before any owner choice
- **WHEN** the app is killed immediately after the fifth committed rep and reopened before easier/same/harder was chosen
- **THEN** the completed set is surfaced with its pending choice, fifth-rep undo remains available, and no new set or verdict drift exists.

#### Scenario: Killed immediately after a committed choice
- **WHEN** the app is killed immediately after the owner choice transaction commits and the exercise is reopened
- **THEN** the position advanced exactly once, the applied-choice marker prevents reapplication, and no successor set exists until a new rep is committed.

#### Scenario: Failed or duplicate write
- **WHEN** a rep, undo, completion or owner-choice write fails or is retried after rapid duplicate input
- **THEN** persisted/UI state remains at the last committed state, a localized retry is available, no duplicate action is applied, and completion/progress cannot drift.

#### Scenario: Undo versus committed choice
- **WHEN** the fifth rep is undone before choosing a next position
- **THEN** the set reopens transactionally; after an owner choice is committed, the historical set cannot be edited through that undo action.

### Requirement: Safe schema evolution and update preservation
The app SHALL use ordered versioned transactional migrations, enable foreign keys, preserve raw history and stable content references, and refuse unsupported downgrades. Installation updates SHALL preserve app identity and database location without uninstall/reset. Existing installed storage SHALL be inspected through safe metadata/testing before assuming it is absent.

#### Scenario: Native update in place
- **WHEN** native build A containing completed and unfinished sessions is updated in place to build B with the next schema version
- **THEN** raw reps/IDs and context progress are preserved, unfinished sessions remain incomplete, and repeated startup applies no duplicate migration.

#### Scenario: Migration failure or newer schema
- **WHEN** a migration fails, the database is corrupt, or its version is newer than supported
- **THEN** the app preserves the existing file, rolls back pending transactional changes where possible, blocks unsafe writes and reports a localized recovery error rather than deleting/resetting data.

#### Scenario: Existing Expo installation
- **WHEN** the native app replaces the existing Expo installation using the same app identity without uninstalling
- **THEN** existing sandbox files are not removed; any discovered legacy data requires a verified compatibility migration rather than a clean-start assumption.

#### Scenario: Legacy v1 session upgrade classification
- **WHEN** a v1 database containing `session` rows with only `ended_at` (no explicit lifecycle) is upgraded, covering exactly-five reps with and without `ended_at`, 0–4 reps with `ended_at`, and 0–4 reps without `ended_at`
- **THEN** rows become respectively completed, completed, abandoned and active by the deterministic rule, only the most recent 0–4-rep null-`ended_at` row per dog × session context stays active, raw reps are never rewritten, owner choice is never auto-applied, and a structurally inconsistent row fails the migration safely without data loss.
