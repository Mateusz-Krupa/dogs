/**
 * The stop line has to lead the card, in this screen and in every future
 * restyle of it. ProblemScreen draws from SECTION_ORDER, so pinning the
 * order and the per-section style here pins the welfare rule itself:
 * recognition first, the red-flag stop before anything actionable, and the
 * numbered training last.
 */

import { behaviourById } from '../../content/behaviour';
import { SECTION_ORDER, sectionLines, sectionStyle } from './problemSections';

describe('problem card section model', () => {
  it('puts the red-flag stop line before every actionable section', () => {
    expect(SECTION_ORDER).toEqual(['urgent', 'avoid', 'now', 'work']);
    expect(SECTION_ORDER[0]).toBe('urgent');
  });

  it('draws urgent as a stop, work as steps, the rest as steering bullets', () => {
    expect(sectionStyle('urgent')).toBe('stop');
    expect(sectionStyle('avoid')).toBe('warn');
    expect(sectionStyle('now')).toBe('start');
    expect(sectionStyle('work')).toBe('steps');
  });

  it('resolves section lines per locale from the shipped content', () => {
    const traffic = behaviourById('traffic');
    expect(traffic).toBeDefined();
    if (!traffic) return;
    expect(sectionLines(traffic, 'urgent', 'pl')[0]).toContain('weterynarz');
    expect(sectionLines(traffic, 'urgent', 'en')[0]).toContain('vet');
    expect(sectionLines(traffic, 'avoid', 'pl').length).toBeGreaterThan(1);
    expect(sectionLines(traffic, 'work', 'en').length).toBeGreaterThan(1);
  });

  it('leads every shipped card with a real stop line', () => {
    const ids = ['bark-door', 'bark-window', 'jumping', 'nipping', 'stealing', 'bolting', 'reactivity', 'traffic', 'noise', 'alone'];
    for (const id of ids) {
      const issue = behaviourById(id);
      expect(issue).toBeDefined();
      if (!issue) continue;
      const pl = sectionLines(issue, 'urgent', 'pl')[0] ?? '';
      const en = sectionLines(issue, 'urgent', 'en')[0] ?? '';
      // A stop line that routes help must name a professional, or it is a
      // comment, not a gate.
      expect(pl + en).toMatch(/behawioryst|weterynarz|behaviourist|vet/i);
    }
  });
});
