# Notes — add-puppy-toilet-guidance

## Planning evidence (2026-10-31)

- User requested a substantially developed puppy topic covering indoor urination, whether to interrupt, gradual outdoor learning and what helps a dog understand.
- Retrieved project memory via Qdrant: CONV-001 (PL/EN alignment), CONV-002 (write-free education), DEC-001 (live checksum inventory), PIT-002 (calendar-safe evidence dates), PIT-003 (UI lookup/cold-start caveats). Also read local CONV-003, found through the graph, for the five-source evidence budget. Semantic search returned obsolete JS-era care material; verified native files instead and did not import that architecture.
- Graph project resolved through `list_projects`: `Users-mateuszkrupa-pettrainer`. Existing `PuppyGuide`, `PuppyGuideView`, `PuppyStartView`, validator and manifest verified against files. Existing spec fixes foundations at four, so a delta must change that count explicitly.
- `git status --short` shows extensive pre-existing modifications and untracked native puppy files. No application files edited by this proposal. Active changes: care, native migration and two earlier content proposals; none plans toilet guidance. Shared files require one implementation owner and a fresh status check at apply.

## Source reads and limitations

Full supporting article text retrieved during planning (not merely snippets):

1. Dogs Trust, “How to toilet or house train your dog”: https://www.dogstrust.org.uk/dog-advice/training/basics/house-or-toilet-training — primary support for the explicit before/ongoing distinction, regular opportunities, reward after finishing while outside, cue association, quiet cleanup and veterinary concerns. Its ongoing-accident section says to let the dog finish; do not misread its earlier “gently interrupt” wording about pre-toileting signs as advice to stop a urine stream.
2. Blue Cross, “How to house and toilet train puppies and adult dogs”: https://www.bluecross.org.uk/advice/dog/behaviour-and-training/how-to-house-and-toilet-train-puppies-and-adult-dogs — routine, signs, quiet outings, unsuccessful outings/supervision, night needs, scent removal and punishment risks. Do not import fixed time guarantees, crate-duration rules, cleaning recipes or leaving contaminated material outdoors.
3. VCA, “House Training for Puppies and Dogs”: https://vcahospitals.com/know-your-pet/house-training-your-puppy — factual corroboration of reward location/timing, maturation, supervision, temporary toileting substrate and medical regression. Its distraction/noise suggestions are excluded by the project's no-error-marker policy; no translated or closely paraphrased article passages, branded cleaner recommendations, universal age/hour limits or crate protocol are planned. Published app prose must be original.

Not yet verified by full supporting reads: exact urinary emergency wording; vaccination/local outdoor infection-risk precautions; explicit water-access wording; detailed pad-to-outdoor transition mechanics. These are authoring gates, not verified claims. Obtain authoritative support within the existing 1–5 source budget or narrow/remove unsupported detail; medical red-flag coverage cannot simply be dropped. A search snippet is not sufficient. Final drafts, exact field mappings and byte digests belong in `content-review.md` during approved apply.

## Approval state

- Proposal artifacts only; implementation and final app copy are not approved.
- Independent plan review pending. Do not act on review findings until the user selects their IDs.

## Independent bilingual copy review of the DRAFT (2026-10-31, GPT-6.1 Sol reviewer, read-only)

- Reviewer fetched and checked all five cited pages. Confirmed support for the load-bearing rules (let-finish, reward still outside, cue pairing, short-opportunity-then-supervise, journal, enzymatic cleaner, regression→vet, excited urination not deliberate, pads as trained substrate, self-reward relief, baby monitor). Verdict: draft NOT ready — blockers C-1…C-18, optional C-19/C-20. All are copy-ledger fixes; the code infrastructure is unaffected.
- Highest-impact: C-1 EN bodies missing for avoid/actions/observe; C-2 PL typo sweep; C-4 the emergency-straining sentence is only carried by the marking page that was dropped from citations. Proposed smallest fix (pending user selection): replace Blue Cross with VCA Marking in the final 5-source set — BC-unique support (guilty look, punishment→anxiety, routine) is duplicated by S1/S2/S4, and the softened phrasing requested in C-11/C-12/C-13 no longer relies on BC's timers.
- Reviewer ran no app/build checks (copy review by design). Review ≠ user approval.

## Copy revision (2026-10-31): all C-1…C-20 applied

- User selected every finding (“wszytkie”). content-review.md rewritten as the revised draft: full PL↔EN pairs for every field; PL typo sweep; the five-source set now Dogs Trust / VCA-HouseTraining / VCA-HouseSoiling / VCA-UTI / **VCA-Marking** (Blue Cross read-but-uncited, reason recorded per CONV-003); two-tier urgent; separation + bite-history escalation; quick reward after finishing; ages/thresholds/minute-counters/one-second deadline removed; pad mechanics limited to source-supported conditioning; regression split into sudden→vet vs learning slip→easier level; journal stays paper-only; treats-in-pocket, comfortable resting space and dog-out-of-room clauses added; cue example changed to „siusiu”/“go potty”.
- Post-revision artifact sweep (non-Latin chars, doubled words, prior defect fragments) run with python: only legitimate Polish punctuation matched; every substring hit visually inspected and clean.
- Gate status: copy review round complete with all findings incorporated; **user copy approval obtained 2026-10-31** — after the vinegar/ocet question was raised, the user chose variant 1 (enzyme-only cleanup copy, no household recipes), leaving the revised ledger text as final. Bundling (tasks 2.2/2.3) is therefore unblocked.

## Copy decision: vinegar (2026-10-31)

- User asked whether odor-neutralising home remedies (e.g. vinegar) should be added. Evidence check: only blog/forum pages recommend vinegar; none of the five cited authoritative pages does, and the design already excluded chemical recipes. Presented options; **user chose 1 — keep the enzymatic copy as-is**. No copy change; `cleanup-and-setbacks` already explains why the odour must be removed for the dog's nose, not the human's. Validator tests remain green from the pre-revision run (copy changes do not touch code); ContentLoader/checksum/UI tests intentionally not yet run because the JSON is not bundled.

## Implementation evidence (2026-10-31)

- Task 1.2: memory re-retrieved (CONV-001/002/003, DEC-001, PIT-002/003); full-page reads added for VCA UTI, VCA House Soiling, VCA Marking; ledger rewritten as content-review.md (draft only, ungated code untouched).
- Task 2.1 implemented: `PuppyGuideSection` + optional `sections` on `PuppyGuide` (ContentModels.swift); `parseSections` in PuppyGuideValidator (absent→[] backwards-compatible; present requires unique nonblank id, bilingual nonblank title, nonempty bilingual paragraphs, unknown-key rejection limited to id/title/paragraphs, nested scoring-key rejection reusing the parent's forbiddenKeys + "reading is never scored"); 11 new validator tests added to PuppyGuideValidatorTests.
- Check: `xcodebuild -project Pettrainer.xcodeproj -scheme Pettrainer -destination 'platform=iOS Simulator,id=51A9D98E-4FE5-4D66-91F1-7414EF273167' -only-testing:PettrainerTests/PuppyGuideValidatorTests CODE_SIGNING_ALLOWED=NO test` → **29 tests, 0 failures** (first run failed only on `XCTAssertEqual(sections, [])` requiring Equatable; fixed the test to `isEmpty` rather than adding Equatable to the model).
- Task 3.1 view code landed (readingSection under the quick actions, accessibility id `puppy-section-<id>`, no new String Catalog keys); kept unchecked until PL/EN simulator verification (task 4.2).
- Path-hygiene note: two shell calls carried garbled paths (`openspecpec`, doubled `.swift`) and were corrected against `pwd`; the actual edits were verified against real files with grep/sed after each write. The `edit` tool echoed similar artifacts; on-disk state was always checked and is clean.
- Pitfall observed: model prose for long bilingual ledgers accumulated stray non-PL glyphs and duplicated words; the copy ledger must be re-swept after every regeneration, and the independent review exists precisely to catch it (C-2).

## Planning validation and review limitation

- `openspec validate add-puppy-toilet-guidance --strict` passed; CLI reports all four required artifacts complete.
- No application code, resources, dependencies or agent configuration edited; no XCTest, simulator or device checks run for this proposal.

## Independent plan review (2026-10-31)

- The earlier `reviewer` failures were a caller-side defect (a bogus `sessionID` parameter), not agent configuration; corrected invocation completed as read-only GPT-6.1 Sol review (session `ses_e6da3c2d9fferOtfSHm1WJgL7Z`). Update notes rather than claiming no review can run.
- Outcome: **no blocking findings**. Compliance confirmed for welfare boundaries, before/during/after rule, minimality, backwards-compatible optional sections, full MODIFIED spec deltas, CONV-002 write-free contract, DEC-001 checksum integration, task ordering and dirty-worktree handling. Reviewer independently re-read the full Dogs Trust article supporting the let-finish rule.
- Optional findings presented to the user:
  - **R-1 (Low):** tasks.md 2.2 must explicitly name the verification-date assertion in `PuppyContentTests.swift:63–66` so the fifth guide's real date does not force backdating or relaxing the four existing expectations.
  - **R-2 (Low):** tasks.md 2.2 must require the existing unscored-language guard (`PuppyContentTests.swift:180–205`) to enumerate section titles/paragraphs in both locales, reusing its banned-term policy.
- Awaiting the user's selection of finding IDs and explicit implementation approval; task 1.1 stays unchecked until recorded. Reviewer ran no app/build checks; its review is not user approval.

## Plan-review selection + implementation approval (2026-10-31)

- User replied "tak wszystko zalecane" — selected both recommended findings **R-1 and R-2**, and the prior `/opsx-apply add-puppy-toilet-guidance` plus this selection constitute explicit approval to implement.
- Both findings applied to `tasks.md` task 2.2 (verification-date assertion handling; unscored-language guard extended to section titles/paragraphs in both locales, reusing its banned-term policy). No other artifacts changed by the review.
- Task 1.1 marked complete. Implementation proceeds sequentially per the Delegation Plan; independent bilingual copy review and user copy approval remain open gates before bundling (tasks 1.2/1.3).

## Bundling + verification evidence (tasks 2.2–4.2, 2026-10-31)

- Copy approved (user variants: "wszytkie" for C-1…C-20, then "1" keeping the enzyme-only cleanup wording; vinegar deliberately not shipped — no authoritative support). `puppy-puppy-toilet.json` bundled with digest 8ef18a69962208c2c6a38244241e9d55d64b672d47cf511d350350ec9c248a33; ledger + checksum entries in content-review.md.
- Unit: `-only-testing:PettrainerTests/PuppyContentTests PuppyIsolationTests ContentLoaderTests PuppyGuideValidatorTests` → 62 tests, 0 failures (simulator 51A9D98E-4FE5-4D66-91F1-7414EF273167). First combined compile hit a Swift type-check timeout on a long `flatMap + chain` in PuppyContentTests; fixed with explicit `[String]` local annotations (test-only change).
- UI: PuppyFlowUITests 5/5; new change-local PuppyToiletVisualTests 3/3 (EN/PL phone-size + UICTContentSizeCategoryL), screenshots exported and reviewed by eye: STOP box precedes everything actionable, both locales render, 5 citations + Verified 2026-10-31 render, large type wraps. The dark pill over the last clipped line in the two "top" shots is the iOS home indicator, not app chrome.
- Caveats: VoiceOver audio pass and airplane-mode toggle not performed (structural guarantees + test evidence only); no physical-device upgrade check.

## Final-review fixes (F-1…F-4, user: fix all; 2026-10-31)

- F-2: `observe[3]` made tentative in BOTH locales — PL „mogą wskazywać na lęk separacyjny… potrzebna jest ocena i pomoc…”, EN “may point to separation-related distress — they need … assessment and help”. User instruction itself was the approval of this one pair (“poprawione tak jak w angielskim ostrozniej”). JSON rebundled; final digest 06ce541e5ded3eb353dbc04ae756712734e880c9be05a3da9c5d63a0be5cd945 in ContentChecksums + ledger; PuppyContentTests now asserts the tentative phrase AND forbids the categorical one in each language.
- F-1: `PuppyToiletVisualTests` no longer claims Dynamic Type enlargement. App typography is fixed `.system(size:)` app-wide (deliberate existing pattern, unchanged here), so the test now proves what the spec scenario promises: at `UICTContentSizeCategoryAccessibilityL` the guide opens, scrolls fully to the 2026-10-31 citation block, PL and EN. Notes text corrected (previous “large type supported” phrasing was an overclaim; the old `UICTContentSizeCategoryL` = default size).
- F-3: 5 more validator fixtures: `sections: null` (caught `isNull` vs `isJSONNull` repo convention + a compile-fix cycle), blank section id, blank title, missing `en` paragraphs list, gating key `requires` inside a section. Validator now distinguishes absent-vs-null explicitly.
- F-4: content-review.md stale “pending approval” gate replaced by the final Gate record; task 1.3 checked; learnings.md written.
- Re-verification: unit combo (PuppyGuideValidatorTests + PuppyContentTests + PuppyIsolationTests + ContentLoaderTests) → **67 tests, 0 failures**; PuppyToiletVisualTests run recorded next (accessibilityL PL+EN). Strict validation valid. One Swift fix needed mid-way (test-only: explicit [String] annotations for a type-check timeout; `section("  ")` call-label fix).
- F-1 re-run completed: PuppyToiletVisualTests on the final bytes → **3/3 passed** (EN top/sources, PL top/źródła, accessibilityL PL+EN reaching the citation block). Task 4.3 closed with the re-verification recorded here.
