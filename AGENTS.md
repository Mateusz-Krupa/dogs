# pettrainer

A dog-training app for phones. Offline-first, no account, Polish and English.

## What the product is

Every dog-training app teaches "sit". This one exists for the problem none of them
solve: a cue that works in a quiet kitchen collapses in a park full of dogs. Dogs do
not generalize context by default, so a behaviour learned in one place is, to the dog,
a different behaviour somewhere else.

Two consequences run through the whole codebase:

1. **Mastery is per (dog × exercise × environment)**, never a single boolean per
   exercise. A `completed: boolean` anywhere in progress code is a design error.
2. **Progress has two axes.** The *installation* axis is the ordered micro-steps
   inside one exercise. The *generalization* axis is the ladder of environments
   (quiet room → garden → street → park → near other dogs). Entering a harder
   environment means dropping back some steps and re-climbing.

## The core rule — do not get this wrong

Training happens in sets of exactly **5 repetitions**. The verdict:

- **5 of 5** → `push` (advance a step)
- **3 or 4 of 5** → `stick` (repeat the same level)
- **0, 1 or 2 of 5** → `drop` (go back a step)

`push` requires five out of five. A widely-copied version of this rule on the web says
"push on 4 or 5" — that is an 80% threshold and it is **wrong**. `stick` is a two-wide
band covering both 3 and 4. A cancelled repetition counts as a failure.

Verdicts are **never stored**. They are always computed from raw `Rep` rows, so a
future change to the thresholds does not invalidate history.

## Hard product rules

- **Never gate content.** Exercises declare prerequisites, and the app uses them to
  *recommend* and to warn. It never locks anything. The owner knows their dog.
- **Red flags route to professionals.** Aggression with a bite history, escalating
  resource guarding, sudden behaviour change suggesting pain, and severe separation
  anxiety short-circuit the troubleshooting flow toward a vet or certified
  behaviourist. No DIY fix is offered for these.
- **No aversive advice, ever.** The app must not reproduce alpha rolls, scruff shakes,
  bark collars, or punishing a growl.
- **No error markers.** On a failed rep the app resets silently and lowers criteria;
  it does not emit a "no!" signal.

## Stack

Expo + React Native, TypeScript (strict). `expo-sqlite` for local progress,
`i18n-js` + `expo-localization` for Polish and English. Node is pinned in `.nvmrc`
to v22.22.3 — the system default is older and will not run Expo.

- `src/domain/` — pure logic, no I/O, no React. The verdict rules live here.
- `src/db/` — schema and migrations.
- `src/i18n/` — locale catalogues. No user-facing string is ever hardcoded.
- Cue names are domain data with a name per locale (`siad`/`sit`), not UI strings.

## Conventions

- Strict TypeScript, no `any`. Named exports; no default exports outside components.
- Two-space indent, single quotes, semicolons.
- Tests live next to the code as `*.test.ts`. Run one file, not the whole suite:
  `npx jest src/domain/verdict.test.ts`. Typecheck with `npm run typecheck`.

## For Claude

Implementation work in this repo is routed through the `opencode-implement` skill —
load it when implementation starts. That routing decision belongs to Claude alone.

If you are an implementer agent working on a specific task: just do the task. Do not
load that skill, do not run `oc.sh`, and do not spawn other agents.
