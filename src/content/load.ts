/**
 * The content loader: JSON in, typed content out.
 *
 * Every file under `data/` is parsed once, here, at module load. Validation
 * runs at startup rather than lazily because a malformed exercise should stop
 * the app in development with a message naming the file and the field, not
 * render a blank screen in front of someone with a puppy waiting.
 *
 * Everything the old hand-written modules exported is exported here under the
 * same name and type, so `catalogue.ts`, `nosework.ts`, `environments.ts` and
 * `mistakes.ts` are thin re-exports and nothing outside `src/content/` had to
 * change.
 *
 * Metro bundles JSON imports natively, so there is no fetch, no fs and no
 * async boundary — the content ships inside the binary, which is what an
 * offline-first app needs anyway.
 */

import type { ExerciseCategory } from '../db/schema';
import type {
  BehaviourIssue,
  CatalogueEntry,
  EnvironmentSeed,
  ExerciseSeed,
  Mistake,
  NoseworkActivity,
  StepSeed,
} from './schema';
import {
  parseBehaviourIssue,
  parseCatalogueEntry,
  parseEnvironmentSet,
  parseMistakes,
  parseNoseworkActivity,
} from './schema';

import comeJson from './data/exercises/come.json';
import downJson from './data/exercises/down.json';
import dropJson from './data/exercises/drop.json';
import handlingJson from './data/exercises/handling.json';
import leashJson from './data/exercises/leash.json';
import leaveJson from './data/exercises/leave.json';
import lookJson from './data/exercises/look.json';
import matJson from './data/exercises/mat.json';
import nameJson from './data/exercises/name.json';
import sitJson from './data/exercises/sit.json';
import stayJson from './data/exercises/stay.json';
import waitJson from './data/exercises/wait.json';

import cupsJson from './data/nosework/cups.json';
import findPersonJson from './data/nosework/find-person.json';
import findToyJson from './data/nosework/find-toy.json';
import scatterJson from './data/nosework/scatter.json';
import snuffleJson from './data/nosework/snuffle.json';
import trackJson from './data/nosework/track.json';

import comeMistakes from './data/mistakes/come.json';
import downMistakes from './data/mistakes/down.json';
import dropMistakes from './data/mistakes/drop.json';
import handlingMistakes from './data/mistakes/handling.json';
import leashMistakes from './data/mistakes/leash.json';
import leaveMistakes from './data/mistakes/leave.json';
import lookMistakes from './data/mistakes/look.json';
import matMistakes from './data/mistakes/mat.json';
import nameMistakes from './data/mistakes/name.json';
import sitMistakes from './data/mistakes/sit.json';
import stayMistakes from './data/mistakes/stay.json';
import waitMistakes from './data/mistakes/wait.json';

import environmentsJson from './data/environments.json';

import barkDoorJson from './data/behaviour/bark-door.json';
import barkWindowJson from './data/behaviour/bark-window.json';
import boltingJson from './data/behaviour/bolting.json';
import jumpingJson from './data/behaviour/jumping.json';
import nippingJson from './data/behaviour/nipping.json';
import noiseJson from './data/behaviour/noise.json';
import reactivityJson from './data/behaviour/reactivity.json';
import stealingJson from './data/behaviour/stealing.json';
import trafficJson from './data/behaviour/traffic.json';
import aloneJson from './data/behaviour/alone.json';

/** The file the data came from, so a validation error can name it. */
type Source = string;

/**
 * Every exercise file, in teaching order. Order lives here rather than in the
 * files because it is a property of the catalogue, not of an exercise, and
 * renaming a file should never silently reorder the app.
 */
const EXERCISE_FILES: readonly (readonly [source: Source, raw: unknown])[] = [
  ['exercises/name.json', nameJson],
  ['exercises/sit.json', sitJson],
  ['exercises/look.json', lookJson],
  ['exercises/down.json', downJson],
  ['exercises/stay.json', stayJson],
  ['exercises/come.json', comeJson],
  ['exercises/leave.json', leaveJson],
  ['exercises/mat.json', matJson],
  ['exercises/wait.json', waitJson],
  ['exercises/leash.json', leashJson],
  ['exercises/drop.json', dropJson],
  ['exercises/handling.json', handlingJson],
];

/** Every exercise the app ships, in teaching order. */
export const CATALOGUE: readonly CatalogueEntry[] = EXERCISE_FILES.map(([source, raw]) =>
  parseCatalogueEntry(raw, source),
);

const EXERCISES_BY_ID = new Map<string, CatalogueEntry>(CATALOGUE.map((entry) => [entry.id, entry]));

/** Look up one exercise by id. */
export function exerciseById(id: string): CatalogueEntry | undefined {
  return EXERCISES_BY_ID.get(id);
}

/** An exercise the code depends on by name — missing it is a programming error. */
function requireExercise(id: string): CatalogueEntry {
  const entry = EXERCISES_BY_ID.get(id);
  if (entry === undefined) {
    throw new TypeError(`content: no exercise with id '${id}' in data/exercises/`);
  }
  return entry;
}

/**
 * `siad` — the first exercise, exported on its own because the tests and the
 * onboarding flow both point at it specifically.
 */
export const SIT: ExerciseSeed = requireExercise('sit');

/** The structured ladders that predate the per-exercise files, by exercise id. */
export const STEPS: Readonly<Record<string, readonly StepSeed[]>> = {
  name: requireExercise('name').steps,
  look: requireExercise('look').steps,
  down: requireExercise('down').steps,
};

const NOSEWORK_FILES: readonly (readonly [source: Source, raw: unknown])[] = [
  ['nosework/scatter.json', scatterJson],
  ['nosework/snuffle.json', snuffleJson],
  ['nosework/cups.json', cupsJson],
  ['nosework/find-toy.json', findToyJson],
  ['nosework/find-person.json', findPersonJson],
  ['nosework/track.json', trackJson],
];

/** Every scent game, easiest first. */
export const NOSEWORK: readonly NoseworkActivity[] = NOSEWORK_FILES.map(([source, raw]) =>
  parseNoseworkActivity(raw, source),
);

const NOSEWORK_BY_ID = new Map<string, NoseworkActivity>(
  NOSEWORK.map((activity) => [activity.id, activity]),
);

/** Look up one activity by id. */
export function noseworkById(id: string): NoseworkActivity | undefined {
  return NOSEWORK_BY_ID.get(id);
}

const ENVIRONMENT_SET = parseEnvironmentSet(environmentsJson, 'environments.json');

/** The ladder, easiest first. */
export const ENVIRONMENTS: readonly EnvironmentSeed[] = ENVIRONMENT_SET.environments;

/** Rungs a puppy under six months should not be asked to work at yet. */
export const BEYOND_PUPPY_SCOPE: readonly string[] = ENVIRONMENT_SET.beyondPuppyScope;

/** The rung every exercise starts on. */
export const STARTING_ENVIRONMENT_ID: string = ENVIRONMENT_SET.startingEnvironmentId;

/** Categories in the order a puppy curriculum introduces them. */
export const CATEGORY_ORDER: readonly ExerciseCategory[] = ENVIRONMENT_SET.categoryOrder;

const MISTAKE_FILES: readonly (readonly [exerciseId: string, raw: unknown])[] = [
  ['name', nameMistakes],
  ['sit', sitMistakes],
  ['look', lookMistakes],
  ['down', downMistakes],
  ['stay', stayMistakes],
  ['come', comeMistakes],
  ['leave', leaveMistakes],
  ['mat', matMistakes],
  ['wait', waitMistakes],
  ['leash', leashMistakes],
  ['drop', dropMistakes],
  ['handling', handlingMistakes],
];

/** Troubleshooting entries, keyed by exercise id. No entry means no section. */
export const MISTAKES: Readonly<Record<string, readonly Mistake[]>> = Object.fromEntries(
  MISTAKE_FILES.map(([exerciseId, raw]) => [exerciseId, parseMistakes(raw, `mistakes/${exerciseId}.json`)]),
);

/** Mistakes for one exercise, or an empty list. */
export function mistakesFor(exerciseId: string): readonly Mistake[] {
  return MISTAKES[exerciseId] ?? [];
}

/**
 * Every behaviour problem the app ships. Order is what the owner browses:
 * the loud things first, the quiet suffering of being alone last.
 */
const BEHAVIOUR_FILES: readonly (readonly [source: Source, raw: unknown])[] = [
  ['behaviour/bark-door.json', barkDoorJson],
  ['behaviour/bark-window.json', barkWindowJson],
  ['behaviour/jumping.json', jumpingJson],
  ['behaviour/nipping.json', nippingJson],
  ['behaviour/stealing.json', stealingJson],
  ['behaviour/bolting.json', boltingJson],
  ['behaviour/reactivity.json', reactivityJson],
  ['behaviour/traffic.json', trafficJson],
  ['behaviour/noise.json', noiseJson],
  ['behaviour/alone.json', aloneJson],
];

export const BEHAVIOUR: readonly BehaviourIssue[] = BEHAVIOUR_FILES.map(([source, raw]) =>
  parseBehaviourIssue(raw, source),
);

const BEHAVIOUR_BY_ID = new Map<string, BehaviourIssue>(BEHAVIOUR.map((issue) => [issue.id, issue]));

/** Look up one behaviour problem by id. */
export function behaviourById(id: string): BehaviourIssue | undefined {
  return BEHAVIOUR_BY_ID.get(id);
}

/**
 * Every `practices` id on a behaviour card must name a real exercise — a
 * broken chip is a broken promise, not a soft link. Returns the problem
 * descriptions so the startup pass can throw with them and tests can check
 * the pass itself.
 */
export function practicesProblems(
  issues: readonly BehaviourIssue[],
  knownExerciseIds: ReadonlySet<string>,
): readonly string[] {
  const problems: string[] = [];
  for (const issue of issues) {
    for (const practice of issue.practices) {
      if (!knownExerciseIds.has(practice)) {
        problems.push(`behaviour/${issue.id} points at unknown exercise '${practice}'`);
      }
    }
  }
  return problems;
}

// Fail at startup, naming both sides of the broken reference.
const PRACTICE_PROBLEMS = practicesProblems(
  BEHAVIOUR,
  new Set(CATALOGUE.map((entry) => entry.id)),
);
if (PRACTICE_PROBLEMS.length > 0) {
  throw new TypeError(`content: ${PRACTICE_PROBLEMS.join('; ')}`);
}
