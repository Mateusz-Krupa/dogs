## Why

The Polish app contains mistranslations, grammatical mistakes, unclear instructions and overconfident training claims. The user approved all 126 numbered findings in `openspec/reviews/2026-10-23-polish-copy-audit.md` with “spoko popraw wszytko”; this change makes that selected wording implementable without changing training mechanics or losing native/Expo parity.

## What Changes

- Apply the audit's explicit replacements 001–126 to Polish UI and bundled content in both runtimes. Preserve unquoted sentences unless a selected item explicitly replaces the entire field.
- Keep English meaning aligned when the approved Polish correction changes advice, safety, criteria or a shared factual claim; do not perform an unrelated English rewrite.
- Apply item 124's Polish quotation-mark normalization throughout user-facing Polish fields. Item 125 approves its one fully written example, not unlisted rewrites of every payment metaphor. Item 126 approves its explicit replacement and the distinction between snapping, attempted biting and biting, not a global substitution.
- Correct the descriptions of the existing `drop` and `mat` tasks as selected in 024 and 036; do not add steps, change progression or alter stored completion data. Item 106 adds the approved toothbrush-familiarization wording within the existing stage, not a new stage.
- Add bounded acceptance coverage and an ID-to-field completion ledger. Update current native content-checksum expectations transparently with before/after evidence; preserve the migration's historical frozen snapshot.

## Capabilities

### New Capabilities

- `approved-bilingual-copy`: Traceable approved Polish corrections, semantically aligned English advice, native/Expo parity, and preservation of product/data invariants.

### Modified Capabilities

None. No published specifications exist. Existing active care and native migration changes overlap files but are not superseded by this change.

## Impact

Bounded surfaces: `src/content/data/`, `src/i18n/locales/`, the existing inline catalogue strings in `src/features/catalogue/ExerciseList.tsx`, matching `Pettrainer/Resources/Content/` and `Localizable.xcstrings`, and nearby content/localization/checksum tests. No dependencies, accounts, network, database migrations, stable ID changes or application architecture changes.

Non-goals: a full English editorial audit; additional veterinary protocols; global stylistic rewriting beyond selected text; schema/domain/persistence changes; finishing or archiving another active change. Preserve all pre-existing uncommitted care/migration work and serialize overlapping writes.

Implementation must use `/opsx-apply correct-approved-polish-copy` (Flash Next) after the independent plan-review gate. The user's selection of all audit IDs is recorded; any NEW review-driven wording/scope changes require separate numbered selection, not silent inclusion.
