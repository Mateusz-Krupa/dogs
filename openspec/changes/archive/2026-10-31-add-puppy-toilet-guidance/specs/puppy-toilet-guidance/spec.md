## ADDED Requirements

### Requirement: Indoor accident guidance distinguishes before, during and after
The `puppy-toilet` guide SHALL place a short response near the top, after visible disclaimer/safety/avoidance blocks and before detailed sections. It MUST distinguish pre-toileting signals, ongoing urination and an accident discovered afterwards. Pre-toileting signs SHALL prompt a calm outdoor opportunity. Ongoing toileting SHALL be allowed to finish without startling, punitive/error sounds, forced interruption or handling. An already discovered puddle SHALL prompt quiet cleanup, not punishment. The explanation SHALL describe how punishment can make toileting in front of people unsafe for the dog rather than teach the desired location.

#### Scenario: Puppy sniffs and circles before urinating
- **WHEN** the owner reads the immediate response in PL or EN
- **THEN** it recommends calmly taking the puppy to a suitable outdoor spot before toileting rather than waiting for a perfectly learned signal

#### Scenario: Puppy is already urinating on a rug or object
- **WHEN** the owner reads the ongoing-accident response
- **THEN** it says to let the dog finish without scolding, clapping, lifting mid-stream or dragging outside, followed by calm cleanup and adjusted future opportunities

#### Scenario: Puddle is found later
- **WHEN** the owner was absent or did not notice the accident
- **THEN** advice excludes retrospective punishment, nose rubbing and interpretations of spite or proof of guilt

### Requirement: Outdoor learning is concrete and gradual
The guide SHALL explain developing bladder control and learning location/substrate through repeated opportunities and rewards. It SHALL cover outings after sleep, eating/drinking, play/excitement, before bed and at individual signals; accompanying the puppy to a quiet suitable spot; prompt reward after finishing while still outside; an optional quiet toileting cue; unsuccessful outings; supervision; and gradual increases in freedom/spacing only as the dog copes. It MUST NOT prescribe age-to-hours formulas, forced holding, a fixed success deadline or withholding basic needs.

#### Scenario: Owner wants the puppy to understand what earned the reward
- **WHEN** reward timing and an optional cue are explained
- **THEN** the treat follows finished toileting near the outdoor spot, not the return indoors or an interruption mid-stream, and the cue is first associated with the action rather than repeatedly demanded

#### Scenario: Puppy does nothing outside then urinates indoors
- **WHEN** the owner reads troubleshooting
- **THEN** it offers a short calm opportunity, return with supervision and another opportunity soon/at signals, with quieter safer conditions for distraction/fear rather than punishment or indefinite waiting

#### Scenario: Puppy has a setback while gaining freedom
- **WHEN** accidents recur
- **THEN** the guide recommends easier management and more appropriate opportunities, not stricter holding targets or a verdict that the dog has failed

### Requirement: Everyday constraints and cleanup have humane alternatives
The guide SHALL address night needs, absences exceeding the puppy's current ability, temporary indoor pads and a gradual outdoor goal, plus odour-removing cleanup using a suitable pet-urine product per label. It MUST preserve water access, rest and a usable toileting option; no forced crate-holding protocol, crying-it-out, chemical recipe, cleaner mixing or branded-product requirement SHALL appear. Specific pad-transition mechanics MUST have verified support before publication. Local infection-risk/vaccination precautions SHALL be referred to the owner's veterinarian without a blanket instruction to isolate or use unsafe public ground.

#### Scenario: Owner lives in an apartment and currently uses pads
- **WHEN** pad guidance is read
- **THEN** it explains the difference between indoor substrate learning and outdoor learning without shame, and adds outdoor opportunities/rewards without abruptly removing the only usable toilet

#### Scenario: Puppy needs to toilet overnight or during a long absence
- **WHEN** management guidance is read
- **THEN** it recommends appropriate toilet access/calm night trips and arranged human help or a suitable fallback, not water restriction or confinement to force holding

### Requirement: Medical triage precedes training advice
The guide SHALL display non-collapsed safety guidance before instructions, distinguishing urgent inability to pass urine/repeated unsuccessful straining from concerns needing prompt veterinary assessment, including pain, blood, sudden regression or concerning changes in frequency/thirst. Exact referral wording SHALL be verified against full authoritative sources. The guide MUST NOT diagnose, recommend home treatment or require a self-help trial before medical assessment. Persistent difficulty and severe separation distress/aggression red flags SHALL route to appropriate veterinary/qualified behavioural help rather than a DIY fix.

#### Scenario: Dog strains repeatedly without producing urine
- **WHEN** the owner opens the guide
- **THEN** visible safety copy directs urgent/emergency veterinary contact instead of another toilet-training attempt

#### Scenario: Previously clean dog suddenly soils indoors
- **WHEN** regression guidance is read
- **THEN** it directs veterinary assessment rather than assuming normal puppy development, marking, disobedience or a need for stricter training

### Requirement: Detailed toilet guidance is structured, localized and write-free
The guide SHALL include the quick response and eight titled sections covering learning, outdoor routine, reward/cue, unsuccessful outings, signals/freedom, nights/absence, pads and cleanup/setbacks. All advice, headings, disclaimer and citation metadata SHALL be bundled in PL/EN and remain usable offline. The guide MUST have no practices links, scoring, completion, timers, diary or storage side effects, and MUST remain outside seeded exercises, recommendations and mastery. Existing raw history, participation and per-dog/exercise/environment state SHALL be preserved; five-rep rules SHALL remain unchanged.

#### Scenario: Owner browses offline and reopens with existing sessions
- **WHEN** both locales are browsed against a store containing two dogs, multiple environments, raw reps, a partial set and a set awaiting choice, and that store is reopened
- **THEN** all guide content/citations remain readable, database rows and schema version are unchanged, and no guide-owned sessions/progress exist

#### Scenario: Owner reads on a phone with larger text
- **WHEN** the guide is viewed in either locale using larger Dynamic Type and accessibility navigation
- **THEN** the quick response precedes detailed headings, full paragraphs/sources can be reached without truncation, and back/re-entry works without completion state
