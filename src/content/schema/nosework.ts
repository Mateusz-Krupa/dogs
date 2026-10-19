/**
 * Validation for one scent-game file: `data/nosework/<id>.json`.
 *
 * Scent games carry no verdict fields on purpose — nothing here may grow a
 * `target` or a `score`, because the whole point is that the owner judges
 * nothing. The validator's job is the shape and both locales, not the wording.
 */

import type { NoseworkActivity, NoseworkLevel } from '../schema';
import {
  POSE_IDS,
  contentError,
  expectGearList,
  expectInteger,
  expectLocales,
  expectNumber,
  expectOneOf,
  expectOrdinal,
  expectRecord,
  expectString,
  fieldPath,
} from './checks';

function parseLevelCopy(value: unknown, source: string, path: string): NoseworkLevel['pl'] {
  const record = expectRecord(value, source, path);
  return {
    title: expectString(record.title, source, fieldPath(path, 'title')),
    setup: expectString(record.setup, source, fieldPath(path, 'setup')),
    how: expectString(record.how, source, fieldPath(path, 'how')),
    watchFor: expectString(record.watchFor, source, fieldPath(path, 'watchFor')),
  };
}

function parseLevel(value: unknown, source: string, index: number): NoseworkLevel {
  const path = fieldPath('levels', index);
  const record = expectRecord(value, source, path);
  const minutes = expectNumber(record.minutes, source, fieldPath(path, 'minutes'));
  if (minutes <= 0) throw contentError(source, fieldPath(path, 'minutes'), 'must be more than 0');
  return {
    ordinal: expectOrdinal(record.ordinal, source, fieldPath(path, 'ordinal'), index),
    minutes,
    gear: expectGearList(record.gear, source, fieldPath(path, 'gear')),
    pl: parseLevelCopy(record.pl, source, fieldPath(path, 'pl')),
    en: parseLevelCopy(record.en, source, fieldPath(path, 'en')),
  };
}

export function parseNoseworkActivity(raw: unknown, source: string): NoseworkActivity {
  const record = expectRecord(raw, source, '');
  if (!Array.isArray(record.levels)) {
    throw contentError(source, 'levels', 'must be an array of levels');
  }
  if (record.levels.length === 0) {
    throw contentError(source, 'levels', 'must have at least one level');
  }
  return {
    id: expectString(record.id, source, 'id'),
    pose: expectOneOf(record.pose, POSE_IDS, source, 'pose'),
    sortOrder: expectInteger(record.sortOrder, source, 'sortOrder'),
    names: expectLocales(record.names, source, 'names', (part, partPath) => {
      const names = expectRecord(part, source, partPath);
      return {
        name: expectString(names.name, source, fieldPath(partPath, 'name')),
        description: expectString(names.description, source, fieldPath(partPath, 'description')),
      };
    }),
    tagline: expectLocales(record.tagline, source, 'tagline', (part, partPath) =>
      expectString(part, source, partPath),
    ),
    levels: record.levels.map((level, index) => parseLevel(level, source, index)),
  };
}
