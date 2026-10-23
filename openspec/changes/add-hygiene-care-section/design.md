## Context

`src/content/schema.ts` defines non-scored nosework levels but no safety stop-lines; behaviour cards separately require `urgent` and `professional`. `App.tsx` stores nosework maxima in memory. Native `NoseworkRepository.swift:15–35` stores one maximum per dog/activity, not a history of attempts. Its completion-oriented comments/API names must not become care UI semantics.

Native routes are in `Pettrainer/App/Route.swift` and `RootView.swift`; catalogue sections in `Pettrainer/Features/Catalogue/CatalogueView.swift`. There is no app-wide About screen in these surfaces. The native catalogue has an existing language menu; the JS catalogue has no equivalent menu. The session's exercise-specific About block is not an app-wide advice surface.

The live `migrate-to-native-swift` design freezes original JSON bytes and checksums (decision 2, line 43); it is not yet cut over. Published specs are empty. Other active content changes are user-owned and must remain untouched except an explicitly coordinated baseline update. The requested `openspec/archive/` does not exist; actual `openspec/changes/archive/` contains only `.gitkeep`, so there is no completed artifact example to copy.

## Goals / Non-Goals

**Goals:** Seven practical, voluntary hygiene routines; visible boundaries and veterinary disclaimer; three selectable stages each; bilingual offline content and UI; honest furthest-tried participation; additive JS/native parity with preserved raw history.

**Non-goals:** See proposal. In particular no care sets/verdicts, environment ladder, treatment protocols, diagnosis, dated log, schedule, new table, dependency, migration cutover or JS deletion. Do not modify scored `handling` or its five-rep rules.

## Decisions

### 1. Participation-only care family (review choice B)

Use `src/content/data/care/<care-id>.json` as the single authoring source, mirrored byte-for-byte to native `Pettrainer/Resources/Content/`. Follow the verified flat `ContentResource` mapping: logical `care/care-paw-rinse.json` maps to `care-care-paw-rinse.json`, likewise for the other IDs. The repeated prefix is the existing family-plus-ID convention, not independently authored content or a translated ID. Add `CareRoutine`/`CareStage` types in `src/content/schema.ts`, a small `src/content/schema/care.ts` parser and `src/content/care.ts` facade; register explicit order/lookup in `src/content/load.ts`. Native uses focused `Content/Models/CareRoutine.swift`, `Content/Validators/CareValidator.swift`, `ContentLoader.swift` and `CatalogueManifest.swift`. Retain logical family paths in diagnostics/checksums and register the flat resources in Xcode.

Schema: stable `id` (`care-` namespace), `sortOrder`, supported `pose`, bilingual `names` (name/description), `tagline`, required non-empty `urgent` AND `professional` (`{pl,en}`), advisory `practices` exercise IDs, routine-level `sources` (contract in decision 6.1), and exactly three `stages`.

Care is a **separate collection with its own manifest list**; it never enters the scored catalogue. JS keeps `care` out of `CATALOGUE` and native keeps it out of `TrainingContent.catalogue`, so neither `ContentSeeder`'s exercise/step seeding (`Pettrainer/Data/ContentSeeder.swift:18–25,48–64`), the Today recommendation (`Pettrainer/App/AppModel.swift:68–69`), nor exercise-card mastery/rungs rollups (`src/features/catalogue/ExerciseList.tsx:80–85`) can observe a care entry. Reviewer A-2: this isolation is a stated contract with integration assertions in both runtimes, not an accident of lookups. Each stage has ordinal 1–3, known `gear` IDs and non-empty PL/EN `title`, `setup`, `how`, `watchFor`, `stop`. `stop` permits stage-specific hazards without hiding the routine stop-lines. No scored criterion, repetition target, prerequisite gate, pass condition, completion requirement or environment field. Reject unknown/colliding IDs, missing translations, blank stop-lines, duplicate/skipped ordinals, invalid references and gear with file/field diagnostics. Test structurally forbidden scoring/completion fields. Human copy review must also catch semantic coercion; schema validation alone cannot.

Reusing the nosework type verbatim is rejected: its safety fields are absent and its wording implies achievement. A scored extension of `handling` is rejected: welfare must not depend on finishing a nail/paw/bath or reaching 5/5. Linking `handling` is advisory only and never a prerequisite.

### 2. Routine/stage boundaries and mandatory stop-lines

Every stage is an invitation that can end before contact or before the procedure. The final stage describes a possible small action **only while participation continues**, not a requirement to complete it. All screens show `urgent` and `professional` before setup/how, never behind a disclosure. Stage-specific `stop` also precedes instructions. Universal text in each routine's bilingual safety data: withdrawal, freezing, moving/leaning away or other stress → stop contact immediately, release and allow space; restart later at easier criteria only if voluntarily offered. No restraint, hammock/sling, scruffing, pinning, trick/distraction deception, punishing growls, error markers or aversive tools. Pain/sudden change → own vet; bite history, escalating aggression or guarding → vet/certified behaviourist; severe separation anxiety also routes to professionals, not these protocols. Necessary urgent care is performed by professionals, not by forcing consent training.

| Routine | Three freely selectable stages | Routine-specific stop-line / safety boundary |
| --- | --- | --- |
| Paw rinsing | voluntary non-slip station; damp contact; brief rinse and thorough drying | Stop for pain, limping, cracks, persistent irritation or suspected injury/foreign body and consult vet. Water temperature and road-salt claims need stronger evidence before authoring. Never force access between toes. |
| Nail care | tool at comfortable distance; touch and sound practised separately; optional one tiny sliver | Stop before an uncertain quick/cut, pain or bleeding; seek professional help. Very long nails or urgent care → vet plan, not forced trimming. Handler practises on a straw first; never clip a whole nail as the task target. No sedation or medication instructions. |
| Brushing | brush introduction; one offered stroke; short coat-specific section | Pain, irritated skin, severe mats or inability to tolerate contact → groomer/vet as appropriate, vet for pain/skin changes. Never pull out mats or use scissors to cut them; do not prescribe a universal coat technique. |
| Checks | approach; separate brief looks; short individual checks | LOOK and notice only: ear odour/redness/discharge/head shaking, painful eyes, squinting/discharge, painful/cracked pads or sudden change → vet. No canal entry, deep cotton buds, OTC ear drops, eye treatments or diagnostic claims. |
| Teeth | dog-paste introduction; offered lip lift/contact; brief outer-surface brushing | Pain, bleeding, marked oral change or refusal → stop and consult vet. Dog toothpaste only, never human toothpaste; confirm authoritative source before copy. Do not force the mouth open or scrape teeth. |
| Towel | towel introduction; gentle offered contact; short blotting | Pain, skin irritation or distress → stop; vet for pain/skin changes. No trapping, wrapping to restrain or vigorous rubbing. |
| Bath | dry non-slip station; water introduced separately; necessary wash/rinse if voluntarily tolerated | Pain, skin/ear/eye concern or distress → stop and vet as appropriate. If necessary care cannot be tolerated, professional plan. Warm water, suitable dog shampoo and thorough rinse; no human shampoo, cold hose, fixed bathing schedule or medicated-shampoo protocol. Brush tangles beforehand; severe mats need professionals. |

Stop/referral details about eyes, oral bleeding and towel skin safety are conservative proposed boundaries, not newly verified clinical claims; implementation must verify them against authoritative sources along with all authored copy. Do not turn these limits into treatment steps.

### 3. Disclaimer: one key per runtime, reused at visible surfaces

Use `care.disclaimer` in `src/i18n/locales/pl.ts`, `en.ts` and native `Resources/Localizable.xcstrings` (not repeated in routine JSON or hardcoded per view). Proposed text:

- **PL:** „To nie jest porada weterynaryjna. Potrzeby Twojego psa mogą być inne. Przed zastosowaniem tych wskazówek najlepiej skonsultować się ze swoim lekarzem weterynarii.”
- **EN:** “This is not veterinary advice. Your dog's needs may differ. Before using this guidance, it is best to consult your own veterinarian.”

Render the full wrapping, legible statement under the care section heading in both catalogues and under the title on **every** care routine screen, followed by the urgent/professional block before stage instructions. No dismissal, tooltip, truncation or acknowledgement gate. Also reuse the same key in the existing native catalogue menu after the language items (a readable informational line, not an endorsement badge). Verify that Menu actually shows the complete text at phone size/large type; if it cannot, pause for a bounded presentation adjustment rather than silently truncate. Do not create a new JS menu/About route solely for this line, or insert it into unrelated exercise About text. The always-visible section and routine statements are primary; the menu is supplementary.

Additional UI keys under `care` cover heading, subtitle, stages, `furthestTried` (ordinal/total interpolation), `markTried`, untried state, stop headings and saving errors. Use “Najdalszy próbowany etap: … / Furthest stage tried: …” and “Próbowaliśmy tego etapu / We tried this stage”; never “opanowane/mastered”, “zaliczone/passed” or “completed”. Localized cue names remain content, IDs never translate.

### 4. Explicit participation, minimal persistence, honest limits (C-1)

Stage selection and reading do not write progress. An explicit “We tried this stage” action records the selected ordinal even when the dog declined contact; the owner can stop without recording anything. Selecting stage 3 immediately is allowed. Records indicate neither tolerance nor safety to attempt the next procedure. No timer, completion confetti or implied permission to escalate.

Reuse the **storage pattern**, not completion semantics: existing `nosework_progress` in `Pettrainer/Data/Migrations.swift:177–183` has primary key `(dog_id, activity_id)` and no activity FK, so namespaced `care-*` IDs fit without schema changes. Add a small `Pettrainer/Data/CareRepository.swift` facade around `NoseworkRepository` with validated known care IDs/ordinals 1–3 and `highestStageTried` / `recordStageTried` vocabulary. Do not rename the nosework API or rewrite applied migrations just for care. Care reload iterates only the care manifest; nosework reload still iterates only nosework, preventing cross-family badges. Existing nosework IDs must not collide with care IDs (validate globally).

Native `AppModel` gets separate care state and an error-aware write: update its published maximum only after success, keep prior state on failure, offer localized retry, and tolerate repeat taps/re-entry with max upsert. Do not copy the current nosework method's `try?` then optimistic update. An interrupted write yields the previous or new committed maximum, never a fake completion. The single `updated_at` is not an attempt history and is not presented as one.

JS `App.tsx` mirrors existing in-memory nosework participation with a separate care map and explicit selected stage. It is a runnable **reference**, not a promise of durable JS storage; it must not regress any existing persistence. Native runtime provides durable offline care participation across relaunch. No new DB table/migration is required by these requirements. A dated log would require new approved requirements plus a versioned migration and preservation tests; it is deliberately out of scope.

### 5. Screens, equipment and accessibility

Add `src/features/care/CareScreen.tsx` and native `Pettrainer/Features/Care/CareView.swift`, reusing existing native controls, theme, gear rows and supported still dog poses, not scored session components. Catalogue links and all stages remain available at zero participation. Wire `App.tsx` and `src/features/catalogue/ExerciseList.tsx`; native `Route`, `RootView`, `AppModel`, `CatalogueView`. Test long checks title and stop-lines in PL/EN, VoiceOver ordering, Dynamic Type, scrolling and touch targets (44pt native).

**Advisory `handling` link invariant (reviewer A-1).** The existing exercise route genuinely creates a pending `session` row when none exists — `AppModel.makeSessionModel` (`Pettrainer/App/AppModel.swift:111–123`) calls `SessionRepository.resumableSet`, which inserts a `'active'` row with zero reps (`Pettrainer/Data/SessionRepository.swift:72–79`). Care therefore does **not** promise that navigating to `handling` leaves the `session` table untouched; that would require a read-only duplicate screen, which this change rejects as needless surface. The guarantee is narrower and checkable: (a) the care mark-tried action writes only the namespaced participation row and never `session`, `rep`, verdict or context progress; (b) opening the advisory link behaves exactly as opening the same exercise from the catalogue does today — at most that exercise's own empty pending set at the dog's current position, no rep rows, no verdict, no step/environment movement; (c) navigating back records nothing further. A fresh-state navigation test asserts all three, and the wording is honest that the pending-set row itself is pre-existing product behaviour rather than care-caused history change.

Existing gear vocabulary verified in `src/ui/Gear.tsx`, `src/content/schema/checks.ts` and native `Content/Vocabulary.swift`: reuse `treats`, `mat`, `towel`, `clippers`, `bowl`. Add stable `brush`, `toothbrush`, `dog-toothpaste`, `dog-shampoo`, `styptic` to both vocabularies, PL/EN labels and JS/native `GearIcon`/`GearIconView`. Render simple matching geometric icons with accessible labels; use existing dog poses, no new handling illustration suggesting restraint. `styptic` is optional preparation vocabulary, not mandatory equipment to proceed, a product recommendation or a bleeding-treatment protocol; do not prescribe its use without verified source and vet guidance. New icons/labels must be tested even if an authored stage does not use one.

### 6. Evidence and authoring gates

The parent supplied the following research evidence; this planning subagent did not re-fetch it. Preserve exact bibliographic URLs/attribution during implementation after verification, without invented endorsements or “vet approved” claims. Source references must work as offline provenance, not require opening a website for essential instructions.

- **VCA, “Taking the Stress out of Nail Trimming for Dogs”** (parent reports full read; Ellen Lindell VMD DACVB and behaviour technicians): tiny touch/sound increments paired with food, non-slip surface, short sessions, one tiny sliver; stress means slow down/stop; no tricking, restraint, hammock or punishment. Very long nails/anxiety require the veterinarian's plan, not forced grooming while consent training is unfinished. Do not reproduce medication advice as home instructions.
- **VCA, “Grooming and Coat Care for Your Dog”** (parent reports full read): coat-specific care, tangles before bathing, no scissors on mats, severe mats/pain → professional, warm water/dog shampoo/thorough rinse, bathing frequency depends on the individual; no universal timetable or medical shampoo protocol here.
- **VCA, “Ear Infections in Dogs (Otitis Externa)”** (parent reports full read): symptoms need vet diagnosis; no self-treatment drops or canal intervention, potentially unsafe with damaged eardrum. This supports a looking-only routine, not ear cleaning.
- **Authoritatively confirmed for the xylitol hazard (full page read): Pet Poison Helpline, “Xylitol”** — lists toothpaste among xylitol-containing products and states life-threatening hypoglycaemia (possibly within 10–15 minutes) and acute liver failure in dogs. This supports a “never human toothpaste” hazard statement. The VCA True/False toothpaste page itself is still a moved-page snippet, so the positive instruction “use a dog enzymatic toothpaste” keeps its confirmation gate.
- **WEAK / BLOCKING COPY GATE — dog toothpaste product type:** what remains unconfirmed by a full-page authoritative read is the recommendation wording for dog-specific enzymatic paste. Confirm before writing the teeth copy. No implied full-page verification.
- **WEAK / BLOCKING COPY GATE — paw rinsing:** road-salt, lukewarm rinse/between-toes/dry advice currently rests on practice blogs/groomer guides. Obtain a stronger veterinary citation before writing this copy. Do not convert weak sourcing into a claimed endorsement.
- Cooperative care handouts (Every Dog Austin, Tails of Connection, Sit Pretty, canine mind; parent reviewer reports retrieval) support start-button/stationing, tiny steps and stopping on refusal. They are practical secondary sources, not veterinary review of this app. Fear Free's bathing page advertises protocols rather than publishing them: do not cite it as the source of unpublished steps.

Record final source URLs, claims supported and limitations in this change's notes; new medical/safety details need the same review. Both weak evidence gates block affected content authoring, not just final release. Independent welfare review of all bilingual authored content is still required.

#### 6.1 Source-reference data contract (reviewer A-3)

So the two independently written validators cannot drift, `sources` is a routine-level array of **1–5** objects, each exactly `{ title, url }`:
- `title`: trimmed non-empty, ≤120 characters, no line breaks;
- `url`: absolute `https://` only (reject `http:`, `file:`, `javascript:`, relative or protocol-free strings), must contain a hostname with at least one dot, no whitespace and no embedded credentials (`@` before the path is rejected);
- duplicate `url` values inside one routine are rejected.

Per-stage `sources` are rejected as an unknown field; provenance belongs to the routine. Both `src/content/schema/care.ts` and `Pettrainer/Content/Validators/CareValidator.swift` MUST carry matching positive and negative fixtures: empty title, blank/padded-only title, `http://` URL, `ftp://`, whitespace-containing URL, credential-bearing URL, missing `title`, unknown extra field, and an empty/zero-source routine. A routine whose copy depends on the two weak gates may not be authored even if its `sources` array is structurally valid — structural validity is not evidence of a strong source.


### 7. Native migration coordination and byte parity (C-3)

Before implementation writes shared files, the parent must coordinate an explicit additive extension with the owner of `migrate-to-native-swift`. Keep its original source commit and checksums as provenance; do not regenerate history as though care existed in that snapshot. Preserve every pre-existing file's hash (including `handling`). The current baseline inventory is stale relative to newer native resources in places; inventory actual current files and explain pre-existing drift instead of automatically accepting it.

Order: approve care plan → agree baseline extension/hold migration cutover → schema/vocabulary → author seven canonical JS files once → mechanically mirror bytes → integrate both runtimes → update reviewed manifests/checksums/locale inventory → parity and welfare tests → independent final review. Integration owns shared project registration and baseline files serially. Migration may continue unrelated work, but no overlapping writes to loader/routes/catalogue/locales/baseline; its JS deletion/cutover waits until this additive parity work is reconciled. If a freeze exception cannot be agreed, pause this change rather than edit frozen data or drop the JS requirement.

The approved update explicitly covers migration `baseline/gen_manifest.py`, `parity-data.json`, `parity-manifest.md`, `locale-keys.json`, native `CatalogueManifest.swift`, `PettrainerTests/ContentChecksums.swift`, and tests/count assertions plus Xcode resource membership. Append documented care provenance and expected new file/locale counts; review the resulting diff and verify unchanged old hashes. Never hand-edit two JSON copies separately or merely update expected hashes to hide a mismatch. Mirror comparison must fail when either side differs or is missing, and load all seven offline. Baseline data/checksum changes are implementation tasks, not changes performed by this proposal.

## Risks / Trade-offs

- [Participation mistaken for consent/mastery] → furthest-tried wording, no completion requirement, withdrawal stops, stage 3 never guarantees a procedure is safe.
- [Shared nosework table has a misleading name] → tiny care facade and disjoint stable IDs; avoid a new table solely for naming. Test two dogs/two routines and existing nosework rows.
- [Three stages compress months of practice] → explain tiny substeps/short sessions and repeat any easier stage without timetable; never guarantee speed or feasibility.
- [Disclaimer mistaken for sufficient clinical safety] → mandatory specific stop-lines, conservative referral boundaries and source/welfare review; disclaimer never replaces them.
- [Native freeze/checksum churn] → reviewed additive provenance, exclusive integration ownership and parity checks before migration cutover.
- [Unknown platform checks] → report actual simulator/device availability; web success is not native SQLite/lifecycle evidence.

## Migration Plan

No schema migration: reuse existing native participation table after verifying the above constraints still hold at apply time. Add bundled content, read/write namespaced rows; upgrade preserves all sessions, reps, mastery, positions and nosework. Verify an existing seeded native DB before/after recording care and after relaunch. On failed write retain old maximum and show retry, without data deletion. Rollback of code leaves unknown namespaced rows untouched; older nosework reload ignores them. Do not delete a DB or rewrite migrations to roll back content.

## Delegation Plan

Planning and read-only independent review use GPT-6.1 Sol. Implementation is exclusively the build agent selected by `/opsx-apply add-hygiene-care-section`, Flash Next (`swissquant-local/vision-flash`); unavailable routing is a reported blocker, not a silent fallback. This subagent does not delegate further.

Use one sequential integration owner because schema → JSON → loader/screens/storage → baseline verification are dependent and share files with the migration. A bounded gear-artwork assignment may be separate only after vocabulary is fixed and ownership of `src/ui/Gear.tsx` and native `GearIconView.swift` is exclusive; integration retains vocabularies/locales/project registration. No overlapping writes or recursive subagents. Before implementation, an independent reviewer reviews these artifacts; the parent presents stable numbered findings and asks which to address, one question at a time. Add only selected review fixes, then obtain explicit proposal/implementation approval. Repeat independent review after verification; do not silently implement its findings.

## Open Questions / Gates

No further product question blocks proposal creation. Blocking implementation gates: parent reviewer/user approval, coordinated baseline freeze exception/ordering, stronger toothpaste/paw evidence before respective authoring, and verification of any additional clinical safety claims. Simulator/device destinations and full menu text layout remain verification gates. Do not treat pending work or supplied research as checks run locally.
