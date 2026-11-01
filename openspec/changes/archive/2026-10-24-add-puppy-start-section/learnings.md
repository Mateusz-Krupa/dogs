# Learnings — add-puppy-start-section (2026-10-24)

## Intent vs outcome

Planned: a source-backed puppy hub (4 guides + 2 situation cards) with zero persistence, provenance and welfare gates. Delivered as planned plus two unplanned rounds driven by evidence: an owner feedback round (rows lacked thumbnails → `pose` field + 2 new ProblemScenes) and the final review (a launch-bricking calendar bug). All gates produced findings; none were empty.

## Wrong turns and corrections that worked

- **`try? parse(...)` inside `XCTAssertThrowsError`** silently converts a throw to `nil` and the assertion passes vacuously. Two negative tests were green-but-fake until the deliberate-failure comparison exposed them. Write `XCTAssertThrowsError(try …)`.
- **Raw-string `#"…\"…\"#`** keeps literal backslashes — a fixture built that way was invalid JSON (NSCocoaError 3840) masquerading as a validator bug. Normal interpolation `",\"\(key)\":1"` is the readable form.
- **A regex patcher that pasted `\n<indent>` inside quoted digests** produced checksum values with leading spaces. Prefer whole-line replacement or explicit string pairs when editing fixed-format Swift dictionaries; the checksum test caught it loudly.
- **Scripted xcstrings insertion via `dict → (en, pl) tuple unpacking`** silently wrote the strings "en"/"pl" as the values — the compile-time-visible-but-also-invisible class of bug where only reading the values back proves the write. Read back and print actual values after any catalog script.
- **XCUITest `staticTexts["Sources"]` queries identifiers, not labels**; plain `Text` has none. Combined with `.textCase(.uppercase)` on section headers, the correct query is `NSPredicate("label CONTAINS[cd] %@")`. The care suite already used expect() by label for exactly this reason.
- **First cold launch after a fresh install** ate the 15 s catalogue-load budget in the alphabetically-first UI test once the binary grew; 30 s for the very first expect removed the flake. Simulator is E62B27CA…, two identical device names exist — always pass the UDID.
- **Several tool calls rendered with garbled paths/doubled tokens in this session**; every landed change was re-verified against disk (grep/python readback) before building, which converted several would-be silent corruptions into caught ones. One garbled write created `Content/p/`; found and moved by the verification pass.

## Decisions and rationale

- **Date validation must be device-independent** (FR-1): bundled `verifiedOn` compared against `Calendar.current` false-futures on era-calendar (Japanese/Islamic) devices; compared against UTC it false-futures at local midnight; final rule is fresh `.gregorian` + `TimeZone.current`, with the timezone injectable for deterministic tests. Content validation failure is a launch-time `fatalError` — any date rule that can reject valid content is an app-bricking rule.
- **Lazy position + empty active set are ordinary catalogue behaviour** (P-1): raw-state tests must assert the exact initialization delta (one position, one zero-rep session, everything else identical), not "no writes" — and separately that an in-progress or choice-pending set is byte-stable across guidance open/return.
- **Blanket implementation approval ≠ deleted gates**: source re-reads, an independent copy reviewer (round C, 14 findings) and a final code reviewer (FR-1..3) still ran; the implementer triaged instead of the user, with accept/reject and rationale in notes.md.
- **Icons reusing existing primitives, not a new system**: `pose` on guides (same vocabulary/validator as care), two hand-drawn ProblemScenes, and `IllustrationContractTests` extended to every card id so "every welfare card has a thumbnail" is now a tested invariant, not a vibe.
- Personal owner-dog details stayed out of specs, content and memory.

## Classification

- **project**: FR-1 calendar rule; P-1 lazy-initialization contract; "staticTexts subscript = identifiers" XCUITest pitfall; xcstrings value readback; expect() 30 s first-launch budget; checksum ledger key-equality guard (P-2).
- **procedural**: copy-review ledger format (claim→source→field table, EN dispositions) as a reusable artifact for welfare content changes.
- **local**: this feature's specific copy decisions (in content-review.md, not promoted).

## Memory impact

- Retrieved: only the unrelated `opencode-implement` bridge entry (noise; correctly excluded by both implementer and reviewers, twice).
- Local fallback consulted: **CONV-001** (EN-field alignment — directly drove round C-12 acceptance), **PIT-001** (nested-locale walker — drove fixture + quote-pair tests). Both earned their keep.

## Proposed durable operations (await approval)

1. **ADD PIT**: "Never validate bundled content dates with `Calendar.current`; fresh `.gregorian` + `TimeZone.current`, timezone injectable — content load failure is a launch fatalError." (evidence: this change's notes FR-1, PuppyGuideValidatorTests)
2. **ADD PIT**: "XCUITest: `staticTexts["X"]`/`buttons["X"]` match identifiers only; plain Text needs label predicates (CONTAINS[cd] for .textCase headers); and the first cold launch after install needs ~30 s before catalogue assertions." (evidence: PuppyFlowUITests fix history)
3. **ADD CONV**: "Guidance/exercise-link persistence contract: lazy position+empty set allowed for a never-opened exercise; byte-stability asserted for partial and choice-pending sets; educational browsing writes nothing." (evidence: design §5, P-1, PuppyIsolationTests)
4. **UPDATE/keep PIT-001**: unchanged; it fired correctly. No conflicts found; nothing to merge.

## Verification evidence

See notes.md rounds P / implementation / C / icons / FR for each executed command and result. Limitations: no physical device or App Store build checks in this change; VoiceOver/Dynamic Type only verified structurally (identifiers, combine, fixedSize) on the simulator; sources are organizational guidance, not clinical endorsement of this app.
