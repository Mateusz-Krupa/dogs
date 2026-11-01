## Why

Owners can find individual behaviour cards but lack a clear starting point for understanding a puppy's needs, fear and escalating arousal. A small, source-backed guide will help them choose between reducing demands, meeting needs, seeking professional help and practising an existing skill, without treating emotions as obedience failures.

## What Changes

- Add an unrestricted **Szczeniak — dobry start / Puppy — a good start** entry near the top of the native catalogue, opening a compact hub.
- Offer four unscored foundations: rest and a quiet place; exploring the world without pressure; play with breaks; first short exercises.
- Add two canonical behaviour cards, available both through the hub and the existing problems list: **overarousal** and **fear/withdrawal**. These are descriptive situations, not diagnoses or treatment programmes.
- Link to existing `nipping` and `mounting` cards rather than duplicating them. Perform a bounded source/welfare and PL/EN review of these two cards; approve proposed replacements before applying them.
- Bundle original PL/EN educational copy, source titles/URLs and verification dates. Show safety/referral boundaries before actionable advice. Source links are optional external reading, never needed for core use.
- Preserve existing training, unrestricted access, raw history and per-context progress. No database migration, completion tracker, new scored exercise or network service.
- Non-goals: a full puppy curriculum, age-based locks, diagnosis quiz, sleep targets/timers, exposure quotas, medication/supplement advice, vaccination schedule, castration advice, new artwork system, account or analytics.

## Capabilities

### New Capabilities

- `puppy-start-guidance`: Offline bilingual puppy hub, four unscored foundations, canonical situation links, safe sourced content, accessible native navigation and isolation from training persistence.

### Modified Capabilities

None. Existing `approved-bilingual-copy` requirements continue to protect prior approved edits; this change does not grant a general copy rewrite or change its historical provenance requirements.

## Impact

- Native Swift only: `Pettrainer/Content/` models/validators/loader/manifest, `Pettrainer/Resources/Content/`, `Localizable.xcstrings`, `Pettrainer/Features/Catalogue/`, a small `Features/Puppy/` area, `Features/Problems/ProblemView.swift`, and app routes/destinations.
- Additive behaviour-source metadata must remain compatible with existing cards. Reuse current `Localized`, `Checks`, source URL validation and native styling where appropriate.
- Targeted XCTest/UI tests cover validation, cross-links, welfare ordering, locales, offline reading and unchanged session/progress state. Existing checksum fixtures change only for the approved resource set with before/after evidence; frozen migration snapshots remain untouched.
- Active migration/care work and extensive existing working-tree changes are not owned by this proposal. Recheck shared files at apply time; do not restore retired JS or overwrite other work. Preserve all existing catalogue entries/routes.
- `sources.md` captures research support and limitations. Source review is not veterinary endorsement.
- Independent reviewer plan gate, user selection of any numbered findings, explicit implementation approval, approved bilingual-copy gate, targeted verification and independent final review are required. Artifact completion alone grants no implementation permission.
