## MODIFIED Requirements

### Requirement: Puppy guidance has one freely accessible native entry
The application SHALL offer a localized puppy-start entry before the existing exercise list. Its hub SHALL show an educational/not-veterinary-care disclaimer, four help-now links in order (overarousal, fear/withdrawal, nipping, mounting), then five foundations in order (rest, exploring the world, play with breaks, first short exercises, toilet training). Access MUST NOT require a dog age, account, prerequisite, completed set or network connection. Existing catalogue entries and destinations SHALL remain available.

#### Scenario: Owner has no training history or age entered
- **WHEN** the owner opens the catalogue and puppy entry in either locale
- **THEN** all nine hub destinations are available without setup or locked content and the disclaimer is visible

#### Scenario: Existing sections remain available
- **WHEN** the puppy entry is introduced or extended
- **THEN** existing exercise, care, nosework and problem destinations remain reachable without reordered existing entries inside their families

### Requirement: Foundations are educational rather than scored activities
The system SHALL bundle exactly five puppy foundations with stable IDs `puppy-rest`, `puppy-world`, `puppy-play`, `puppy-first-exercises`, `puppy-toilet`, separately from scored exercises. Each SHALL include bilingual title/description, urgent/referral boundaries, things to avoid, concrete actions, observations, professional-help guidance and evidence. Optional exercise links SHALL resolve to existing exercises. Foundations MAY add optional titled bilingual reading sections; absence SHALL preserve existing content compatibility. Foundation screens MUST NOT expose completion, attempts, scores, timers, mastery or emotion-success metrics.

#### Scenario: Owner reads rest guidance
- **WHEN** `puppy-rest` is opened
- **THEN** the guidance describes undisturbed comfortable rest and individual needs without a universal sleep quota or a requirement to obey before resting

#### Scenario: Owner opens first exercises
- **WHEN** `puppy-first-exercises` is opened
- **THEN** it offers optional links to `name`, `look` and `mat`, explains that practice requires comfortable engagement, and does not equate stillness with emotional calm

#### Scenario: Owner opens toilet guidance
- **WHEN** `puppy-toilet` is opened
- **THEN** it offers an immediate accident response and titled detailed reading sections without scored drills or completion state

### Requirement: Published guidance is traceable to verified sources and approved copy
All five foundations, both new cards and the reviewed nipping/mounting cards SHALL carry 1–5 source titles/HTTPS URLs and an actual verification date. All action/medical/referral claims SHALL have a field-level source mapping in the change's copy ledger before publication, including any added section paragraphs. Full supporting-page reads, independent bilingual review and explicit user approval of drafts/replacements MUST precede bundling. Source-backed copy MUST be original and MUST NOT assert veterinary endorsement. Existing unrelated approved sentences SHALL be preserved; every touched existing PL field SHALL record the corresponding EN disposition.

#### Scenario: A source is available only as a search snippet
- **WHEN** a proposed medical claim lacks a readable supporting source
- **THEN** the claim is omitted or the affected draft remains blocked, and the app does not present that snippet as verified clinical authority

#### Scenario: One source also recommends punitive methods
- **WHEN** advice is selected from a mixed source
- **THEN** only independently supported welfare-compatible claims are used and punitive passages are excluded in both languages

#### Scenario: Existing card receives a replacement
- **WHEN** a specific mounting/nipping field is proposed for change
- **THEN** its before/after text, source support and PL/EN alignment are reviewed and approved before that field changes, while other fields and stable IDs remain intact

## ADDED Requirements

### Requirement: Optional foundation sections are validated without breaking older guides
When supplied, `sections` SHALL be a nonempty array of sections with unique nonblank stable IDs, nonblank PL/EN titles and nonempty PL/EN paragraph arrays whose entries are nonblank. Missing `sections` SHALL parse as no extra sections. Present-but-malformed sections and scored/gated fields within sections MUST fail with source/field diagnostics, using the same prohibited scoring/gating concepts as the parent guide. Existing evidence/date and reference checks SHALL remain intact.

#### Scenario: Existing foundation has no sections
- **WHEN** the existing four resources load unchanged
- **THEN** they parse and render without empty section placeholders or new content requirements

#### Scenario: A section translation or ID is invalid
- **WHEN** a section lacks an EN title, includes a blank paragraph, duplicates another section ID or introduces a completion/repetition field
- **THEN** validation fails with the affected resource and field rather than silently hiding the malformed section
