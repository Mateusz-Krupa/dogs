# Parity manifest — JS baseline (frozen reference)

Captured at apply start. Everything below is the contract the native port must
meet before any JS deletion. Machine-checkable data lives in
`parity-data.json` (content, bindings) and `locale-keys.json` (UI strings);
this file adds the curated checklists and evidence notes.

## Provenance

- Source commit: `5a1bdb5f8446162db46813c497c6975a97262caf` (2026-10-21) — `build(ios): prebuild the native project…`
- Working tree at capture: only untracked `build/` and OpenSpec change dirs; `src/` clean.
- Checksums: SHA-256, `shasum -a 256` over `src/content/data/**` (41 files, listed in `parity-data.json → files`).
- Generator: `gen_manifest.py` (re-runnable; must produce byte-identical `parity-data.json`).

## Content inventory (verified counts)

- 12 exercises; order (teaching order, from `load.ts` — NOT filename order):
  `name, sit, look, down, stay, come, leave, mat, wait, leash, drop, handling`
- 12 mistakes files (one per exercise), 6 nosework activities, 10 behaviour cards:
  `bark-door, bark-window, jumping, nipping, stealing, bolting, reactivity, traffic, noise, alone`
- 23 environment rungs, start `quiet-room`; `beyondPuppyScope = dogs-close,
  toy-in-motion, dogs-playing, wildlife-fleeing`; `categoryOrder = foundation,
  impulse_control, advanced`. Full rows embedded verbatim in `parity-data.json`.
- Exercise JSON shape: `category, gear, id, names{pl,en{name,description}}, pose,
  requires, sortOrder, steps[{ordinal, motion, pose?, sound?, pl{instruction,
  criterion, setup?, reps?, note?, title?}, en{…}}], tagline{pl,en}`.
- Nosework level shape: `ordinal, minutes, gear, pl/en lists`; no scoring fields.
- Behaviour card shape: `id, sortOrder, urgent, professional{pl,en},
  recognizes/now/work/practices/avoid {pl,en}, names{pl,en{name,description}}`.

## UI localisation

- 81 leaf keys per locale, PL/EN symmetric (no one-sided keys), **zero `%{...}`
  interpolations** in either catalogue; top-level blocks: common, session, gear,
  nosework, problems, verdict, today, dog, errors. Details: `locale-keys.json`.

## F-4 — inline bilingual copy outside `src/i18n` (must map into String Catalog)

| Where | Copy |
| --- | --- |
| `App.tsx:142` | dog label: “Your dog” / “Twój pies” |
| `App.tsx:176` | bar meta word “step” / “krok” (+ ordinals) |
| `ExerciseList.tsx:112` | chip “next up” / “na teraz” |
| `ExerciseList.tsx:144–147` | “Step x/y” / “Krok x/y”, “N steps” / “N kroków” |
| `ExerciseList.tsx:154–156` | prerequisite hint (two full sentences + joiner “and”/“i”) |
| `ExerciseList.tsx:178–183` | “Training plan” / “Plan treningu” + openness subline |
| `ExerciseList.tsx:226–228` | “N levels” / “N poziomy” |
| `SetScreen.tsx:201` | disclosure “About this exercise” / “O tym ćwiczeniu” (+ `+/−` chevron) |
| `SetScreen.tsx:210` | “When it is not working” / “Gdy coś nie idzie” |
| `SetScreen.tsx:230` | mistake action label “TRY THIS” / “SPRÓBUJ TAK” |

Disclosure interactions to port: `showAbout` toggle; `openMistake` one-at-a-time expand (`SetScreen.tsx:122–123,197–231`).

## Diagram bindings (from `StepDiagram.tsx` + `schema/checks.ts`)

- 18 motions: `up, down, draw, hold, away, leg, refuse, deny, swap, contact,
  touchPaw, lift, face, return, collar, door, bowl, toss` (semantic comments in checks.ts).
- Default motion per exercise: `name:hold, sit:up, look:up, down:down, stay:hold,
  come:away, leave:refuse, drop:swap, wait:hold, leash:away, mat:down, handling:contact`;
  per-step `motion`/`pose`/`sound` overrides exist in step JSONs (see `parity-data.json → exercises.*.steps`).
- 10 poses: `sit, down, stand, stay, come, look, mat, leave, sniff, search`.
- 14 gear ids: `treats, lead, longline, mat, towel, box, toy, cups, clippers,
  bowl, helper, door, grass, nothing`.
- Stage policy (`lureStages.ts`, copied verbatim into `parity-data.json → diagrams.lure_stages`).
- Canvas 100×100, ground y=82, dog faces right in every pose (StepDiagram header doc).

## Screen/action state inventory (parity checklist)

- Catalogue: dog heading + openness subline; per-exercise card (name, tagline,
  step meta or “N steps”, gear row, “next up” chip, prerequisite hint, progress
  rail/pct, environment name, ladder-complete and fully-generalized markers,
  rungs cleared); nosework rows (tagline, level count, level-done); problem rows;
  recommendation = first untouched exercise else first.
- Session: step rail, instruction/structured setup+reps+note, criterion block,
  diagram with stage, 5 rep controls (hit/miss/cancelled semantics per
  `RepOutcome`), undo, decided-state copy, verdict badge (push/stick/drop
  colors green/amber/brick), easier/same/harder choice row with recommendation
  marking but all buttons live, harder/easier place-change explanation banner,
  about + mistakes disclosures, back to catalogue.
- Nosework: hero pose, description, “not scored” note, level selector +
  level detail (setup lines, minutes, gear), single Done action, restart keeps
  highest visited level.
- Problems: header (name, description), urgent/stop-line block, recognizes/now/
  work/practices/avoid sections, related-exercise links open the session.
- Global: safe-area bars, `‹ All exercises` back, StatusBar auto; PL and EN pass of every state above.

## SQL seed mapping (native decision, not present in JS runtime)

- JS runtime never wrote SQL (verified: no callers of `runMigrations`).
- Native seed rule: `exercise.id` = JSON id; `step.id` = `<exerciseId>#<ordinal>`;
  `environment.id` = JSON id; default dog id = `dog.default` (created idempotently).
  Recorded here so native `mastery`/`session` fixtures are reproducible.

## Deployed-storage evidence (metadata only, no personal data read)

- One simulator (`996BC188…`) holds an installed `pettrainer.app` bundle
  v0.1.0, id `com.mateuszkrupa.pettrainer`.
- No app SQLite file found anywhere under that device’s data containers
  (only unrelated system `.sqlite` files) — consistent with the unwired `src/db/`.
- Physical-device installs and TestFlight binaries are NOT verifiable from this
  machine right now; update-in-place and any real legacy storage must be checked
  at tasks 8.3/8.4 gates. If a legacy store is ever found, the F-3 classification
  table applies and raw reps are never rewritten.
