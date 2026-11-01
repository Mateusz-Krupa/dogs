## ADDED Requirements

### Requirement: Approved corrections are traceable and bounded
The application SHALL use the explicit approved replacement wording from audit IDs 001–126 in `openspec/reviews/2026-10-23-polish-copy-audit.md`. The change MUST record an ID-to-field implementation ledger and preserve unquoted sentences except where the selected item replaces a whole field. Unspecified future stylistic work MUST NOT be inferred from approval of the audit.

#### Scenario: A selected sentence is part of a longer note
- **WHEN** a selected correction quotes one sentence from a multi-sentence note
- **THEN** that sentence is replaced with its approved version and unaffected sentences remain intact

#### Scenario: Common style direction is not an unbounded rewrite
- **WHEN** findings 124–126 are implemented
- **THEN** Polish quotation pairs are normalized, the explicit example in 125 is corrected, and snapping is not globally replaced with biting

#### Scenario: Live content changed during another feature
- **WHEN** an audited current sentence no longer matches the live field or the approved replacement
- **THEN** the implementer records the conflict and pauses that row rather than overwriting the other change

### Requirement: Advice remains semantically consistent in Polish and English
The app SHALL present equivalent instructions, success criteria and welfare boundaries in PL and EN for every corrected field. English that already matches the approved meaning MUST remain unchanged unless required by another selected correction. Placeholders and localized cue vocabulary MUST retain their runtime-compatible identifiers and types.

#### Scenario: Waiting time is corrected
- **WHEN** the user reads the look exercise's third-step note in either locale
- **THEN** the note describes waiting for the first offered look, not a look lasting half a minute

#### Scenario: Observable criteria match existing instructions
- **WHEN** the fourth drop or fourth mat step is displayed
- **THEN** both locales describe the currently instructed observable task according to findings 024 and 036 without adding a step or changing scoring mechanics

#### Scenario: Counts and interpolation render correctly
- **WHEN** catalogue level counts or care attempted-stage counters render in PL or EN
- **THEN** numeric placeholders remain valid and the approved Polish level-count format does not produce an invalid plural form

### Requirement: Source and native copies remain identical offline resources
Each changed content JSON resource SHALL have byte-identical source and native bundled copies. All corrected content SHALL remain available offline without authentication. Current checksum expectations MUST be updated only for approved changed files with before/after provenance; historical frozen migration snapshots MUST NOT be silently regenerated.

#### Scenario: A corrected care or exercise file is bundled
- **WHEN** the corrected resource is loaded from source and from the native bundle
- **THEN** both copies contain identical bytes and the current checksum fixture matches those bytes

#### Scenario: Historical provenance remains reviewable
- **WHEN** approved content hashes change
- **THEN** this change records the starting and resulting hashes and audit IDs while the original migration snapshot remains intact

### Requirement: Training, progress and history are unchanged
Copy corrections MUST NOT change stable IDs, step/stage counts, environment ordering, database structure, raw reps or progress records. Completed sets SHALL still contain exactly five reps: 5/5 push, 3–4/5 stick, 0–2/5 drop. Cancelled reps SHALL count as failures, incomplete sets SHALL remain incomplete, verdicts SHALL be computed rather than persisted, and mastery SHALL remain isolated by dog, exercise and environment.

#### Scenario: Existing history is opened after the copy update
- **WHEN** an existing owner opens training history or resumes an incomplete session
- **THEN** raw data, session completeness and per-dog/exercise/environment progress are preserved without reset or migration

#### Scenario: Boundary verdicts remain unchanged
- **WHEN** existing domain verification exercises hit counts 0 through 5, cancellation and incomplete sets
- **THEN** the original five-rep verdict and completeness behaviour remains unchanged

#### Scenario: Care attempted stages are displayed
- **WHEN** an owner marks or reads a care stage as tried
- **THEN** the wording describes an attempt rather than mastery or acceptance and no scored set or new stage is introduced

### Requirement: Editorial corrections preserve welfare boundaries
The corrected copy SHALL avoid aversive advice, punitive error markers, forced handling and content gating. Bite-history aggression, escalating guarding, severe separation distress and sudden changes suggesting pain MUST direct owners to appropriate professionals instead of a DIY fix. New medical protocols or professional endorsements MUST NOT be introduced as copy corrections.

#### Scenario: A warning involves snapping or a bite
- **WHEN** corrected warnings are displayed
- **THEN** snapping, attempted biting and biting are distinguished without minimizing danger or asserting contact that the text does not establish

#### Scenario: A selected correction replaces unsafe certainty
- **WHEN** the owner reads the revised nail, guarding, separation or noise guidance
- **THEN** the approved professional-referral and stop conditions remain intact in PL and EN and are not replaced with an unsupported guarantee
