/**
 * Validation for `data/environments.json` — the distraction ladder.
 *
 * `parseEnvironments` checks the rungs themselves and takes the `environments`
 * array; `parseEnvironmentSet` checks the whole file, including the two ids and
 * the category order that hang around the ladder. Both are exported because the
 * file is one unit while the ladder is reused on its own by the tests.
 */

import type { EnvironmentSeed, EnvironmentSet } from '../schema';
import {
  CATEGORIES,
  DISTRACTION_KINDS,
  contentError,
  expectLocales,
  expectNumber,
  expectOneOf,
  expectOrdinal,
  expectRecord,
  expectString,
  expectStringList,
  fieldPath,
} from './checks';

/** The `environment` table has CHECK (difficulty >= 1 AND difficulty <= 10). */
const MIN_DIFFICULTY = 1;
const MAX_DIFFICULTY = 10;

function parseEnvironment(value: unknown, source: string, index: number): EnvironmentSeed {
  const path = fieldPath('environments', index);
  const record = expectRecord(value, source, path);
  const difficulty = expectNumber(record.difficulty, source, fieldPath(path, 'difficulty'));
  if (difficulty < MIN_DIFFICULTY || difficulty > MAX_DIFFICULTY) {
    throw contentError(
      source,
      fieldPath(path, 'difficulty'),
      `must be between ${MIN_DIFFICULTY} and ${MAX_DIFFICULTY}`,
    );
  }
  const threshold = record.thresholdMetres;
  return {
    id: expectString(record.id, source, fieldPath(path, 'id')),
    difficulty,
    distractionKind: expectOneOf(
      record.distractionKind,
      DISTRACTION_KINDS,
      source,
      fieldPath(path, 'distractionKind'),
    ),
    sortOrder: expectOrdinal(record.sortOrder, source, fieldPath(path, 'sortOrder'), index),
    thresholdMetres: threshold === null ? null : expectNumber(threshold, source, fieldPath(path, 'thresholdMetres')),
    names: expectLocales(record.names, source, fieldPath(path, 'names'), (part, partPath) =>
      expectString(part, source, partPath),
    ),
  };
}

export function parseEnvironments(raw: unknown, source: string): EnvironmentSeed[] {
  if (!Array.isArray(raw)) throw contentError(source, 'environments', 'must be an array of rungs');
  if (raw.length === 0) throw contentError(source, 'environments', 'must have at least one rung');

  const environments = raw.map((item, index) => parseEnvironment(item, source, index));

  const seen = new Set<string>();
  for (const [index, environment] of environments.entries()) {
    // Ids are keys everywhere the ladder is used, so a repeat is never harmless.
    if (seen.has(environment.id)) {
      throw contentError(source, fieldPath('environments', index), `id '${environment.id}' is already used`);
    }
    seen.add(environment.id);

    const previous = environments[index - 1];
    // Ties are allowed; going backwards is not, or "move up a rung" would
    // sometimes mean "make it easier".
    if (previous !== undefined && environment.difficulty < previous.difficulty) {
      throw contentError(
        source,
        `${fieldPath('environments', index)}.difficulty`,
        `must not be below '${previous.id}' at ${previous.difficulty}`,
      );
    }
  }
  return environments;
}

function requireRung(id: string, ids: ReadonlySet<string>, source: string, path: string): void {
  if (!ids.has(id)) throw contentError(source, path, `names '${id}', which is not a rung on the ladder`);
}

export function parseEnvironmentSet(raw: unknown, source: string): EnvironmentSet {
  const record = expectRecord(raw, source, '');
  const environments = parseEnvironments(record.environments, source);
  const ids = new Set(environments.map((environment) => environment.id));

  const startingEnvironmentId = expectString(record.startingEnvironmentId, source, 'startingEnvironmentId');
  requireRung(startingEnvironmentId, ids, source, 'startingEnvironmentId');

  const beyondPuppyScope = expectStringList(record.beyondPuppyScope, source, 'beyondPuppyScope');
  for (const [index, id] of beyondPuppyScope.entries()) {
    requireRung(id, ids, source, fieldPath('beyondPuppyScope', index));
  }

  if (!Array.isArray(record.categoryOrder)) {
    throw contentError(source, 'categoryOrder', 'must be an array of categories');
  }
  return {
    startingEnvironmentId,
    beyondPuppyScope,
    categoryOrder: record.categoryOrder.map((item, index) =>
      expectOneOf(item, CATEGORIES, source, fieldPath('categoryOrder', index)),
    ),
    environments,
  };
}
