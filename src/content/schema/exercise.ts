/**
 * Validation for one exercise file: `data/exercises/<id>.json`.
 *
 * `parseExercise` checks the teaching content itself and is what the type
 * `ExerciseSeed` describes. `parseCatalogueEntry` adds the three display fields
 * the list and detail screens need — `pose`, `tagline`, `gear` — and is what the
 * loader actually calls, since one file carries both.
 */

import type { CatalogueEntry, ExerciseSeed, StepCopy, StepSeed } from '../schema';
import {
  CATEGORIES,
  MOTION_IDS,
  POSE_IDS,
  contentError,
  expectGearList,
  expectInteger,
  expectLocales,
  expectOneOf,
  expectOptionalBoolean,
  expectOptionalList,
  expectOrdinal,
  expectRecord,
  expectString,
  expectStringList,
  expectUnwritten,
  fieldPath,
} from './checks';

function parseStepCopy(value: unknown, source: string, path: string): StepCopy {
  const record = expectRecord(value, source, path);
  const instruction = expectString(record.instruction, source, fieldPath(path, 'instruction'));
  const criterion = expectString(record.criterion, source, fieldPath(path, 'criterion'));
  const title = expectUnwritten(record.title, source, fieldPath(path, 'title'));
  const setup = expectOptionalList(record.setup, source, fieldPath(path, 'setup'));
  const reps = expectOptionalList(record.reps, source, fieldPath(path, 'reps'));
  const note = record.note === undefined ? undefined : expectString(record.note, source, fieldPath(path, 'note'));

  return {
    instruction,
    criterion,
    ...(setup === undefined ? {} : { setup }),
    ...(reps === undefined ? {} : { reps }),
    ...(note === undefined ? {} : { note }),
    ...(title === undefined ? {} : { title }),
  };
}

function parseStep(value: unknown, source: string, path: string, index: number): StepSeed {
  const record = expectRecord(value, source, path);
  const motion =
    record.motion === undefined
      ? undefined
      : expectOneOf(record.motion, MOTION_IDS, source, fieldPath(path, 'motion'));
  const pose =
    record.pose === undefined
      ? undefined
      : expectOneOf(record.pose, POSE_IDS, source, fieldPath(path, 'pose'));
  const sound = expectOptionalBoolean(record.sound, source, fieldPath(path, 'sound'));
  return {
    ordinal: expectOrdinal(record.ordinal, source, fieldPath(path, 'ordinal'), index),
    ...(motion === undefined ? {} : { motion }),
    ...(pose === undefined ? {} : { pose }),
    ...(sound === undefined ? {} : { sound }),
    pl: parseStepCopy(record.pl, source, fieldPath(path, 'pl')),
    en: parseStepCopy(record.en, source, fieldPath(path, 'en')),
  };
}

function parseSteps(value: unknown, source: string, path: string): readonly StepSeed[] {
  if (!Array.isArray(value)) throw contentError(source, path, 'must be an array of steps');
  if (value.length === 0) throw contentError(source, path, 'must have at least one step');
  return value.map((item, index) => parseStep(item, source, fieldPath(path, index), index));
}

/** Exercise ids this one recommends doing first. Advisory, and always resolvable. */
function parseRequires(value: unknown, source: string, path: string): readonly string[] {
  return expectStringList(value, source, path);
}

export function parseExercise(raw: unknown, source: string): ExerciseSeed {
  const record = expectRecord(raw, source, '');
  return {
    id: expectString(record.id, source, 'id'),
    category: expectOneOf(record.category, CATEGORIES, source, 'category'),
    sortOrder: expectInteger(record.sortOrder, source, 'sortOrder'),
    requires: parseRequires(record.requires, source, 'requires'),
    names: parseCueNames(record.names, source, 'names'),
    steps: parseSteps(record.steps, source, 'steps'),
  };
}

function parseCueNames(
  value: unknown,
  source: string,
  path: string,
): CatalogueEntry['names'] {
  return expectLocales(value, source, path, (part, partPath) => {
    const record = expectRecord(part, source, partPath);
    return {
      name: expectString(record.name, source, fieldPath(partPath, 'name')),
      description: expectString(record.description, source, fieldPath(partPath, 'description')),
    };
  });
}

function parseTagline(value: unknown, source: string, path: string): CatalogueEntry['tagline'] {
  return expectLocales(value, source, path, (part, partPath) => expectString(part, source, partPath));
}

export function parseCatalogueEntry(raw: unknown, source: string): CatalogueEntry {
  const record = expectRecord(raw, source, '');
  return {
    ...parseExercise(record, source),
    pose: expectOneOf(record.pose, POSE_IDS, source, 'pose'),
    tagline: parseTagline(record.tagline, source, 'tagline'),
    gear: expectGearList(record.gear, source, 'gear'),
  };
}
