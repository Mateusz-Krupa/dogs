## Context

The approved audit is `openspec/reviews/2026-10-23-polish-copy-audit.md`, IDs 001–126. Most changes are string replacements, but selected findings correct advice and observable criteria. Expo authors content in `src/content/data/`; the native app bundles corresponding files under `Pettrainer/Resources/Content/`. UI strings live in the locale catalogues, inline catalogue copy, and the native String Catalog.

The active hygiene-care and native-migration changes have uncommitted overlapping edits. Their existing files are the starting point, not noise to reset. Native checksum expectations currently describe historical content, so blindly regenerating the migration baseline would erase provenance.

## Goals / Non-Goals

**Goals:** implement exactly the approved corrections in existing fields, preserve product invariants, keep English advice semantically consistent, and verify source/native byte parity and traceability.

**Non-Goals:** new exercises/stages, veterinary treatment protocols, persistence/schema/domain changes, new abstractions/dependencies, unrelated English polish, any unlisted global stylistic rewrite, or changes to another feature's scope.

## Decisions

1. **Audit-as-contract plus a small completion ledger.** At apply start create `implementation-notes.md` here with one row per audit ID: current source path/field, native counterpart, PL outcome, EN disposition (aligned/already equivalent/not applicable), and check/evidence. Record rows only from actual edits/checks. Use the explicit replacement rather than reconstructing it from the summary. Already-correct live text counts only after comparison. Unexpected drift/conflicting edits blocks that row; do not overwrite another session's wording.

   Alternative: global search/replace. Rejected because sentence-level changes overlap full-field changes, quoted text may be only part of a field, and the current working tree is changing concurrently.

2. **Bounded common changes.** Normalize Polish quotation pairs (124) without touching JSON escaping, stable IDs, apostrophes or English fields. Implement the explicit sentence in 125 only. Preserve snapping/attempted-bite/bite distinctions per 126. Existing UI interpolation syntax remains runtime-specific (`{{…}}` versus `%…`). The native-only level-count correction 012 also applies to the equivalent inline Expo label if still present; use its existing numeric interpolation, not a new localization architecture.

3. **Meaning alignment, not literal translation.** For every approved sentence compare the corresponding EN advice. Correct EN when required to retain the approved timing, criterion, risk/referral or factual meaning; leave it unchanged when it already expresses the corrected meaning (for example the waiting-for-a-look explanation). Record the decision in the ledger. Do not introduce new advice while translating. Any material ambiguity or new reviewer-suggested wording returns to the user as a numbered decision.

4. **No content topology or behaviour changes.** Findings 024 and 036 revise criterion text to match the current instructions; they do not change the five-rep algorithm or attempt to infer success automatically. For 106 use the approved familiarization instruction in the existing stage's setup before brushing; do not add an ordinal or make the routine scored. Keep every stable cue/content ID, ordinal, stage/step count, environment ordering, gear binding and advisory link unchanged.

5. **Transparent current checksums; immutable historical baseline.** Keep `migrate-to-native-swift/baseline/parity-data.json`, its historical digests and original provenance intact. Before copy edits capture the starting hashes of touched data files in this change's `approved-content-delta.md`; after mirroring record new hashes and audit IDs, with care/untracked files identified as working-tree inputs rather than original baseline. Update only affected entries in `PettrainerTests/ContentChecksums.swift` and its comment to describe historical baseline plus this approved copy revision. Reuse the existing checksum test, with an accurate name/comment if necessary; do not disable assertions or update untouched hashes. Source/native parity must be checked independently of expected checksums. Coordinate this shared fixture with the care/migration writer before touching it.

   Alternative: regenerate the frozen snapshot. Rejected because current editorial corrections must not masquerade as migration-capture content. No new runtime checksum mechanism is needed.

## Risks / Trade-offs

- **Welfare regression while simplifying copy** → independent pre-apply review; no new treatment advice; professional referral remains visible before DIY instructions for bite-history aggression, escalating guarding, severe separation distress and possible pain. No aversives, error markers, forced restraint or locks.
- **Longer labels wrap on phones** → check selected long labels, banners and care stages in PL/EN at phone size and large text; do not silently shorten approved sentences. Report layout blockers for a separate decision.
- **UI count correction diverges by runtime** → preserve interpolation types and check rendered numeric examples in each runtime, including a count outside 2–4.
- **Concurrent edits / checksum churn** → sequential file ownership, live-text comparison before each batch, no reset/stash/checkout; preserve other work and record only the copy delta.
- **Overly broad approval interpretation** → 001–126 explicit wording is approved; audit sections explicitly marked future/undecided remain out of scope. A new independent finding is not covered by the earlier “all”.

## Migration Plan

No database migration, reseeding, account, network or destructive rollback is permitted. Updated bundled strings load through the existing content path. Existing per-dog/exercise/environment progress, raw reps, incomplete sessions, offline history and care attempted-stage records remain unchanged. If a regression is found, revert only this change's identified copy/checksum delta, never the user's database or unrelated working-tree changes.

## Open Questions

No additional product choice is needed for the explicit approved replacements. Independent review is mandatory and still pending. Any new safety/wording issue from that review must be presented with stable IDs for user selection before amending this plan or the text contract.
