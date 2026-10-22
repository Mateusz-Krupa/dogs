## ADDED Requirements

### Requirement: Native feature and content parity
The app SHALL implement the catalogue, sessions, nosework and behaviour cards using native SwiftUI without a JavaScript runtime. It SHALL preserve all 41 existing JSON resources, IDs, explicit catalogue order, prerequisites, copy, equipment, diagrams and links.

#### Scenario: Offline catalogue and feature access
- **WHEN** the app launches in airplane mode and an owner opens any of the 12 exercises, 6 nosework activities or 10 behaviour cards
- **THEN** the bundled content and relevant still diagrams render without network access or locked prerequisites.

#### Scenario: Content validation
- **WHEN** content contains duplicate IDs, invalid references, unsupported diagram values, malformed optional fields or missing PL/EN text
- **THEN** validation identifies the source and field and prevents invalid content from being released.

### Requirement: Five-rep domain rules and owner control
One pure Swift domain implementation SHALL derive verdicts only from exactly five raw reps: 5 hits push, 3–4 stick, 0–2 drop. Cancelled reps SHALL count as failures. Incomplete sets SHALL NOT produce a completed verdict or automatic advancement.

#### Scenario: All score bands
- **WHEN** completed sets have respectively 0, 1, 2, 3, 4 and 5 successful reps
- **THEN** verdicts are respectively drop, drop, drop, stick, stick and push, including cancelled reps among failures.

#### Scenario: Partial sets and undo
- **WHEN** a set has 0–4 reps or the owner undoes its fifth rep before committing a next-step choice
- **THEN** it is incomplete with no completed verdict; recording a sixth rep is prevented.

#### Scenario: Owner selects progression
- **WHEN** a completed set suggests a change
- **THEN** easier, same and harder choices remain owner-controlled and advancement only happens after an explicit choice.

### Requirement: Two-axis progression
The app SHALL preserve ordered installation steps and environment generalization as separate axes, retain per-context progress, and use the existing domain boundary policy rather than a UI-specific offset. Historical mastery per dog × exercise × environment SHALL increase only when a completed five-rep set at that step earned push (5/5); current position, owner-selected advancement after stick/drop, and downward moves SHALL NOT change earned mastery. Any mastered/learned badge or wording SHALL be computed from mastery, never from current position alone.

#### Scenario: Position does not fake mastery
- **WHEN** an owner reaches the final step by entering it, or by choosing harder after a stick or drop set
- **THEN** historical mastery for that step does not increase and the catalogue presents the position neutrally rather than as mastered; mastery appears only after a push 5/5 completed set at that step, and a later drop never erases previously earned mastery.

#### Scenario: Move beyond final step
- **WHEN** an owner chooses harder at the last step with a next environment available
- **THEN** the app enters that environment at `max(1, ceil(stepCount * 0.6))` without overwriting the previous environment's progress.

#### Scenario: Easier and outer boundaries
- **WHEN** the owner chooses easier below step one or moves beyond the lowest/highest environment boundary
- **THEN** the previous environment is entered at its final step when available, otherwise the position is clamped as in the existing policy.

### Requirement: Bilingual accessible native interface
The app SHALL preserve PL/EN UI and training copy, interpolation values, device-language resolution and Polish fallback. Controls SHALL have accessible names, at least 44pt touch targets, and usable phone/tablet and Dynamic Type layouts.

#### Scenario: Language and diagram verification
- **WHEN** every changed screen and diagram family is inspected in Polish and English at phone size
- **THEN** no missing translation, clipped essential action or contradictory pose/motion/treat/sound cue is present; unsupported preferred languages fall back to Polish.

### Requirement: Welfare and unscored nosework
Prerequisites SHALL remain advisory. Red flags (bite-history aggression, escalating guarding, possible pain and severe separation anxiety) SHALL direct owners to a vet/certified behaviourist rather than DIY fixes. No aversive advice, error markers or punitive failure feedback SHALL be introduced. Nosework SHALL remain participation-based without hit/miss scoring.

#### Scenario: Red-flag card
- **WHEN** an owner opens a relevant red-flag behaviour card in either language
- **THEN** the professional stop-line remains visible and related exercises are not presented as a substitute DIY treatment.

#### Scenario: Failed repetition and nosework
- **WHEN** a rep fails or an owner completes a nosework level
- **THEN** failure resets silently without a punitive signal, and nosework records participation without a verdict.
