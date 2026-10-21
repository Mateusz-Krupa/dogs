/**
 * Hand-written checks shared by the content validators.
 *
 * Deliberately not a validation library: the shapes are a dozen small objects,
 * and what matters is the error message. Every failure names the file and the
 * exact field path, so someone who edits a JSON file and runs the app is told
 * which key to fix instead of being shown a library's internal path syntax.
 */

import type { ExerciseCategory } from '../../db/schema';
import type { GearId } from '../../ui/Gear';
import type { Pose } from '../../ui/DogPose';
import type { DistractionKind } from '../schema';

/** A validation failure: `sit.json: steps[3].pl.criterion must be ...`. */
export function contentError(source: string, path: string, rule: string): TypeError {
  return new TypeError(`${path === '' ? source : `${source}: ${path}`} ${rule}`);
}

/** Path of a child key or a list element, without a leading dot at the root. */
export function fieldPath(parent: string, key: string | number): string {
  if (parent === '') return String(key);
  return typeof key === 'number' ? `${parent}[${key}]` : `${parent}.${key}`;
}

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

export function expectRecord(value: unknown, source: string, path: string): Record<string, unknown> {
  if (!isRecord(value)) throw contentError(source, path, 'must be an object');
  return value;
}

/** Text the owner is meant to read. Blank counts as missing. */
export function expectString(value: unknown, source: string, path: string): string {
  if (typeof value !== 'string') throw contentError(source, path, 'must be a string');
  if (value.trim() === '') throw contentError(source, path, 'must be a non-empty string');
  return value;
}

/**
 * Text a human has not written yet — `title` on a step, present in every file
 * and filled in later. A non-string is still a mistake; an empty string is not.
 * Empty comes back as `undefined` so the app never renders a blank heading.
 */
export function expectUnwritten(
  value: unknown,
  source: string,
  path: string,
): string | undefined {
  if (value === undefined || value === '') return undefined;
  if (typeof value !== 'string') throw contentError(source, path, 'must be a string');
  return value;
}

/** A list of prose lines. Each element must be non-empty; emptiness checked by caller. */
export function expectStringList(value: unknown, source: string, path: string): readonly string[] {
  if (!Array.isArray(value)) throw contentError(source, path, 'must be an array of strings');
  return value.map((item, index) => expectString(item, source, fieldPath(path, index)));
}

/** Optional prose bullets: absent is fine, an empty or blank list is a half-edit. */
export function expectOptionalList(
  value: unknown,
  source: string,
  path: string,
): readonly string[] | undefined {
  if (value === undefined) return undefined;
  const list = expectStringList(value, source, path);
  if (list.length === 0) throw contentError(source, path, 'must list something or be left out');
  return list;
}

export function expectNumber(value: unknown, source: string, path: string): number {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw contentError(source, path, 'must be a number');
  }
  return value;
}

/** Optional flag: absent means “let the defaults decide“, anything else is a typo. */
export function expectOptionalBoolean(
  value: unknown,
  source: string,
  path: string,
): boolean | undefined {
  if (value === undefined) return undefined;
  if (typeof value !== 'boolean') throw contentError(source, path, 'must be true or false');
  return value;
}

export function expectInteger(value: unknown, source: string, path: string): number {
  const parsed = expectNumber(value, source, path);
  if (!Number.isInteger(parsed)) throw contentError(source, path, 'must be a whole number');
  return parsed;
}

export function expectOneOf<T extends string>(
  value: unknown,
  allowed: readonly T[],
  source: string,
  path: string,
): T {
  if (typeof value !== 'string' || !(allowed as readonly string[]).includes(value)) {
    throw contentError(source, path, `must be one of: ${allowed.join(', ')}`);
  }
  return value as T;
}

/**
 * A `{ pl, en }` pair. Both locales are required everywhere, so a record that
 * is only half translated fails at load rather than showing one language to a
 * Polish owner.
 */
export function expectLocales<T>(
  value: unknown,
  source: string,
  path: string,
  parse: (part: unknown, partPath: string) => T,
): { readonly pl: T; readonly en: T } {
  const record = expectRecord(value, source, path);
  return {
    pl: parse(record.pl, fieldPath(path, 'pl')),
    en: parse(record.en, fieldPath(path, 'en')),
  };
}

/** The categories, as data. Typed against the union, so it cannot drift silently. */
export const CATEGORIES: readonly ExerciseCategory[] = ['foundation', 'impulse_control', 'advanced'];

/** Distraction kinds, as data. A kind missing here cannot be used by a file. */
export const DISTRACTION_KINDS: readonly DistractionKind[] = [
  'none',
  'household',
  'handler',
  'object_still',
  'object_moving',
  'outdoor_novelty',
  'people',
  'children',
  'food_ground',
  'wildlife',
  'dogs',
];

// The `Record<..., true>` typing is the point: add an icon to the union in
// `ui/Gear` or `ui/DogPose` without adding it here and this stops compiling.
const GEAR_IDS: Record<GearId, true> = {
  treats: true,
  lead: true,
  longline: true,
  mat: true,
  towel: true,
  box: true,
  toy: true,
  cups: true,
  clippers: true,
  bowl: true,
  helper: true,
  door: true,
  grass: true,
  nothing: true,
};

const POSES: Record<Pose, true> = {
  sit: true,
  down: true,
  stand: true,
  stay: true,
  come: true,
  look: true,
  mat: true,
  leave: true,
  sniff: true,
  search: true,
};

export const GEAR_IDS_LIST: readonly GearId[] = Object.keys(GEAR_IDS) as GearId[];
export const POSE_IDS: readonly Pose[] = Object.keys(POSES) as Pose[];

/**
 * The step-diagram vocabulary: what a step's picture draws. Defined from one
 * `as const` list so the type and the validator can never drift apart; the
 * drawings live in `ui/StepDiagram`.
 */
export const MOTION_IDS = [
  'up', // treat above the nose, dog folds into a sit
  'down', // nose to floor, straight in front of the paws
  'draw', // down to the floor and drawn toward the handler
  'hold', // nothing moves; the handler and the dog both stay put
  'away', // the dog travels toward the hand held up in front
  'leg', // the treat arrives low, at the handler's leg
  'refuse', // a forbidden item on the ground, crossed out
  'deny', // the same item offered at muzzle height, crossed out
  'swap', // a better piece at the nose, the held item dropping to the floor
  'contact', // a hand rests on the dog's back
  'touchPaw', // a hand reaches down to a front paw
  'lift', // a paw goes up and comes back down
  'face', // the muzzle is lifted and inspected
  'return', // the handler steps away from the held dog and comes back
  'collar', // a hand closes on the collar and lets go
  'door', // a door, and the gap being opened
  'bowl', // a food bowl lowered, lifted back when the dog moves
  'toss', // a treat tossed in an arc onto the mat
] as const;

export type StepMotion = (typeof MOTION_IDS)[number];

/** Gear ids, checked against the union the icons are actually drawn from. */
export function expectGearList(value: unknown, source: string, path: string): readonly GearId[] {
  const list = expectStringList(value, source, path);
  if (list.length === 0) throw contentError(source, path, 'must list at least one item');
  return list.map((item, index) => expectOneOf(item, GEAR_IDS_LIST, source, fieldPath(path, index)));
}

/** 1-based position on a ladder, checked against the array index it sits at. */
export function expectOrdinal(value: unknown, source: string, path: string, index: number): number {
  const ordinal = expectInteger(value, source, path);
  if (ordinal !== index + 1) {
    throw contentError(source, path, `must be ${index + 1}; ordinals run contiguously from 1`);
  }
  return ordinal;
}
