## Context

`PuppyStartView` renders four foundations from `TrainingContent.puppyGuides` and four canonical behaviour links. `PuppyGuideView` renders disclaimer → urgent → avoid → actions → observe → professional → optional exercise links → evidence. `PuppyGuide` currently has only flat bilingual text lists. This works for short foundations but would bury this topic's practical detail in one long numbered list.

Current puppy files are untracked/pre-existing user work; reuse them without treating their entire contents as this change's diff. Existing specs explicitly require four foundations. Graph/semantic discovery and current files, rather than obsolete migration-era TypeScript references, establish the native architecture.

## Goals / Non-Goals

**Goals:** A fifth, clearly discoverable foundation; an unambiguous accident response; concrete, source-backed outdoor learning; useful detail in titled chunks; full offline PL/EN access; no history/progress writes.

**Non-goals:** See proposal. No new exercise, scored set, participation record, scheduled notification, toilet diary, behavioural diagnosis, crate-training programme, generic article engine or redesign of other foundations.

## Decisions

### 1. One canonical guide and existing route

Append `puppy-toilet` after `puppy-first-exercises` in `CatalogueManifest.puppy`; bundle `Pettrainer/Resources/Content/puppy-puppy-toilet.json` using the current family/ID convention. Reuse `Route.puppyGuide`, hub row, supported still pose and evidence view. No duplicated Problems card or new top-level navigation entry. Do not alter the relative order or content of the original four guides or help-now links. An existing pose suffices: custom toileting art adds no necessary instruction.

### 2. Optional, small content extension

Add `PuppyGuideSection` with a stable nonblank `id`, bilingual nonblank `title`, and bilingual nonempty `paragraphs: [String]`. Add optional JSON `sections` to `PuppyGuide`, normalized to an empty array when absent. Present-but-empty/malformed sections, duplicate IDs, missing locales/blank paragraphs and scoring/gating fields in sections fail with source/field diagnostics. Reuse `Checks` and the existing forbidden-key policy. Do not loosen evidence validation or introduce arbitrary rich text, nested sections, media or dynamic layout variants.

Existing flat lists remain required; `actions` contains only the quick accident response, not a duplicate of the full outdoor plan. Render titled sections after `actions` and before `observe`, preserving disclaimer/urgent/avoid before all action. Existing guides have no sections and render as before. Use content-localized titles rather than one translation key per article heading; any genuinely new UI chrome belongs in both locales of the String Catalog. If a small private section renderer would breach the reviewed view-file size bound, use one focused puppy-section view rather than a broad UI refactor.

Alternative rejected: a new guide family/view or fixed toilet-only model duplicates working routing/evidence. A long flat list is smaller in code but poorer for this explicitly more detailed topic. Sections are reading structure, never training stages or completion controls.

### 3. Editorial outline and behavioural boundaries

These are content requirements, not final approved copy. Keep paragraphs short, direct and original; every instruction explains what the owner does and what association/opportunity it supports.

Quick actions distinguish all three cases: pre-toilet signals → calmly go to the chosen spot; already urinating → let finish without reacting, noise or forced handling; found puddle → calmly clean. No “no”, clapping, startling, lifting mid-stream, dragging, rubbing the nose, retrospective punishment or praising the interruption. Once finished, an ordinary further outdoor opportunity is possible, never punishment or a requirement to finish again.

Proposed section IDs/order and coverage:

1. `how-learning-works`: developing control, location/substrate habits, why an accident is not spite; do not expect reliable signals or infer a diagnosis from one accident.
2. `outdoor-routine`: prepare treats, accompany to a quiet suitable spot, allow unhurried sniffing, use regular opportunities after sleep/food/drinking/play/excitement, before bed and when signs appear. Intervals adapt to the individual, never age-plus-one-hour formulas or endurance practice. Local vaccination/infection-risk advice comes from the owner's vet; no blanket public-ground instruction for incompletely vaccinated puppies.
3. `reward-and-cue`: reward promptly after finishing, still outside near the spot, not after returning home or mid-stream; optional quiet cue paired with the action before asking in advance. No repeated commands, forced performance, or need to toilet to earn water/rest/safety.
4. `no-toilet-outside`: if nothing happens after a short calm opportunity, return without punishment, supervise and offer another opportunity soon/at signals. Address distractions/fear with a quieter safe spot, not waiting indefinitely outside. Indoor accidents after outings do not prove stubbornness.
5. `signals-and-freedom`: watch sniffing/circling/restlessness/door-seeking, respond promptly, gradually loosen supervision and spacing only as the dog copes; after setbacks return to easier management rather than making the dog hold longer. No guaranteed deadline or requirement to ring a bell.
6. `nights-and-absence`: night opportunities may be needed; calm trips, comfortable safe space and planned human help when needs exceed absence. No crying-it-out, forced crate holding, confinement as punishment or water restriction. A paper observation note can help identify patterns; no app tracking feature.
7. `pads-to-outdoors`: pads are an optional practical fallback, not a moral failure; explain indoor substrate learning versus the outdoor goal, retain a usable option when outside access is not adequate, and build outdoor reward opportunities gradually. Verify any specific relocation/removal technique before proposing it; never simply remove the only accessible toilet or shame apartment owners.
8. `cleanup-and-setbacks`: remove odour with an appropriate pet-urine/enzymatic cleaner used per label and surface suitability; keep the dog away during cleaning as directed. No chemical recipes, branded products, mixing cleaners or diagnosis from which object was urinated on. Sudden/repeated changes get a vet check rather than an increasingly strict training plan.

Always-visible `urgent` before actions: inability to pass urine/repeated unsuccessful straining warrants emergency veterinary contact; pain, blood, sudden regression or concerning frequency/thirst warrant prompt vet contact. Confirm precise wording/urgency from authoritative full-page reads before draft approval; no home treatment. `professional` explains persistent difficulty after medical assessment, qualified support, and that marked separation distress or aggression risks need professional help rather than this DIY plan. The guide is primarily for puppies but must not label a previously clean adult dog's sudden accidents as normal puppy learning.

### 4. Evidence and copy approval before shipping

Planning source reads and unresolved claims are recorded in `notes.md`. Build `content-review.md` during approved apply with stable field IDs for every PL/EN field (including section paragraphs), full-page source/claim mappings, actual verification date, unsupported-claim dispositions and explicit user approval. Use 1–5 load-bearing citations, not a larger hidden source list presented as complete metadata. Choose authoritative sources covering unresolved medical, water, outdoor-risk and pad details before authoring those claims; omit unsupported optional mechanics, but block the guide if essential safety advice remains unsupported.

Independent bilingual welfare review and the user's approval of final drafts must precede JSON bundling. Plan approval is not approval of prose that has not been shown. No “vet approved” badge, copied passages or professional endorsement. Preserve all unrelated approved copy/checksums; register only the reviewed new resource hash in the live ledger and relevant inventories, never rewrite frozen migration provenance. Source URLs remain optional to open; reading does not require network access.

### 5. No persistence change; focused verification

No Data/Domain/AppModel write changes or migration. `practices` is empty: toilet learning does not need links to scored drills. Extend `PuppyIsolationTests` to open the new guide/content path with seeded two-dog, multi-environment, partial-set and choice-pending records, and compare all training/participation rows and schema version across browsing/reopen. Assert `puppy-toilet` is absent from scored seeding/recommendations/mastery. Existing rules remain 5/5 push, 3–4 stick, 0–2 drop; cancellation fails; incomplete sets remain incomplete; verdicts remain derived.

Extend existing `PuppyGuideValidatorTests`, `PuppyContentTests`, `ContentLoaderTests` and `PuppyFlowUITests` for sections, fifth entry, exact order, full content presence, sources and localization. Update `ContentChecksums` with before/after evidence and registered-key equality. Run focused relevant XCTest classes; reuse existing verdict/set suites as regressions only as appropriate, without expanding a content change into all-suite churn. UI checks cover quick response before long sections, reaching each heading/sources, back/re-entry, PL/EN, phone size, Dynamic Type and VoiceOver reading order. Offline content/isolation tests and simulator checks are not proof of a physical-device upgrade.

## Risks / Trade-offs

- [Sources disagree on interrupting] → Explicitly choose the Dogs Trust ongoing-accident rule; no sound/error-marker protocol in either language. Keep before/ongoing/after separate in review and tests.
- [More detail becomes unreadable] → Quick response first, eight short titled sections and existing native scrolling; do not expand the other guides or build a navigation system.
- [Optional extension silently drops malformed data] → Absence is compatible; malformed presence fails with diagnostics and fixture tests.
- [Medical issue mistaken for training failure] → Visible triage first, veterinary checks for regression/concerns, no diagnosis or delay-until-training-fails rule.
- [Dirty shared files mask unrelated edits] → Capture scoped baseline/status, one sequential implementation owner, inspect actual hunks and do not blanket-regenerate hashes.

## Migration Plan

Additive bundled content and backwards-compatible parsing only; no SQLite migration. Old guides remain valid without sections. Rollback removes the new guide's resource/registration/extension together and does not delete a database, raw history or existing progress.

## Delegation Plan

GPT-6.1 Sol plans; a read-only independent `reviewer` checks this plan before implementation. Present stable numeric findings and obtain the user's selection before editing for those findings. After explicit implementation approval, `/opsx-apply add-puppy-toilet-guidance` selects Flash Next (`swissquant-local/vision-flash`); this planner does not implement or substitute a model.

Use one implementation owner sequentially: evidence/drafts → copy review/user approval → optional model/validator → resource/manifest/view → tests/checksum integration. The same shared files and ordering dependencies make parallel writing unhelpful. Reviewer work is read-only, subagents do not delegate, and assignments return files/checks/open issues. After verification require an independent final review and user selection of any further fixes. Reflection and memory approval precede any CLI archive operation.

## Open Questions / Gates

No product question blocks the plan. Pending gates: independent plan review, user implementation approval, source confirmation for flagged safety/details, independent bilingual draft review and user copy approval, then verification and final independent review. No draft or implementation is implicitly approved by artifact completeness.
