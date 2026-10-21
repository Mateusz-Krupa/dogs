/**
 * Types and runtime validation for the training content in `data/`.
 *
 * The content itself is JSON — it is edited far more often than the code around
 * it, and a reviewer should be reading a diff of prose, not of object literals.
 * JSON has no types and no checks, so both live here: the interfaces below are
 * what the app compiles against, and the `parse*` functions are what make sure
 * the files actually match them.
 *
 * Validation runs once, at module load, and throws a `TypeError` naming the
 * file and the field path — `sit.json: steps[3].pl.criterion must be a
 * non-empty string` — because the person who hits it is editing JSON, not
 * debugging TypeScript. Hand-written rather than a schema library on purpose:
 * the shapes are small, and a library's error messages name its own internal
 * paths rather than the key the editor has their cursor on.
 */

import type { ExerciseCategory } from '../db/schema';
import type { StepMotion } from './schema/checks';
import type { GearId } from '../ui/Gear';
import type { Pose } from '../ui/DogPose';

/** One language's copy for a step. */
export interface StepCopy {
  /** One-line summary. Used on cards and wherever the full form does not fit. */
  readonly instruction: string;
  /** What counts as a correct rep. The owner scores against exactly this. */
  readonly criterion: string;
  /** What to arrange before the dog is involved. Two or three imperatives. */
  readonly setup?: readonly string[];
  /** One repetition, start to finish, in order. */
  readonly reps?: readonly string[];
  /** The one trap worth naming, with its reason. Omitted when there isn't one. */
  readonly note?: string;
  /** Heading for the step. Not written yet — blank in the JSON means unwritten. */
  readonly title?: string;
}
/** One micro-step on the installation ladder. */
export interface StepSeed {
  /** 1-based position in the ladder. */
  readonly ordinal: number;
  /**
   * What the diagram draws for this step. Defaults to the exercise's motion;
   * a step that practises something else — stepping away, the collar grab —
   * names its own motion so the picture cannot drift from the instruction.
   */
  readonly motion?: StepMotion;
  /** Pose override for steps that practise the behaviour in a different stance. */
  readonly pose?: Pose;
  /**
   * Whether the owner's voice is part of this step. Drives the sound mark in
   * the diagram; verbal ladder stages imply it, so it is only set where food
   * is still in play and the word rides alongside it.
   */
  readonly sound?: boolean;
  readonly pl: StepCopy;
  readonly en: StepCopy;
}

/** An exercise with everything needed to seed it. */
export interface ExerciseSeed {
  readonly id: string;
  readonly category: ExerciseCategory;
  readonly sortOrder: number;
  /** Advisory only — the app recommends, it never blocks. */
  readonly requires: readonly string[];
  readonly names: {
    readonly pl: { readonly name: string; readonly description: string };
    readonly en: { readonly name: string; readonly description: string };
  };
  readonly steps: readonly StepSeed[];
}

/** An exercise plus the illustration that represents it. */
export interface CatalogueEntry extends ExerciseSeed {
  readonly pose: Pose;
  /**
   * Four or five words for the list card. The full description is written for
   * the exercise screen, where there is room to read; a card is scanned, not
   * read, and a paragraph on it reads as noise.
   */
  readonly tagline: { readonly pl: string; readonly en: string };
  /** What to have to hand before starting. Shown as icons on the exercise screen. */
  readonly gear: readonly GearId[];
}

/** What makes a rung hard, independent of where it is. */
export type DistractionKind =
  | 'none'
  | 'household'
  | 'handler'
  | 'object_still'
  | 'object_moving'
  | 'outdoor_novelty'
  | 'people'
  | 'children'
  | 'food_ground'
  | 'wildlife'
  | 'dogs';

/** One rung of the ladder, with its names per locale. */
export interface EnvironmentSeed {
  readonly id: string;
  readonly difficulty: number;
  readonly distractionKind: DistractionKind;
  readonly sortOrder: number;
  /** Working distance from the trigger, in metres, where that is the variable. */
  readonly thresholdMetres: number | null;
  readonly names: {
    readonly pl: string;
    readonly en: string;
  };
}

/** Everything `environments.json` carries, not just the ladder. */
export interface EnvironmentSet {
  readonly startingEnvironmentId: string;
  readonly beyondPuppyScope: readonly string[];
  readonly categoryOrder: readonly ExerciseCategory[];
  readonly environments: readonly EnvironmentSeed[];
}

/** One stage of a scent game. */
export interface NoseworkLevel {
  readonly ordinal: number;
  /** Suggested length in minutes. Scent work is tiring; short is correct. */
  readonly minutes: number;
  /** What to have ready before the dog is involved. */
  readonly gear: readonly GearId[];
  readonly pl: {
    readonly title: string;
    /** How to set it up before the dog is involved. */
    readonly setup: string;
    /** What you do once the dog is in. */
    readonly how: string;
    /** What success looks like — and what "too hard" looks like. */
    readonly watchFor: string;
  };
  readonly en: NoseworkLevel['pl'];
}

export interface NoseworkActivity {
  readonly id: string;
  readonly pose: Pose;
  readonly sortOrder: number;
  readonly names: {
    readonly pl: { readonly name: string; readonly description: string };
    readonly en: { readonly name: string; readonly description: string };
  };
  readonly tagline: { readonly pl: string; readonly en: string };
  readonly levels: readonly NoseworkLevel[];
}

export interface Mistake {
  readonly pl: { readonly symptom: string; readonly why: string; readonly fix: string };
  readonly en: Mistake['pl'];
}

/**
 * An everyday behaviour problem — barking, fear, jumping — written as an
 * owner finds it: mid-chaos, without vocabulary. `avoid` is welfare first:
 * every item names the thing that makes it worse and why, because a bare
 * prohibition gets argued with. `now` is management (what to change today,
 * before any training), `work` is the training itself, and `professional`
 * is the welfare line where this app stops and a vet or behaviourist
 * starts. `practices` links to exercise ids; they are advisory and must
 * always resolve.
 */
export interface BehaviourIssue {
  readonly id: string;
  readonly sortOrder: number;
  readonly names: {
    readonly pl: { readonly name: string; readonly tagline: string };
    readonly en: { readonly name: string; readonly tagline: string };
  };
  readonly recognizes: { readonly pl: string; readonly en: string };
  /**
   * The red-flag stop line: the conditions under which this card's training
   * is the wrong answer and a vet or behaviourist is the right one. Rendered
   * above the training sections, so an owner reading a bite or a panic cannot
   * scroll past it on the way to a protocol.
   */
  readonly urgent: { readonly pl: string; readonly en: string };
  readonly avoid: { readonly pl: readonly string[]; readonly en: readonly string[] };
  readonly now: { readonly pl: readonly string[]; readonly en: readonly string[] };
  readonly work: { readonly pl: readonly string[]; readonly en: readonly string[] };
  readonly professional: { readonly pl: string; readonly en: string };
  readonly practices: readonly string[];
}

export { parseCatalogueEntry, parseExercise } from './schema/exercise';
export { parseEnvironments, parseEnvironmentSet } from './schema/environments';
export { parseMistakes } from './schema/mistakes';
export { parseNoseworkActivity } from './schema/nosework';
export { parseBehaviourIssue } from './schema/behaviour';

export type { StepMotion };
