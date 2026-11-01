# Learnings — correct-approved-polish-copy

## Intent vs. outcome

**Intent:** Apply all 126 approved Polish copy corrections across Expo content JSON,
locale catalogues, inline UI strings, and native Swift resources, while preserving
welfare boundaries, domain invariants, and native/Expo parity.

**Outcome:** 123 of 126 findings applied. 3 rows (092, 101, 105) correctly paused
because concurrent `add-hygiene-care-section` work had already corrected those fields
with its own welfare-approved wording. Welfare intent was preserved in all cases.

## Plan vs. reality

- The plan anticipated concurrent conflicts in `care/` files but did not predict that
  the `walk_and_fix` typography walker would silently miss nested PL strings (see PIT-001).
- The pre-implementation reviewer caught RV-001 (contradictory native-only instruction
  in notes.md) before edits began — that gate prevented a real scope error.
- The final reviewer caught FR-001/FR-002 (EN welfare fields and criteria not aligned)
  and FR-003/FR-004/FR-005 — all fixed before archive. Without that review pass,
  two welfare-critical English fields would have contradicted the corrected Polish meaning.

## Wrong turns and what worked

**PIT — Nested PL string walker missed 50 quotation-pair instances.**
The `walk_and_fix` function checked `if k == 'pl'` for strings/dicts/lists, then
recursed only into `pl`-keyed values. For `names: { pl: { name: "...", description: "..." } }`
it entered the `pl` dict but then treated `name`, `description` etc. as ordinary keys and
skipped them because they don't match `k == 'pl'`. This caused Phase F to report 19 fixes
when 69 were needed. The error was caught by the reviewer (FR-004), not by the existing
tests (no test checked the quotation pair globally). Fix: when recursing into a `pl`
dict, walk ALL string values regardless of their key name.

**PIT — Python 3.13 rejects `\uXXXX` in `re.sub` replacement strings.**
The first Phase F implementation used `re.sub(r'...', r'\u201e\1\u201d', text)`. Python 3.13
raises `PatternError: bad escape \u` for the replacement template. Fix: use a lambda
(`lambda m: '\u201e' + m.group(1) + '\u201d'`) or pass the actual Unicode character literals.

**PIT — EN welfare fields must be aligned, not assumed equivalent.**
The implementer's reasoning "EN already says the right thing" was correct for most findings,
but wrong for the resource-guarding referral (045), nipping warning (068), snuffle paper
ingestion (120), and two EN criteria (024, 036). These required an explicit EN field update,
caught by the final reviewer. The rule: for welfare and criteria fields, always diff EN text
against the approved PL meaning and record the disposition in the ledger. Do not skip the
EN check even when PL is clearly a language-only fix.

**What worked:** Capturing before-hashes in `approved-content-delta.md` before any copy
edits allowed the checksums and parity to be verified independently after the fact.
The reviewer's read-only constraint correctly prevented it from overwriting or "fixing"
the concurrent care feature's changes.

## Decisions and rationale

- **Conflicts: pause, do not overwrite.** Findings 092/101/105 were recorded as incomplete
  audit rows rather than forcibly overwritten with audit wording. The concurrent care feature
  had already addressed the same welfare concerns (medication guarantee removed, xylitol
  overclaim softened, gum-bleeding referral corrected) using its own welfare-reviewed wording.
  Overwriting would have undone the care feature's independently verified text.

- **Checksums: update current file, keep frozen baseline immutable.** `ContentChecksums.swift`
  was updated for 40+ changed files and its comment corrected to describe current-repo digests.
  `migrate-to-native-swift/baseline/parity-data.json` was never touched. `approved-content-delta.md`
  carries the before/after audit trail.

- **New test file vs. extending existing tests.** A new `copy-welfare.test.ts` was created
  rather than embedding welfare-critical string assertions into the schema/load tests.
  Rationale: welfare assertions change when copy changes; schema tests should validate
  structure and remain stable.

## Memory impact

**Entries retrieved:** 1 (`[skill] opencode-implement` — unrelated to this task; not relied upon).
**Impact on task:** None — the task did not involve the opencode CLI or Claude delegation.

## Verification evidence

- 140/140 Jest tests (including 26 new welfare assertions) — passed.
- `npm run typecheck`: clean.
- `xcodebuild test` (iPhone 15 Pro sim E62B27CA…): 33/33 native tests, TEST SUCCEEDED.
- Byte parity: 50/50 source↔native content files identical.
- Structure: IDs, ordinals, counts, environment ordering, gear, EN fields all unchanged.
- Migration baseline `parity-data.json`: unchanged.
- `openspec validate --strict`: valid.

## Not verified

- Task 5.5 (manual phone-size PL/EN visual layout check): cannot be done programmatically.
- Physical device behaviour (SQLite, lifecycle, offline): no device session available.
- Independent reproduction of test results in a fresh worktree.

## Lesson classification

| ID | Class | Lesson |
|----|-------|--------|
| PIT-001 | procedural | Nested `pl` dict walker must process ALL string sub-keys, not only keys named `pl`. |
| PIT-002 | local | Python 3.13 `re.sub` replacement template rejects `\uXXXX`; use a lambda or literal chars. |
| CONV-001 | project | Welfare/criteria copy changes: always diff EN field against corrected PL meaning; record disposition. Do not assume EN is already aligned. |
