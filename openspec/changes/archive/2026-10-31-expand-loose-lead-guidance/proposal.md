## Why

Owners need practical guidance on equipment, sniffing stops, and dogs that refuse to walk, not only instructions for stopping pulling. The existing loose-lead exercise omits these cases and contains categorical claims that can encourage frustrating, over-controlled walks.

## What Changes

- Recommend a comfortable fixed-length lead (around 2 m, adjusted to the setting and dog) and well-fitting, non-restrictive harness for training; explain why an unlocked retractable lead makes a clear slack-lead signal harder.
- Explain that sniffing is normal enrichment, not disobedience, and distinguish short training stretches from ordinary exploratory walking.
- Add practical PL/EN troubleshooting for prolonged sniffing, difficulty moving on, and refusal to walk, with pain/fear safeguards.
- Revise the two existing troubleshooting cards and nearby categorical PL/EN claims without changing exercise criteria or progression.
- Extend the existing `puppy-first-exercises` foundation with bilingual guidance on eating things off the floor (dropped food at home, found items outdoors), keeping `leave` before pickup separate from `drop` after pickup, linking to the canonical exercises, and routing ingestion/guarding red flags to professionals first.

## Capabilities

### New Capabilities
- `loose-lead-guidance`: Source-supported, bilingual equipment and walk-troubleshooting guidance within the existing loose-lead exercise.
- `puppy-scavenging-guidance`: Source-supported, bilingual floor-scavenging advice inside the existing puppy foundation, with escalation ahead of practice.

### Modified Capabilities
None. Existing bilingual-copy and `puppy-start-guidance` requirements remain in force: four foundations keep their stable IDs, exercise links are optional and not capped, and no second puppy copy of the scored exercises is created.

## Impact

Application scope is `exercises-leash.json`, `mistakes-leash.json` and `puppy-puppy-first-exercises.json`, their three `ContentChecksums` entries, focused assertions in existing `ContentLoaderTests`/`ContentValidatorTests` and narrow expectation updates in `PuppyContentTests`. Reuse existing description/setup/note, troubleshooting disclosures, guide sections and evidence blocks; no new screens, schemas, dependencies or runtime networking. Evidence and approved copy live in this change.

Release: TestFlight is the approved destination. Before any archive/export/upload the exact release-tree scope is inventoried and approved separately (R-4), because the working tree carries unrelated work.

Non-goals: no new scored steps, cue IDs, environment policy, verdict changes, database changes, content gating or unrelated copy sweep. Offline history and per-dog/exercise/environment progress are preserved. Implementation requires independent plan review and explicit user approval, then `/opsx-apply expand-loose-lead-guidance` (Flash Next).
