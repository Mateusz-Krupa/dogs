# Scope extension: picking up and eating things from the floor

Status: user requested this guidance and suggested placement in the puppy section. Planning only; not bundled or deployed. Before apply, reconcile this addendum into proposal/design/specs/tasks and obtain independent review plus approval of the bilingual draft. The existing loose-lead proposal alone does not cover this extension.

## Placement decision

Use the existing `puppy-first-exercises` foundation as the primary educational entry, with practical guidance and optional links to existing `leave` and `drop` exercises, retaining `name`, `look`, `mat`. Do not introduce a fifth foundation, duplicate scored exercises or move/remove catalogue entries. The current puppy spec explicitly has four foundations, and this resource already supports actions, safety/referral copy, exercise links and source metadata. Guidance also applies to adult dogs, with no age gate.

## Draft acceptance scope

- Distinguish normal sniffing and safe exploration from swallowing found items; do not prohibit all nose-to-ground exploration or all food-based enrichment.
- Explain `leave` before pickup versus `drop` once an item is in the mouth. Link to existing canonical exercises rather than adding a new scoring/progression policy.
- At home: manage access during cooking and clear dropped items; practise voluntary disengagement with safe, controlled dog-appropriate items, reward from the owner rather than awarding the practice item, then gradually practise safe low-height drops. Never use medication, rubbish, sharp objects or toxic food as props.
- Outdoors: start in a quieter/easier context with distance and a slack fixed lead; reward leaving a safe controlled item or checking in. Do not assume kitchen performance transfers to the street, test on hazardous finds, yank the lead or require constant eye contact.
- Already holding something: use a practised voluntary trade, not chasing, scolding, forced mouth opening or a struggle. Return only safe practice toys, never a dangerous find.
- Suspected toxic/medicine/sharp-object ingestion requires immediate veterinary contact rather than continuing a training protocol; breathing difficulty/choking is an emergency. No DIY vomiting or improvised emergency-extraction instructions.
- Guarding, freezing over an item, growling or snapping requires safe distance and professional support rather than testing/taking items; escalating guarding/bite history short-circuit DIY guidance. Repeated non-food ingestion or a sudden change merits veterinary assessment.
- Preserve equivalent original PL/EN advice, existing safety blocks and unrelated approved copy; record field-level sources and before/after wording. Reading remains write-free; exercise links retain ordinary lazy initialization and preserve existing partial/choice-pending sets (CONV-002). No age/content locks, progress changes, migrations or account/network dependency.

## Evidence inspected

Full pages read on 2026-10-29:

- Dogs Trust, “How to train your dog to leave it”: https://www.dogstrust.org.uk/dog-advice/training/basics/leave-training — explicitly discusses puppy mouth exploration, voluntary trade, leaving before pickup, rewarding from another hand, gradual floor/low-drop practice, new settings and reducing difficulty.
- Dogs Trust, “How to stop your dog from stealing”: https://www.dogstrust.org.uk/dog-advice/training/unwanted-behaviours/stop-your-dog-stealing — supports prevention, safe alternatives, voluntary swaps, no chasing/scaring and professional support for guarding. Do not reuse its ignore/wait advice for dangerous objects or make guarantees about trading.
- Medical/emergency and repeated non-food ingestion statements still require full-page veterinary source verification and exact field mapping before publication; the above training sources are not sufficient clinical evidence.

## Delegation Plan and gates

1. GPT-6.1 Sol planner updates OpenSpec artifacts and drafts the additional PL/EN text with verified sources. Independent reviewer examines the combined scope; user selects any numbered review findings before amendments.
2. After approval, `/opsx-apply expand-loose-lead-guidance` selects Flash Next. Implement sequentially because copy, linked exercise expectations and resource hashes depend on each other. No recursive delegation or overlapping writers.
3. Expected incremental application scope: `puppy-puppy-first-exercises.json`, only its checksum entry, focused existing puppy content/link/UI expectations as necessary. No application edits by the planner. Do not modify canonical `leave`/`drop` steps unless separately approved.
4. Verification: relevant `PuppyContentTests`, `PuppyGuideValidatorTests`, `PuppyIsolationTests` and `ContentLoaderTests`, plus PL/EN phone-sized offline inspection. Inspect existing UI expectations before changing links; run the relevant focused puppy UI test if navigation expectations change. Record actual checks, not presumed passes. Keep unrelated dirty content and checksum entries untouched.
5. Final independent review precedes release; no unselected reviewer fixes. User confirmed deployment destination is TestFlight. The implementation/release agent must establish the exact release-tree scope, follow existing distribution documentation without reading credential files, verify build-number/signing/upload prerequisites, preserve installed data and distinguish successful upload from Apple processing/tester availability. No build/upload has occurred in this planning session.
