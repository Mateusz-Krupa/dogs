/**
 * Validation for one troubleshooting file: `data/mistakes/<exercise-id>.json`.
 *
 * A mistake entry is a diagnosis in three parts, and all three are load-bearing:
 * the symptom is what makes an owner think "that's me", the why is what makes
 * them accept the fix instead of repeating what just failed. An entry missing
 * one of them reads as a bullet point, so the validator requires all three, in
 * both locales.
 */

import type { Mistake } from '../schema';
import { contentError, expectLocales, expectRecord, expectString, fieldPath } from './checks';

function parseEntry(value: unknown, source: string, path: string): Mistake['pl'] {
  const record = expectRecord(value, source, path);
  return {
    symptom: expectString(record.symptom, source, fieldPath(path, 'symptom')),
    why: expectString(record.why, source, fieldPath(path, 'why')),
    fix: expectString(record.fix, source, fieldPath(path, 'fix')),
  };
}

export function parseMistakes(raw: unknown, source: string): Mistake[] {
  if (!Array.isArray(raw)) throw contentError(source, '', 'must be an array of entries');
  if (raw.length === 0) throw contentError(source, '', 'must have at least one entry');
  return raw.map((item, index) =>
    expectLocales(item, source, `[${index}]`, (part, partPath) => parseEntry(part, source, partPath)),
  );
}
