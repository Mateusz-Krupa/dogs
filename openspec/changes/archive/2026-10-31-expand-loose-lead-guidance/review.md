# Independent plan review — expand-loose-lead-guidance

Reviewer: `reviewer` agent, model `openai/gpt-6.1-sol`, read-only, 2026-10-29.
Scope: proposal, design, tasks, content-review, loose-lead delta spec,
puppy-scope-addendum, plus current leash/puppy content, validators, SetView
disclosures, content tests, checksum ledger, distribution docs.
`openspec validate expand-loose-lead-guidance --strict` passed in the review.

## Findings

| ID | Severity | Location | Finding | Smallest fix | Blocks |
| --- | --- | --- | --- | --- | --- |
| R-1 | High | proposal.md:5–22, design.md:3,18,24, tasks.md:11,15–25, spec.md:3–44, puppy-scope-addendum.md:3,32–33 | Combined scope not reconciled: main artifacts authorize two JSON resources while the addendum adds a third resource, puppy tests and acceptance criteria missing from the delta spec | Fold three-resource scope, checksum ledger, file ownership and verification into the main artifacts; encode scavenging acceptance cases in this change's delta spec. Existing `puppy-start-guidance` spec needs no change (links are optional; four foundations retained) | implementation |
| R-2 | High | puppy-scope-addendum.md:13–18,24–26,30, content-review.md:26–54 | Veterinary evidence for ingestion/emergency/non-food-ingestion claims unverified; no reviewed PL/EN puppy draft or field-level mapping (required by `openspec/specs/puppy-start-guidance/spec.md:58–71`) | Complete veterinary source verification, add exact touched-field PL/EN drafts with before/after wording and dispositions to the ledger for review/approval; keep escalation ahead of practice; retain existing urgent safeguards | puppy extension only |
| R-3 | Medium | puppy-scope-addendum.md:33, tasks.md:22–24 | `PuppyContentTests.swift:63` pins every guide's `verifiedOn` to `2026-10-24`; `:87` requires exactly `["name","look","mat"]`. Adding reviewed date + leave/drop links invalidates both; running validator/isolation suites alone would not verify decoded bilingual advice | Narrowly update the changed guide's date/link expectations, keep other guides' assertions, add decoded PL/EN checks for leave-before-pickup vs drop-after-pickup, safe props, home→street difficulty, ingestion referral, guarding short-circuit; reuse existing isolation coverage | implementation |
| R-4 | Medium | puppy-scope-addendum.md:34, tasks.md:27–30 | Release-tree scope not gated on user approval; `git status --short` shows extensive unrelated staged/unstaged work, so archiving the workspace would ship more than this change | Add a release-only inventory + user approval gate before archive→export→validate→upload (`DISTRIBUTION.md:18–48`); verify signing/build-number prerequisites without reading credentials; report upload separately from Apple processing/tester availability | release only |

Reviewer also recorded: no additional welfare or placement findings; independent
re-fetch of the RSPCA, Dogs Trust, Preventive Vet and Blue Cross sources
supports the equipment, reel-tension, normal-sniffing and leave/trade advice;
the locked-with-slack qualification avoids an overbroad claim; `SetView.swift:184–219`
renders five disclosures without UI/schema change; 5/5 push, 3–4 stick,
cancellation, incomplete-set, derived-verdict, per-context and raw-history
semantics stay untouched.

## User selection

2026-10-29, single question: user selected **all of R-1, R-2, R-3, R-4**
(“Wszystkie R-1–R-4”). No unselected findings are implemented.

## Final review (implementation diff) — 2026-10-31

Second independent `reviewer` pass (model `openai/gpt-6.1-sol`) over the six-file
implementation diff. It recomputed all three SHA-256 hashes (all matched), re-fetched the
cited sources, confirmed the leash copy is welfare-aligned and that no Domain/Data,
migration, gating, translation-key or training-rule change is present. Findings:

| ID | Severity | Location | Finding | Fix |
| --- | --- | --- | --- | --- |
| F-1 | High (release blocker) | puppy guide `urgent`/`observe` | Guarding signs were labelled "not ordinary stubbornness", but `urgent` only escalated *worsening* guarding; no explicit "no self-test, no punishment, stop item practice, vet then behaviourist" | Appended the matching PL/EN sentence to `urgent` |
| F-2 | Medium | puppy guide `actions.pl[4]/en[4]` | Missing approved distinction: safe practice toy is returned after a trade, a dangerous find never is | Appended it in both languages |
| F-3 | Medium | ContentLoaderTests, PuppyContentTests | Keyword-level assertions: `&&` non-emptiness passed with one empty locale; EN `"locked"` also matched "unlocked"; leave/drop test checked cue names not before/after-pickup order; no guarding assertion | Quoted full safety clauses per locale, split every `&&` pair, asserted before/after order, toy-return, force ban, and guarding short-circuit |
| O-1 | Optional | `avoid.en[3]` | EN narrower than PL ("as a lesson") | EN reworded to match PL ("do not take items out of the dog's mouth by force") |

User selection (one question): **F-1, F-2, F-3 and the optional item — all**. Applied in
the same files; the puppy resource changed bytes, so its checksum entry and the ledger
after-hash were updated (revision below).
