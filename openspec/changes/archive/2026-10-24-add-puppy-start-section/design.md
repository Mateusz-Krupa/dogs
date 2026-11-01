## Context

The native catalogue currently renders exercises, care, nosework and problems. `Route`/`RootView` own navigation; `TrainingContent`/`ContentLoader` and `CatalogueManifest` own validated bundled content. `ProblemView` already enforces urgent → avoid → now → work before practice links and professional guidance. `BehaviourIssue` currently has neither source metadata nor a separate observation section. `CareSource` and `CareValidator` offer an existing title/HTTPS validation pattern, but care stages/participation persistence are not a fit for educational reading.

The graph query returned no matching Swift symbols and semantic results included retired TS paths; direct reads of the current native files settled integration decisions. Active migration/care changes and user edits share several target files. Only this change's OpenSpec artifacts are being written at proposal time.

## Goals / Non-Goals

**Goals:** A discoverable puppy starting point; four short foundations; two reusable situation cards; original source-backed bilingual guidance; explicit withdrawal/referral rules; no training or history side effects from reading.

**Non-Goals:** Diagnosis, clinical treatment plans, fear-exposure ladders, age gates, developmental guarantees, new scored exercises, progress tracking, data migration, backend, telemetry, fixed daily sleep/activity prescriptions, medication or neutering recommendations. Do not redesign existing catalogue sections or add an illustration framework.

## Decisions

### 1. One compact hub, two existing destination families

Add one prominent hub row before `exerciseSection` in `CatalogueView`, not another long list of eight cards at root. Add `Route.puppyStart` and `Route.puppyGuide(guideId:)` with small `PuppyStartView` and `PuppyGuideView` files. Reuse `Theme`, card styling, native back navigation and existing `Route.problem`/`Route.exercise`.

Hub order:

1. Localized title, short purpose and educational/not-veterinary-care disclaimer.
2. "Help now": `overarousal`, `fear-withdrawal`, `nipping`, `mounting` links, in that order.
3. "Everyday foundations": `puppy-rest`, `puppy-world`, `puppy-play`, `puppy-first-exercises`, in that order.

No age/profile setup is required, and adult-dog owners can open everything. Add the two new behaviour entries immediately before `alone`, preserving all existing entries' relative order. Do not copy `nipping`/`mounting` into a puppy namespace. Existing topic-specific `noise`, `traffic` and `reactivity` cards remain intact; the new fear card gives general safety orientation, not a second treatment protocol.

Alternative rejected: four new top-level catalogue sections, a multi-week curriculum or a symptom wizard. They add navigation and false diagnostic certainty without serving the first release.

### 2. Small read-only guide shape, separate from scored content

Add `PuppyGuide` and `PuppyGuideValidator` using `Localized`/`Checks`. Proposed required fields: stable `id` (prefix `puppy-`), integer `sortOrder`, bilingual `names` (name/description), `urgent`, `avoid` (nonempty list), `actions` (nonempty list), `observe` (nonempty list), `professional`, `practices` (possibly empty exercise-ID list), and `evidence`.

Render title/description/disclaimer, then urgent → avoid → actions → observe → professional → optional practice links → sources. Safety appears before every actionable block; it is not collapsed. There is no score, stage, timer, completion button or saved reading state. The first-exercises guide links only to existing `name`, `look` and `mat`; other guides can have no exercise links. Meeting basic needs is never conditional on a cue.

Register four resources through a separate `CatalogueManifest.puppy` and `TrainingContent.puppyGuides` collection/lookup; extend collision and reference checks. Family `puppy` plus ID `puppy-rest` yields `puppy-puppy-rest.json`, following the current flat family-prefixed bundle convention. Do not seed these IDs as exercises, recommend them as scored work or include them in mastery rollups.

Alternative rejected: reuse `CareRoutine` and its participation storage. Three stages and "tried" semantics are inappropriate for reading and fear/rest guidance.

### 3. Additive evidence and observation support for selected behaviour cards

Use a small `GuidanceEvidence` value containing a nonempty array of 1–5 `{title, url}` sources and one actual calendar date `verifiedOn` (`YYYY-MM-DD`, no future dates). Reuse the current `CareSource` value shape and URL-checking pattern rather than refactoring all source consumers. URLs must be absolute HTTPS, have a dotted hostname, contain no whitespace or credentials and be unique within the evidence list. Source titles are nonempty original publication titles; UI section labels are localized. The date is the date of an actual supporting-page read, not an invented clinical review date.

Extend `BehaviourIssue`/`BehaviourValidator` with optional `evidence` and optional bilingual `observe`. Old cards without them continue to parse and render exactly as before. If present, both locales of observe are required and nonempty; malformed evidence is rejected rather than ignored. Integration validation requires both fields on `overarousal`/`fear-withdrawal` and evidence on the reviewed `nipping`/`mounting` cards. Update fixtures/call sites compatibly, with default absent values where needed; do not backfill every behaviour resource.

Keep `ProblemSections.order` unchanged. Render optional observation guidance after work and before practice chips, and optional evidence after the existing professional/sudden-change text. The stop-first sequence cannot regress. Do not add obligatory practice prerequisites: behaviour's current required practice list can reference a safe later skill (e.g. `mat`), with text explicitly saying it is not the response to active fear/panic and not proof of calm.

Alternative rejected: make sources mandatory on all old behaviour cards now. That would turn this bounded feature into a catalogue-wide evidence migration.

### 4. Content brief and evidence gate before bundled copy

`sources.md` is the claim/source ledger. During apply, first produce `content-review.md` under this change: complete PL/EN drafts for the six new resources, and exact field-level before/after proposals for `nipping`/`mounting`, each mapped to source IDs. Independent reviewer checks both languages and safety; present stable numbered findings, obtain the user's selection of corrections, then explicit approval of the resulting copy before bundling it. Model review must never be labelled veterinary approval. Unverified clinical claims are omitted or block the affected content; they are not filled in from intuition.

| Resource | Required educational focus | Excluded inference |
| --- | --- | --- |
| `puppy-rest` | Quiet, comfortable undisturbed rest; needs-first routine; unusual sleep/behaviour changes → vet | Fixed sleep quota; forced confinement; interpreting every energetic episode as exhaustion |
| `puppy-world` | Comfortable distance, voluntary observation/approach and ability to leave; vet-guided infection precautions | Exposure checklist, luring into fear, compulsory greetings, blanket pre-vaccination permission |
| `puppy-play` | Appropriate play outlets, short calm breaks, balance with rest and needs; adult supervision around children | Exhaustion as treatment, shouting/squealing as an error marker, unsupervised child management |
| `puppy-first-exercises` | Optional short practice when the dog can engage comfortably; stop if overwhelmed; links to current skills | Sit/stillness = emotional calm; meals/toilet/access to rest earned by obedience |
| `overarousal` | Multiple possible contexts; reduce stimulation/demands; check needs and observe antecedents/recovery | ADHD-style diagnosis; guaranteed calming tools; automatic exercise escalation |
| `fear-withdrawal` | Distance, safe retreat, no forced approach; persistent/intense fear → vet and qualified behaviour help | DIY flooding/desensitization ladder; food acceptance alone proves comfort |

Existing mounting/nipping review is limited to supported needs-first advice, medical/referral boundaries, avoiding causal certainty and PL/EN alignment. Preserve unrelated sentences/IDs and approved wording unless this gate explicitly approves a replacement. Do not retain a "wait months" threshold that delays help for pain, escalation or impaired functioning. Do not suggest that neutering is a general solution.

All six new resources and the two reviewed cards carry sources and actual verification date. Drafts use original wording: do not translate, copy or systematically paraphrase proprietary articles. The VCA article is corroboration only; use independently supported claims and original organization for the product. No logos, endorsements or copied illustrations.

### 5. No persistence changes, with an honest exercise-link boundary

Reading the hub/guides/problem cards, opening sources and navigating back writes no session, rep, progress, care participation or schema data. No new repository or migration is needed. Test on a fixture containing two dogs, multiple environments and an incomplete session; reopen the same store after browsing and compare raw state.

Opening an existing exercise link intentionally behaves like opening it from the catalogue. Per the current code path (`AppModel.makeSessionModel` → `ProgressRepository.position` → `SessionRepository.resumableSet`), that means an exercise never opened before gains its ordinary lazy initial state — a step-1/starting-environment `position` row and, when the exercise view materializes it, an empty active set. That initialization is allowed from guidance links exactly as from the catalogue. What is forbidden: any change to an existing `position`, earned mastery, `context_progress`, raw reps, owner choices, care participation, or the creation of guide-owned sessions. Re-entry/undo/recovery remain the existing session implementation's responsibility.

Five-rep rules remain domain-owned: 5/5 push, 3–4 stick, 0–2 drop; cancellation is failure, partial sets stay incomplete, verdicts are derived, and progress remains per dog/exercise/environment. Never derive a behavioural diagnosis from session scores.

### 6. Native-only resources and bounded provenance

Use the current native runtime as canonical; do not recreate `src/` or mirror into deleted Expo content. Preserve original frozen migration snapshots. Record current starting hashes and approved resulting hashes of only changed resources in this change; update `ContentChecksums` expectations through the existing reviewed procedure. The historical bilingual-copy spec protects its original edits/provenance, not a requirement to revive a retired runtime. If apply finds live-source ownership or byte-mirroring requirements unresolved in the active cutover, pause for reconciliation rather than modifying that change or guessing.

## Risks / Trade-offs

- **General guidance mistaken for diagnosis** → descriptive labels, visible disclaimer, multiple plausible contexts, no quiz, no fixed promises, prominent referral boundaries.
- **Medical signs normalized as puppy behaviour** → urgent sudden-change/pain warnings; persistent or severe fear and compulsive/disruptive mounting seek help, not a prolonged DIY trial. Bite-history aggression, escalating guarding and severe separation anxiety short-circuit to professionals in both locales.
- **Conflicting recommendations across pages** → record support and exclusions per claim; prefer current AVSAB humane-training stance; never copy a source's punitive advice just because other passages are useful.
- **PL/EN drift** → field-paired draft ledger, explicit aligned/corrected/N/A disposition for every touched existing field, semantic review in addition to structural validation.
- **Growing `CatalogueView`/`ProblemView`** → use focused new views for hub row/evidence/guide sections; no unrelated screen rewrite. Review the 100–250-line guideline.
- **User work in shared files** → recheck status/diff at apply time and edit only approved hunks; shared writes are sequential. Do not reset/stash other work.
- **Unavailable sources** → explicit evidence status; UC Davis was not fully readable and is not an authored-claim authority for this proposal. Re-fetch cited pages before copy approval.

## Migration Plan

No schema/version change. Ship additive native resources and views together after passing content/validation/UI gates. A feature rollback removes only its entry/routes/resources/code and explicitly approved content changes; never reset or downgrade the database. Existing incomplete sessions/history must survive the update. Retain old-card parsing compatibility; a malformed new bundle fails through existing content-validation conventions, not a destructive storage recovery.

## Delegation Plan

1. **Planner (GPT-6.1 Sol):** artifacts/source ledger; no application edits.
2. **Independent reviewer:** read-only artifact review before apply. No further delegation. Present numbered findings; only user-selected fixes enter this plan.
3. **Build via `/opsx-apply` (Flash Next):** sequential bounded work: draft content and source recheck → approved copy → model/validation/resources → native UI/navigation → targeted tests. One implementer owns shared loader, manifest, locale and route files; no parallel overlapping writes or recursive agents. Return changed files, executed checks and open issues.
4. **Independent reviewer:** bilingual draft gate and final code/content/data-safety review, read-only, with user selection of any fixes. No claim of clinician review.
5. **Planner:** archive reflection and memory proposals only after completion, with approval before durable memory updates and before CLI archive.

## Open Questions

No product-scope question blocks proposal review. Actual PL/EN copy and any changes to existing cards remain an explicit approval gate, not implied by approval of this design. Simulator destination must be verified during apply; no tests or device review are claimed at planning time.
