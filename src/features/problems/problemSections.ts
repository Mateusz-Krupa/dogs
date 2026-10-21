/**
 * The section model of a behaviour card, kept out of the component so the
 * welfare ordering is a tested value and not an accident of JSX.
 *
 * `urgent` must lead the actionable sections: the moment an owner's dog has
 * bitten or is panicking, the answer is a professional, and a card that put
 * the training first would hand them a protocol before the stop sign. The
 * recognising paragraph and the closing lines (practice chips, professional
 * box, vet reminder) sit around these blocks in ProblemScreen itself.
 */

import type { BehaviourIssue } from '../../content/behaviour';

export const SECTION_ORDER = ['urgent', 'avoid', 'now', 'work'] as const;

export type SectionKind = (typeof SECTION_ORDER)[number];

/** The body lines of one section, already resolved to the active locale. */
export function sectionLines(
  issue: BehaviourIssue,
  kind: SectionKind,
  locale: 'pl' | 'en',
): readonly string[] {
  if (kind === 'urgent') return [issue.urgent[locale]];
  if (kind === 'avoid') return issue.avoid[locale];
  if (kind === 'now') return issue.now[locale];
  return issue.work[locale];
}

/**
 * How a section is drawn: a warning that interrupts, bullets that steer
 * away from harm, bullets that start help today, numbered training steps.
 */
export function sectionStyle(kind: SectionKind): 'stop' | 'warn' | 'start' | 'steps' {
  if (kind === 'urgent') return 'stop';
  if (kind === 'avoid') return 'warn';
  if (kind === 'now') return 'start';
  return 'steps';
}
