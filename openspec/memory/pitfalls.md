# Pitfalls

<!--
Entry format (each ## section is one retrievable memory):

## PIT-001: Short imperative title
**When relevant:** comma, separated, retrieval, keywords
**Learning:** The durable fact a future agent should know before working here.
**Why:** Why it is true / what went wrong when it was ignored.
**Evidence:**
- openspec/changes/archive/YYYY-MM-DD-<change>
**Last verified:** YYYY-MM-DD

Populated by /opsx-archive reflection. Do not hand-edit for one-off details.
-->

## PIT-001: Nested `pl` dict walker must process all string sub-keys
**When relevant:** batch scripts editing bilingual JSON content, typography normalisation, copy sweep
**Learning:** In content JSON the bilingual pair lives under a `pl`/`en` key whose value is a dict
(e.g. `steps[].pl.instruction`, `names.pl.name`). A walker that only processes strings whose immediate
parent key equals `'pl'` silently skips every nested sub-field. When entering a `pl` dict, recurse into
ALL string and list-of-string values regardless of their sub-key name.
**Why:** Phase F of `correct-approved-polish-copy` reported 19 fixes; 50 quotation-pair defects
remained and were caught only by the independent final reviewer (FR-004).
**Evidence:**
- openspec/changes/archive/2026-10-23-correct-approved-polish-copy/learnings.md
**Last verified:** 2026-10-23

## PIT-002: Bundle-content date checks must ignore the device calendar style
**When relevant:** content validation, verifiedOn/evidence dates, anything gating bundled JSON at load
**Learning:** Validate content dates against a fresh `Calendar(identifier: .gregorian)` with
`TimeZone.current` (timezone injectable for tests). Never `Calendar.current`, never fixed UTC.
**Why:** `Calendar.current` on an era-calendar device (Japanese/Reiwa → year 8) false-futures every
2026 file; a UTC-only clock false-futures files verified "today" at local midnight ahead of UTC.
Content validation failure is a launch-time `fatalError` — a date rule that can reject valid content
bricks the app. Both failure modes shipped into this repo's branch before FR-review caught them.
**Evidence:**
- openspec/changes/archive/2026-10-24-add-puppy-start-section/notes.md (round FR-1)
- Pettrainer/Content/Validators/PuppyGuideValidator.swift (`today(_:timeZone:)`)
**Last verified:** 2026-10-24

## PIT-003: XCUITest element lookups match identifiers, not labels; cold launch needs ~30 s
**When relevant:** UI tests asserting on plain `Text`, section headers, first launch of a suite
**Learning:** `app.staticTexts["X"]` queries accessibility **identifiers** — plain `Text` has none, so
find welfare labels with `NSPredicate("label CONTAINS[cd] %@")` (headers render `.textCase(.uppercase)`,
never `==` the raw copy). The first expect() after a fresh install should budget ~30 s for catalogue
load, or the alphabetically-first test flakes on busy machines.
**Learning (addition, 2026-10-31):** For phone-size PL/EN inspection of copy-only changes, a
temporary XCUITest screenshot harness can navigate the real screens, expand disclosures and attach
screenshots without ever tapping the scoring buttons; delete it afterwards and verify no harness
residue remains in `git status`. This proves inspected rendering only — a zero rep counter does not
prove write-free navigation, database preservation, physical-device lifecycle or disconnected use.
**Why:** PuppyFlowUITests failed twice on `staticTexts["Sources"]` ("IN identifiers") and once on a
15 s cold-start budget before both fixes; a green targeted re-run proved the code was never wrong.
The loose-lead change used a temporary harness for two PL/EN passes and 18 attachments without
scoring, so one-off screenshot automation never entered the committed suite.
**Evidence:**
- openspec/changes/archive/2026-10-24-add-puppy-start-section/learnings.md
- PettrainerUITests/PuppyFlowUITests.swift (`expect`/`label` helpers)
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/learnings.md
**Last verified:** 2026-10-31


## PIT-004: Validate bundled JSON syntax with a JSON parser, not plutil lint
**When relevant:** editing bundled content JSON, syntax validation, misleading lint failures
**Learning:** Validate syntax of the bundled content resources with a JSON parser. `plutil -lint`
rejects these files even when untouched, so its verdict alone is not evidence of malformed JSON.
Keep syntax parsing separate from the content loader/validator tests, which check decoded structure
and the domain constraints that actually ship.
**Why:** Treating a property-list lint rejection as a JSON defect points investigation at valid
content and never checks the application's real content contract.
**Evidence:**
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/notes.md
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/learnings.md
**Last verified:** 2026-10-31

## PIT-005: Clean suspected stale test binaries before diagnosing current assertions
**When relevant:** xcodebuild incremental runs, changed assertions, output inconsistent with source
**Learning:** When a targeted incremental run appears to execute an old assertion, or its output
disagrees with the current test source, run `xcodebuild clean` for the same project/scheme and rerun
the relevant classes before diagnosing or editing application content. A green or red rerun while the
binary is suspected stale proves nothing about the current assertions; include decoded runtime values
in failure diagnostics where that makes the next read unambiguous. This is a staleness recovery step,
not a rule to clean every normal run.
**Why:** An updated PuppyContentTests assertion still ran against a stale incremental binary and
produced a false failure; the clean rerun passed with no content change.
**Evidence:**
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/notes.md
- openspec/changes/archive/2026-10-31-expand-loose-lead-guidance/learnings.md
**Last verified:** 2026-10-31

## PIT-006: Fixed `.system(size:)` typography never scales; "large text" checks need AccessibilityL
**When relevant:** UI verification of Dynamic Type / larger-text requirements, XCUITest launch
arguments for content size, visual screenshot claims
**Learning:** Every pettrainer screen renders with fixed `.system(size:)` fonts, so a Dynamic Type
category does NOT enlarge app text. `UICTContentSizeCategoryL` is the DEFAULT size — using it to
"prove" larger-text support verifies nothing. For an honest enlarged-state check launch with
`-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityL` and assert only what the
fixed layout actually guarantees: the content still opens, scrolls and stays fully reachable in both
locales. Say "reachability at accessibility sizes", never "scales with Dynamic Type", unless the
fonts themselves become scalable.
**Why:** add-puppy-toilet-guidance recorded "large Dynamic Type verified" on a UICTContentSizeCategoryL
run; the final reviewer (F-1) caught that L is the default category and that the guide's fonts do not
scale at all, so the claim had to be re-planned and re-run at accessibilityL.
**Evidence:**
- openspec/changes/archive/2026-10-31-add-puppy-toilet-guidance/learnings.md
- PettrainerUITests/PuppyToiletVisualTests.swift
**Last verified:** 2026-10-31
