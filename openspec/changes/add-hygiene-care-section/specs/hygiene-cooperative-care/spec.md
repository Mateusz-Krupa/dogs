## ADDED Requirements

### Requirement: Seven freely accessible care routines
The application SHALL offer the seven stable routine IDs and PL/EN names in the proposal under Higiena i pielęgnacja / Hygiene & care, in that order, in both the JS reference and native application. Each routine MUST have exactly three freely selectable stages. Access MUST NOT depend on participation, a scored exercise, a prerequisite or a veterinarian acknowledgement checkbox.

#### Scenario: First use without training history
- **WHEN** an owner with no progress opens the catalogue and selects any care routine
- **THEN** the routine and each of its three stages are available, including stage 3, without completing an earlier stage or `handling`

#### Scenario: Routine stage coverage
- **WHEN** the bundled seven routines are validated
- **THEN** their stages cover voluntary station/damp contact/rinse-and-dry; nail tool/separate touch-and-sound/tiny sliver; brush introduction/stroke/coat section; check approach/separate looks/individual checks; dog paste/lip contact/outer brushing; towel introduction/contact/blotting; and dry bath station/separate water/necessary wash-and-rinse respectively

### Requirement: Voluntary participation without procedure targets
Care instructions SHALL make voluntary participation and stopping on withdrawal explicit in both locales. No stage SHALL require completing a paw, nail, coat section, mouth or bath, enduring contact, meeting a repetition target or passing a stage. The final-stage action SHALL be conditional on continued participation. Refusal/freezing MUST stop contact immediately, not trigger correction or restraint.

#### Scenario: Dog withdraws before a tiny nail sliver
- **WHEN** a dog freezes or withdraws before tool contact or cutting
- **THEN** the displayed guidance says to stop contact immediately and allow space, without holding the paw, distracting to finish, counting a failure or requiring a cut before leaving

#### Scenario: Unsafe techniques are excluded
- **WHEN** PL/EN copy and illustrations for every stage are reviewed
- **THEN** none recommends forced restraint, hammock/sling, scruffing, pinning, deception, punishment of growling, aversive tools or error markers; an optional reference to `handling` never overrides refusal

### Requirement: Required visible safety stop-lines
Every routine MUST contain non-empty bilingual `urgent` and `professional` fields and each stage a bilingual `stop` field. Both runtime screens SHALL render routine urgent/professional and selected-stage stop-lines before instructions, without disclosure or scrolling past instructions first. Pain/sudden change, bite history/escalating aggression or guarding, and severe separation anxiety SHALL route to a veterinarian/certified behaviourist as appropriate. Necessary urgent care SHALL route to professionals instead of forced consent training.

#### Scenario: Routine opened directly on a later stage
- **WHEN** an owner opens any routine and selects stage 3 in either locale
- **THEN** the routine red flags, professional referral and that stage's stop-line precede setup/how in reading and accessibility order

#### Scenario: Safety translation omitted
- **WHEN** a routine or stage lacks an EN/PL stop-line, has blank urgent/professional text or contains an invalid practice reference
- **THEN** both validators reject it with a source and field diagnostic rather than accepting an unsafe partial translation

### Requirement: Routine-specific professional boundaries
All routines SHALL include the specific safety limits in the design's routine table. Home checks SHALL be looking/noticing only, never diagnosis, canal cleaning, deep cotton buds, drops or treatment. Copy SHALL refer pain, bleeding, marked changes, severe mats and necessary intolerable procedures appropriately; it SHALL NOT prescribe medication/sedation, human shampoo, human toothpaste or a universal bathing schedule.

#### Scenario: Ear signs or painful eyes during a check
- **WHEN** an owner reads the checks routine after noticing ear odour/discharge/head shaking or a painful/squinting eye
- **THEN** the stop-line directs them to their veterinarian and no next instruction offers ear drops, canal entry, eye treatment or a DIY diagnosis

#### Scenario: Procedure cannot be safely continued
- **WHEN** nail location is uncertain, grooming reveals severe mats/irritated skin, or a necessary bath cannot be tolerated voluntarily
- **THEN** the content stops the relevant home procedure and directs professional help rather than finishing by force, cutting mats with scissors or supplying medication instructions

### Requirement: Shared visible veterinary disclaimer
The full PL/EN text proposed in design decision 3 SHALL be stored under one reused UI key `care.disclaimer` per runtime catalogue, not duplicated in routine JSON. It MUST state that this is not veterinary advice, individual needs may differ, and consulting one's own veterinarian before use is best. It SHALL appear at the care section header, every care routine screen and the existing native catalogue menu, legibly and without truncation/dismissal. No veterinary approval or endorsement SHALL be implied. No new JS About/menu surface is required.

#### Scenario: Locale and route changes
- **WHEN** the owner views the care section, each routine and the native menu in PL and EN
- **THEN** each relevant surface displays the full statement in the chosen language, sourced from `care.disclaimer`, and routine instructions follow its safety block

### Requirement: Honest furthest-tried tracking
Care SHALL have no five-rep set, hit/miss, verdict, score, environment ladder or mastery flag. Selecting/reading a stage MUST NOT record participation. Only an explicit tried action SHALL record the maximum tried ordinal 1–3 per dog and routine, labelled “Najdalszy próbowany etap / Furthest stage tried”, never mastered/passed/completed. This SHALL NOT be represented as a dated history or evidence of tolerance.

#### Scenario: Reading then leaving
- **WHEN** an owner selects stage 3, reads it and leaves without marking tried
- **THEN** the stored/native and displayed maximum remain unchanged and no session, rep or verdict is created

#### Scenario: Earlier stage after later attempt
- **WHEN** dog A has tried stage 3 in care-nails and explicitly marks stage 1 tried
- **THEN** its maximum remains 3, other routines, dog B and nosework remain unchanged, and no mastery/completion badge appears

### Requirement: Offline participation and data preservation
All care content, icons, stop-lines and translations SHALL be bundled and available without network/authentication. Native tried maxima SHALL survive relaunch using existing namespaced participation storage with no new table or migration. JS reference participation SHALL match its existing in-memory nosework lifetime without claiming durable history. Writes MUST be acknowledged only after commit; failures MUST preserve the prior maximum and provide localized retry. Existing raw reps, incomplete sessions, nosework and dog/exercise/environment progress SHALL remain intact.

#### Scenario: Native offline relaunch
- **WHEN** dog A marks stage 2 tried offline, the app exits and reopens
- **THEN** native care-nails still reports furthest stage tried 2 for A, dog B remains separate, and all care instructions are available offline

#### Scenario: Failed or interrupted save
- **WHEN** a tried write fails, is tapped twice or is interrupted before acknowledgement
- **THEN** failure does not display an uncommitted maximum, retry is localized/idempotent, and relaunch reads the old or new committed maximum without resetting any database or inventing an attempt log

### Requirement: Typed bilingual content and equipment parity
Both loaders/validators SHALL enforce exactly seven known care IDs, unique cross-family IDs, three contiguous stages, valid practice/gear references and complete non-empty PL/EN safety/instruction fields. Each routine SHALL carry 1–5 routine-level `sources` of `{ title, url }` with a trimmed non-empty `title` (≤120 characters) and an absolute `https://` URL containing a dotted hostname, no whitespace and no credentials; per-stage sources SHALL be rejected. They SHALL reject care scoring, environment, completion and gating fields. The five new gear IDs `brush`, `toothbrush`, `dog-toothpaste`, `dog-shampoo`, `styptic` SHALL have PL/EN labels and corresponding icons in both runtimes, alongside reused existing equipment. Controls and text SHALL remain usable at phone size with accessible reading order and native 44pt touch targets.

#### Scenario: Invalid source reference
- **WHEN** a routine omits `sources`, has a blank title, an `http://`, `ftp://`, whitespace- or credential-containing URL, a duplicate URL, or a `sources` field on a stage
- **THEN** both the JS and native validators reject it with a source/field diagnostic, and matching negative fixtures exist in both test suites

#### Scenario: Malformed care resource
- **WHEN** a file has duplicate/skipped stage ordinals, unknown gear, missing copy, unknown exercise links, colliding IDs or scoring/completion fields
- **THEN** both validation paths reject it with useful source/field diagnostics

#### Scenario: Long Polish content and gear
- **WHEN** the checks routine and every new equipment icon are viewed with large text and accessibility enabled in PL/EN
- **THEN** titles, disclaimer and stop-lines wrap without being hidden, stage controls remain usable, and gear has correct localized accessible labels without implying medical approval

### Requirement: Verified sources and single-authored resource parity
Care copy SHALL retain source attribution without endorsement claims. Weak toothpaste and paw-rinsing evidence MUST receive authoritative confirmation before affected copy is authored. JSON SHALL be authored once in `src/content/data/care/` and mirrored byte-identically into native resources. A separately reviewed additive migration-baseline extension SHALL record new inventory, locale keys, hashes and provenance while preserving all prior resource hashes. This change SHALL NOT perform JS deletion or migration cutover.

#### Scenario: Weak evidence not resolved
- **WHEN** implementation has only the moved toothpaste snippet or practice/groomer road-salt sources
- **THEN** authoring of the affected guidance remains blocked and notes record the limitation rather than claiming full-source verification or veterinary approval

#### Scenario: Resource mismatch or stale inventory
- **WHEN** either runtime's care bytes differ, a resource is missing, a prior hash changes, or expected inventory omits a care resource
- **THEN** targeted parity validation fails; updating expected checksums alone cannot satisfy review without the canonical mirror and approved provenance update

### Requirement: Existing scored training remains unchanged
Care SHALL live in its own collection and manifest list and SHALL NOT enter the scored catalogue (`CATALOGUE` in JS, `TrainingContent.catalogue` in native), the seeded exercise/step inventory, the Today recommendation, or any mastery/rungs rollup. The scored `handling` resource, training domain and raw-history semantics SHALL remain unchanged. Care links to `handling` SHALL be advisory-only. Training SHALL continue to derive verdicts from exactly five raw reps: 5/5 push, 3–4 stick, 0–2 drop; cancelled reps fail and unfinished sets produce no completed verdict. Progress SHALL remain isolated per dog/exercise/environment.

#### Scenario: Care use alongside a partial set
- **WHEN** care is opened and a stage is marked tried alongside a seeded incomplete training session and existing context mastery
- **THEN** the raw reps, session lifecycle, per-context progress and `handling` bytes are unchanged, and the care action itself writes no `session`, `rep`, verdict or context-progress row

#### Scenario: Advisory exercise link behaves like the catalogue route
- **WHEN** an owner opens the advisory `handling` link from a care screen with no pending set and returns to care
- **THEN** the exercise route may hold that exercise's own pending set at the dog's current position with zero reps, exactly as opening it from the catalogue does today, with no rep, verdict or step/environment change attributable to care

#### Scenario: Care stays out of scored surfaces
- **WHEN** either runtime starts with the care resources present and the app computes its recommendation, catalogue rows, seeded exercise/step counts and schema version, before and after care is read or marked
- **THEN** the recommended exercise, scored catalogue membership, seeded exercise/step inventory, mastery/rungs rollups and schema version are identical, and no care identifier appears in any scored list

#### Scenario: Training regression guard
- **WHEN** targeted verdict/progression tests run for hit counts 0–5, cancelled reps, incomplete sets and dog/environment boundaries
- **THEN** existing domain expectations pass, including 4/5 remaining stick rather than push
