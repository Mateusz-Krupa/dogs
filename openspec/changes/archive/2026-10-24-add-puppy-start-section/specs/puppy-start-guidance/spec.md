## ADDED Requirements

### Requirement: Puppy guidance has one freely accessible native entry
The application SHALL offer a localized puppy-start entry before the existing exercise list. Its hub SHALL show an educational/not-veterinary-care disclaimer, four help-now links in order (overarousal, fear/withdrawal, nipping, mounting), then four foundations in order (rest, exploring the world, play with breaks, first short exercises). Access MUST NOT require a dog age, account, prerequisite, completed set or network connection. Existing catalogue entries and destinations SHALL remain available.

#### Scenario: Owner has no training history or age entered
- **WHEN** the owner opens the catalogue and puppy entry in either locale
- **THEN** all eight hub destinations are available without setup or locked content and the disclaimer is visible

#### Scenario: Existing sections remain available
- **WHEN** the puppy entry is introduced
- **THEN** existing exercise, care, nosework and problem destinations remain reachable without reordered existing entries inside their families

### Requirement: Foundations are educational rather than scored activities
The system SHALL bundle exactly four puppy foundations with stable IDs `puppy-rest`, `puppy-world`, `puppy-play`, `puppy-first-exercises`, separately from scored exercises. Each SHALL include bilingual title/description, urgent/referral boundaries, things to avoid, concrete actions, observations, professional-help guidance and evidence. Optional exercise links SHALL resolve to existing exercises. Foundation screens MUST NOT expose completion, attempts, scores, timers, mastery or emotion-success metrics.

#### Scenario: Owner reads rest guidance
- **WHEN** `puppy-rest` is opened
- **THEN** the guidance describes undisturbed comfortable rest and individual needs without a universal sleep quota or a requirement to obey before resting

#### Scenario: Owner opens first exercises
- **WHEN** `puppy-first-exercises` is opened
- **THEN** it offers optional links to `name`, `look` and `mat`, explains that practice requires comfortable engagement, and does not equate stillness with emotional calm

### Requirement: Situations use canonical behaviour content
The system SHALL add canonical behaviour cards `overarousal` and `fear-withdrawal` to the existing problems list immediately before `alone` and reuse those same cards from the puppy hub. Hub nipping/mounting links SHALL resolve to existing `nipping`/`mounting` cards. No second puppy-specific copy of those cards SHALL exist. The new cards SHALL include separate observation guidance and evidence; other old cards SHALL remain compatible without those optional fields.

#### Scenario: Same situation is opened from two entry points
- **WHEN** the owner opens overarousal from the hub and from the problems list
- **THEN** both routes resolve the same content ID, localized advice, sources and verification date

#### Scenario: An old card has no evidence or observation extension
- **WHEN** an unchanged existing behaviour card is loaded
- **THEN** it still parses and renders with its original mandatory sections and no empty source/observation panel

### Requirement: Safety and referral precede actionable guidance
Every foundation and the two new cards SHALL show a non-collapsed safety/referral block before actionable instructions. Advice SHALL avoid diagnosis, punitive/error markers, forced contact, flooding, obedience-conditioned basic needs and indiscriminate exercise escalation. Sudden change suggesting pain SHALL direct owners to a veterinarian; bite-history aggression, escalating guarding and severe separation distress SHALL direct to veterinary/qualified behavioural help instead of a DIY protocol. Persistent/intense fear and compulsive or disruptive mounting SHALL prompt professional help without a mandatory prolonged self-help trial.

#### Scenario: Puppy withdraws during exposure
- **WHEN** the owner reads world or fear guidance in PL or EN
- **THEN** it supports ending/reducing the exposure and safe retreat, never forcing or luring the puppy toward the feared stimulus, and directs marked or persistent fear to individual professional guidance

#### Scenario: Owner considers public exposure before full vaccination
- **WHEN** the owner reads socialization precautions
- **THEN** the text balances early safe experiences with the veterinarian's local infection-risk/vaccination advice, not a blanket instruction to isolate until fully vaccinated or expose without precautions

#### Scenario: Mounting may have a medical cause or interruption risk
- **WHEN** the reviewed mounting card is read
- **THEN** medical concerns and aggression risk route to appropriate professionals, without physical removal, dominance diagnosis, an automatic neutering solution or advice to wait months despite red flags

#### Scenario: Owner cannot tell why a puppy is highly aroused
- **WHEN** overarousal guidance is read
- **THEN** it presents multiple possible contexts, a needs/context check and reduced demands, not a definitive cause inferred from one behaviour or training score

### Requirement: Published guidance is traceable to verified sources and approved copy
All four foundations, both new cards and the reviewed nipping/mounting cards SHALL carry 1–5 source titles/HTTPS URLs and an actual verification date. All action/medical/referral claims SHALL have a field-level source mapping in the change's copy ledger before publication. Full supporting-page reads, independent bilingual review and explicit user approval of drafts/replacements MUST precede bundling. Source-backed copy MUST be original and MUST NOT assert veterinary endorsement. Existing unrelated approved sentences SHALL be preserved; every touched existing PL field SHALL record the corresponding EN disposition.

#### Scenario: A source is available only as a search snippet
- **WHEN** a proposed medical claim lacks a readable supporting source
- **THEN** the claim is omitted or the affected draft remains blocked, and the app does not present that snippet as verified clinical authority

#### Scenario: One source also recommends punitive methods
- **WHEN** advice is selected from a mixed source
- **THEN** only independently supported welfare-compatible claims are used and punitive passages are excluded in both languages

#### Scenario: Existing card receives a replacement
- **WHEN** a specific mounting/nipping field is proposed for change
- **THEN** its before/after text, source support and PL/EN alignment are reviewed and approved before that field changes, while other fields and stable IDs remain intact

### Requirement: Content validation rejects incomplete or broken guidance
Validation SHALL require nonblank PL/EN fields, nonempty required lists, unique prefixed guide IDs, valid references and valid evidence for the designated resources. Evidence URLs SHALL be absolute HTTPS with dotted hostnames, no whitespace/credentials and no duplicates; dates SHALL be real `YYYY-MM-DD` calendar dates not later than validation day. Missing optional behaviour extensions SHALL remain valid, but malformed present extensions MUST fail with source/field diagnostics.

#### Scenario: A resource loses a translation or link target
- **WHEN** a guide lacks its EN stop line, uses a duplicate ID or references an unknown exercise
- **THEN** validation fails with the affected source and field rather than silently falling back or hiding the link

#### Scenario: Evidence metadata is invalid
- **WHEN** evidence contains an HTTP URL, credential-bearing URL, duplicate URL, impossible date or future date
- **THEN** validation rejects the resource

### Requirement: Guidance works offline and remains usable in both languages
Hub, guides, behaviour content, disclaimer and source titles/URLs/date SHALL be bundled and readable offline without authentication. External source links SHALL be optional and failure to open them MUST NOT remove advice or alter training state. All UI labels SHALL use PL/EN localization and current in-app language switching. Phone layouts SHALL support readable long text, accessibility labels, Dynamic Type and native back navigation.

#### Scenario: Owner reads without connectivity
- **WHEN** the app has no network access and the owner browses all hub destinations and their sources
- **THEN** all advice and citation metadata remain available locally, and returning from an unavailable external source leaves the same usable screen

#### Scenario: Language changes during use
- **WHEN** the owner switches between Polish and English using the current app control and reopens guidance
- **THEN** both UI labels and content use the selected language without raw keys, missing text or different welfare boundaries

### Requirement: Browsing preserves raw history and per-context progress
Reading hub/guides/behaviour cards, opening sources and returning SHALL perform no training/participation writes or schema changes. Puppy guides SHALL be excluded from exercise seeding, recommendations and mastery. Existing exercise links SHALL retain ordinary catalogue behaviour: for an exercise never opened before, the lazy initial `position` row and its empty active set may be created exactly as via the catalogue; the links SHALL NOT modify any existing position, earned mastery, context progress or choices, SHALL NOT auto-record reps, and SHALL NOT create guide-owned sessions. Five-rep verdicts, cancellation/incomplete-set semantics, derived verdicts and per-dog/exercise/environment isolation SHALL remain unchanged.

#### Scenario: Owner browses with existing progress and a partial session
- **WHEN** a store containing two dogs, multiple exercise/environment records and an incomplete set is opened, all puppy guidance is browsed, and the same store is reopened
- **THEN** raw reps, sessions, choices, progress, participation and schema version are unchanged and no guide ID appears in scored storage

#### Scenario: Owner follows an exercise link for a never-opened exercise
- **WHEN** an owner opens a fresh exercise from guidance and returns without recording any rep
- **THEN** that exercise holds exactly the same lazy initial state (step-1/starting-environment position and empty active set) the catalogue route would have produced, with no rep recorded and no guide session

#### Scenario: Owner follows an exercise link for an exercise already in progress
- **WHEN** an exercise already has a position, a resumable partial set or a completed set awaiting an owner choice, and the owner opens it from guidance and returns
- **THEN** every existing row is byte-identical to before, no choice was applied, and returning does not mark guidance complete

#### Scenario: Verdict and interruption regressions are checked
- **WHEN** verification exercises hit counts 0–5, cancelled reps and an interrupted partial set
- **THEN** only 5/5 yields push, 3–4 yields stick, 0–2 yields drop, cancellation is failure, partial sets stay incomplete and dog/exercise/environment state stays isolated
