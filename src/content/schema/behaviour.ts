/**
 * Validation for one behaviour-problem file: `data/behaviour/<id>.json`.
 *
 * Every section is load-bearing and the validator insists on it: a card
 * without `avoid` sends the owner down the punishment route by default, and
 * a card without `professional` is the app pretending it can fix what it
 * cannot. Both locales must carry the same shape — the UI has no fallback.
 */

import type { BehaviourIssue } from '../schema';
import {
  contentError,
  expectInteger,
  expectLocales,
  expectRecord,
  expectString,
  expectStringList,
  fieldPath,
} from './checks';

/** A plain string carried in both locales. */
function parseText(value: unknown, source: string, path: string): BehaviourIssue['recognizes'] {
  return expectLocales(value, source, path, (part, partPath) =>
    expectString(part, source, partPath),
  );
}

/** Bullet list carried in both locales; an empty list is an unfinished card. */
function parseTextList(
  value: unknown,
  source: string,
  path: string,
): BehaviourIssue['avoid'] {
  return expectLocales(value, source, path, (part, partPath) => {
    const list = expectStringList(part, source, partPath);
    if (list.length === 0) throw contentError(source, partPath, 'must list something');
    return list;
  });
}

export function parseBehaviourIssue(raw: unknown, source: string): BehaviourIssue {
  const record = expectRecord(raw, source, '');
  const names = expectLocales(record.names, source, 'names', (part, partPath) => {
    const entry = expectRecord(part, source, partPath);
    return {
      name: expectString(entry.name, source, fieldPath(partPath, 'name')),
      tagline: expectString(entry.tagline, source, fieldPath(partPath, 'tagline')),
    };
  });
  const practices = expectStringList(record.practices, source, 'practices');
  if (practices.length === 0) throw contentError(source, 'practices', 'must point at at least one exercise');

  return {
    id: expectString(record.id, source, 'id'),
    sortOrder: expectInteger(record.sortOrder, source, 'sortOrder'),
    names,
    recognizes: parseText(record.recognizes, source, 'recognizes'),
    urgent: parseText(record.urgent, source, 'urgent'),
    avoid: parseTextList(record.avoid, source, 'avoid'),
    now: parseTextList(record.now, source, 'now'),
    work: parseTextList(record.work, source, 'work'),
    professional: parseText(record.professional, source, 'professional'),
    practices,
  };
}
