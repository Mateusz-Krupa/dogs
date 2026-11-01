# Learnings — add-puppy-toilet-guidance (2026-10-31)

## Intent vs outcome

- Intent: a substantially richer puppy topic for indoor urination — what to do during an accident, whether to interrupt, gradual outdoor teaching. Outcome: shipped `puppy-toilet` as the fifth foundation with quick before/during/after response + eight titled sections, PL/EN, offline, write-free. Scope matched the approved proposal; no non-goals were touched.
- Plan-vs-reality: the design's optional-`sections` extension proved sufficient; no schema or persistence change was needed. The main unplanned work was verification honesty (F-1) and one welfare-wording fix (F-2), both caught by reviews, not by tests.

## Problems / wrong turns (and what actually worked)

1. **Subagent invocation**: four reviewer calls failed with `Subagent session not found` because a bogus `sessionID` (`ses_invalid`) was passed for what should have been a fresh session. Fix: omit `sessionID` entirely for new subagent sessions. Local (tooling), but recurring in this session's notes; the misleading "review unavailable" wording in the proposal notes had to be corrected afterwards.
2. **Overclaimed Dynamic Type verification (reviewer F-1)**: `PuppyToiletVisualTests` used `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryL`, which is the *default* category — and the app's `.system(size:)` typography never scales at all. A green test there proves layout reachability, not enlarged-text support. Fix: `UICTContentSizeCategoryAccessibilityL`, both locales, scroll to the citation block, plus corrected wording in notes. This is a reusable trap → PIT-004 candidate.
3. **Definitive PL diagnosis (reviewer F-2)**: `observe[3]` PL said an absence-only accident pattern "to sprawa lęku separacyjnego" while EN was hedged ("point to"). Welfare copy must keep symptom→cause attribution tentative **in both languages**, and a per-locale test that only asserts substrings can miss modality differences. Fixed to "mogą wskazywać…" / "may point to…" with negative assertions on the categorical phrasings. → CONV-004 candidate.
4. **Swift type-check timeout**: a `flatMap` + long `+` chain of string arrays inside `XCTAssert` context blew the compiler's inference budget. Fix: explicit `[String]` local annotations before the assertion. Local-ish but cheap to remember.
5. **JSON `null` ≠ absent**: `parseSections` initially treated any present value via `guard let value`; explicit `sections: null` then surfaced as "array of objects" mismatch instead of the clear sections error, and the test exposed the API name: `JSONValue.isJSONNull` (the repo's own convention: absence and null are different failures). Local lesson, already documented in code comments.
6. **Long model-authored bilingual ledgers produce copy artifacts** (stray CJK glyphs, doubled words, wrong grammatical cases). What worked: a mechanical python sweep (non-Latin char scan, doubled-word regex, known-artifact grep) *plus* the independent bilingual reviewer before bundling; both layers found different items. Procedural.
7. **Source-set churn was expected, not drift**: dropping Blue Cross for VCA Marking to carry the emergency-straining claim followed CONV-003 (record the read-but-uncited reason in the ledger). Worked as designed.

## Decisions and rationale

- Dogs Trust "let it finish" chosen over VCA's "interrupt without scaring" for the *during* case: no-error-marker product rule resolves the cross-source conflict; recorded in notes and the ledger so future editors do not "fix" it back.
- Vinegar/home-remedy cleanup was offered by the user and declined on evidence grounds (no authoritative support; design excludes chemical recipes). User accepted variant 1 explicitly.
- Two-tier urgent (emergency straining vs same-day check) so the most acute sign reads first without inventing a triage system.
- Validator rejects scoring/gating keys *inside* sections by reusing the parent's forbiddenKeys (no parallel policy; reviewer R-2/F-3 extended coverage to `requires`).

## Memory impact (retrieved entries consulted)

- CONV-001: helped — drove the per-field PL↔EN diff discipline; F-2 shows alignment must include *modality*, not just content.
- CONV-002: helped — write-free test design reused as-is; no delta.
- CONV-003: helped — the Blue Cross drop / VCA-Marking add is exactly its "record the reason" flow.
- DEC-001: helped — checksum ledger + registered-key equality caught nothing because the flow worked; digest churn (F-2) was recorded, not blessed silently.
- PIT-001: helped — nested-locale fixtures (missing `en` inside paragraphs) caught the walker case up front.
- PIT-002: N/A — evidence date rules untouched.
- PIT-003: helped — label-vs-identifier and 30 s cold-start budgets kept the new UI tests stable first try.
- opencode-implement skill: retrieved but NOT applicable — this OpenCode implementer must not spawn a nested implementation agent; implemented directly. (Noise for an OpenCode-side run; its ⚠ no-verification-date caveat held.)

## Verification evidence and limitations

- Runs recorded in notes.md: 62→(after fixes) unit suite incl. 34 validator tests, 5/5 PuppyFlowUITests, visual UI tests re-planned at accessibilityL; strict OpenSpec validation green; digests: pre-fix 8ef18a69…, final shipped 06ce541e… (both in content-review.md).
- Not verified: VoiceOver audio pass, airplane-mode toggle, physical-device upgrade, iOS 16.4-old runtime. Claims in notes state exactly this.

## Proposed durable memory operations

- **ADD PIT-006** (pitfalls; PIT-004/005 are already taken): fixed `.system(size:)` typography + `UICTContentSizeCategoryL` default trap; verify enlarged-text claims with `UICTContentSizeCategoryAccessibilityL` and assert only what the layout proves (reachability), not scaling the app never does.
- **ADD CONV-004** (conventions): welfare-copy symptom→cause attribution must be tentative in *both* locales; test the modality with positive *and* negative substring assertions.
- IGNORE: subagent sessionID mishap (harness tooling, not a project fact); Swift type-check timeout and `isJSONNull` naming (already documented in code/test comments; one-off colour).
- No UPDATE/MERGE candidates: CONV-001/003, DEC-001, PIT-001/002/003 all stayed accurate as written.
- Observed drift, NOT touched (out of scope, flag only): `index.md` omits existing CONV-001 and PIT-001 entries.
