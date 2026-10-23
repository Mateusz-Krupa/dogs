/**
 * Validation for one hygiene routine: `data/care/<care-id>.json`.
 *
 * Two rules carry the whole design. First, a safety boundary is not optional:
 * `urgent` and `professional` must exist in both locales, because a care card
 * that reads as "keep trying" is the failure mode this app cannot ship.
 * Second, nothing here may be scored. These routines deliberately have no
 * criterion, no repetition target and no pass condition — hygiene is trained by
 * participation, and a five-out-of-five rule would turn a dog's "not today"
 * into a failed set. The forbidden keys below make that structural rather than
 * a convention someone can forget.
 */

import type { CareRoutine, CareSource, CareStage } from '../schema';
import {
  POSE_IDS,
  contentError,
  expectGearList,
  expectInteger,
  expectLocales,
  expectOneOf,
  expectOrdinal,
  expectRecord,
  expectString,
  expectStringList,
  fieldPath,
} from './checks';

/** Every routine offers exactly three invitations; no more, no fewer. */
const STAGE_COUNT = 3;

/** `care-` prefix keeps these ids from ever colliding with exercises or games. */
const ID_PREFIX = 'care-';

/** Provenance is capped so a card stays readable and reviewable. */
const MAX_SOURCES = 5;

const MAX_TITLE_LENGTH = 120;

/**
 * Keys that would turn participation into a scored exercise. Rejected at both
 * the routine and the stage level, and named in the error so the intent is
 * legible to whoever hits it.
 */
const FORBIDDEN_KEYS = [
  'criterion',
  'reps',
  'repetitions',
  'target',
  'score',
  'verdict',
  'pass',
  'passed',
  'completed',
  'completion',
  'mastered',
  'requires',
  'prerequisite',
  'prerequisites',
  'unlocked',
  'environment',
  'environmentId',
  'environment_id',
] as const;

/** A plain string carried in both locales. */
function parseText(value: unknown, source: string, path: string): CareRoutine['urgent'] {
  return expectLocales(value, source, path, (part, partPath) =>
    expectString(part, source, partPath),
  );
}

/** Reject keys that would import scored-training semantics into a care file. */
function rejectScoringKeys(record: Record<string, unknown>, source: string, path: string): void {
  for (const key of FORBIDDEN_KEYS) {
    if (Object.prototype.hasOwnProperty.call(record, key)) {
      throw contentError(
        source,
        fieldPath(path, key),
        'is not allowed on a care routine: participation is never scored',
      );
    }
  }
}

function parseSource(value: unknown, source: string, index: number): CareSource {
  const path = fieldPath('sources', index);
  const record = expectRecord(value, source, path);
  const keys = Object.keys(record);
  const unexpected = keys.filter((key) => key !== 'title' && key !== 'url');
  if (unexpected.length > 0) {
    throw contentError(source, path, `may only carry title and url, found ${unexpected.join(', ')}`);
  }
  const title = expectString(record.title, source, fieldPath(path, 'title'));
  if (title.length > MAX_TITLE_LENGTH) {
    throw contentError(source, fieldPath(path, 'title'), `must be at most ${MAX_TITLE_LENGTH} characters`);
  }
  if (title !== title.trim() || /[\r\n]/.test(title)) {
    // A citation label is one line: padding or a line break means the field was
    // pasted out of a page instead of written.
    throw contentError(source, fieldPath(path, 'title'), 'must be a single trimmed line');
  }
  const url = expectString(record.url, source, fieldPath(path, 'url'));
  let parsed: URL | null = null;
  try {
    parsed = new URL(url);
  } catch {
    parsed = null;
  }
  if (parsed === null) {
    throw contentError(source, fieldPath(path, 'url'), 'must be an absolute URL');
  }
  if (parsed.protocol !== 'https:') {
    throw contentError(source, fieldPath(path, 'url'), 'must be an https:// address');
  }
  if (!parsed.hostname.includes('.')) {
    throw contentError(source, fieldPath(path, 'url'), 'must name a host');
  }
  if (parsed.username !== '' || parsed.password !== '') {
    throw contentError(source, fieldPath(path, 'url'), 'must not carry credentials');
  }
  if (/\s/.test(url)) {
    // URL parsing percent-encodes a space rather than failing, so the typo
    // "https://example.com/a b" has to be caught by hand.
    throw contentError(source, fieldPath(path, 'url'), 'must not contain whitespace');
  }
  return { title, url };
}

function parseSources(value: unknown, source: string): readonly CareSource[] {
  if (!Array.isArray(value)) throw contentError(source, 'sources', 'must be an array of sources');
  if (value.length === 0) {
    throw contentError(source, 'sources', 'must cite at least one source');
  }
  if (value.length > MAX_SOURCES) {
    throw contentError(source, 'sources', `must cite at most ${MAX_SOURCES} sources`);
  }
  const sources = value.map((item, index) => parseSource(item, source, index));
  const seen = new Set<string>();
  for (const item of sources) {
    if (seen.has(item.url)) {
      throw contentError(source, 'sources', `must not repeat ${item.url}`);
    }
    seen.add(item.url);
  }
  return sources;
}

function parseStageCopy(value: unknown, source: string, path: string): CareStage['pl'] {
  const record = expectRecord(value, source, path);
  rejectScoringKeys(record, source, path);
  return {
    title: expectString(record.title, source, fieldPath(path, 'title')),
    setup: expectString(record.setup, source, fieldPath(path, 'setup')),
    how: expectString(record.how, source, fieldPath(path, 'how')),
    watchFor: expectString(record.watchFor, source, fieldPath(path, 'watchFor')),
    // The stage-level hazard is required: the routine's own stop-line is above
    // it, but a hazard specific to water, clippers or a muzzle belongs here.
    stop: expectString(record.stop, source, fieldPath(path, 'stop')),
  };
}

const STAGE_KEYS = ['ordinal', 'gear', 'pl', 'en'] as const;

function parseStage(value: unknown, source: string, index: number): CareStage {
  const path = fieldPath('stages', index);
  const record = expectRecord(value, source, path);
  // Name the scoring mistake as the scoring mistake, before the generic
  // unknown-key message, so the error says why the field can never belong here.
  rejectScoringKeys(record, source, path);
  // Provenance belongs to the routine. A stage carrying its own `sources` is a
  // half-finished edit, and an unknown key here is always a typo.
  const unexpected = Object.keys(record).filter((key) => !(STAGE_KEYS as readonly string[]).includes(key));
  if (unexpected.length > 0) {
    throw contentError(
      source,
      path,
      `may only carry ${STAGE_KEYS.join(', ')}, found ${unexpected.join(', ')}`,
    );
  }
  return {
    ordinal: expectOrdinal(record.ordinal, source, fieldPath(path, 'ordinal'), index),
    gear: expectGearList(record.gear, source, fieldPath(path, 'gear')),
    pl: parseStageCopy(record.pl, source, fieldPath(path, 'pl')),
    en: parseStageCopy(record.en, source, fieldPath(path, 'en')),
  };
}

export function parseCareRoutine(raw: unknown, source: string): CareRoutine {
  const record = expectRecord(raw, source, '');
  rejectScoringKeys(record, source, '');

  const id = expectString(record.id, source, 'id');
  if (!id.startsWith(ID_PREFIX)) {
    throw contentError(source, 'id', `must start with "${ID_PREFIX}" so ids cannot collide`);
  }
  if (!Array.isArray(record.stages)) {
    throw contentError(source, 'stages', 'must be an array of stages');
  }
  if (record.stages.length !== STAGE_COUNT) {
    throw contentError(source, 'stages', `must offer exactly ${STAGE_COUNT} stages`);
  }
  const practices = expectStringList(record.practices, source, 'practices');
  if (practices.length === 0) {
    throw contentError(source, 'practices', 'must point at at least one exercise');
  }

  return {
    id,
    pose: expectOneOf(record.pose, POSE_IDS, source, 'pose'),
    sortOrder: expectInteger(record.sortOrder, source, 'sortOrder'),
    names: expectLocales(record.names, source, 'names', (part, partPath) => {
      const names = expectRecord(part, source, partPath);
      return {
        name: expectString(names.name, source, fieldPath(partPath, 'name')),
        description: expectString(names.description, source, fieldPath(partPath, 'description')),
      };
    }),
    tagline: parseText(record.tagline, source, 'tagline'),
    urgent: parseText(record.urgent, source, 'urgent'),
    professional: parseText(record.professional, source, 'professional'),
    practices,
    sources: parseSources(record.sources, source),
    stages: record.stages.map((stage, index) => parseStage(stage, source, index)),
  };
}
