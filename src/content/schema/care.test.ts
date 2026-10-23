/**
 * Validation tests for hygiene-care files.
 *
 * Two properties are load-bearing and nothing else is: a routine must carry
 * its safety boundaries in both locales, and it must be impossible to score.
 * These tests guard exactly that — the wording belongs to the welfare review,
 * not to the parser.
 */

import { parseCareRoutine } from '../schema';

function stageFixture(ordinal: number, override: Record<string, unknown> = {}): unknown {
  const copy = {
    title: `Etap ${ordinal}`,
    setup: `Przygotowanie ${ordinal}`,
    how: `Robisz to ${ordinal}`,
    watchFor: `Patrzysz na ${ordinal}`,
    stop: `Stop dla etapu ${ordinal}`,
  };
  return {
    ordinal,
    gear: ['treats', 'mat'],
    pl: copy,
    en: { ...copy, title: `Stage ${ordinal}`, stop: `Stop for stage ${ordinal}` },
    ...override,
  };
}

function routineFixture(override: Record<string, unknown> = {}): unknown {
  return {
    id: 'care-nails',
    pose: 'stand',
    sortOrder: 2,
    names: {
      pl: { name: 'Pielęgnacja pazurów', description: 'Pazury bez siłowania.' },
      en: { name: 'Nail care', description: 'Nails without a fight.' },
    },
    tagline: { pl: 'Łapa sama podana', en: 'A paw offered freely' },
    urgent: {
      pl: 'Ból, krwawienie albo warczenie — stop i weterynarz.',
      en: 'Pain, bleeding or growling — stop and call the vet.',
    },
    professional: {
      pl: 'Bardzo długie pazury planuje weterynarz, nie siła.',
      en: 'Very long nails are a veterinarian plan, not a struggle.',
    },
    practices: ['handling', 'mat'],
    sources: [
      {
        title: 'VCA: Taking the Stress out of Nail Trimming for Dogs',
        url: 'https://vcahospitals.com/know-your-pet/taking-the-stress-out-of-nail-trimming-for-dogs',
      },
    ],
    stages: [stageFixture(1), stageFixture(2), stageFixture(3)],
    ...override,
  };
}

describe('care routines', () => {
  it('accept a well-formed routine', () => {
    expect(() => parseCareRoutine(routineFixture(), 'care-nails.json')).not.toThrow();
    const routine = parseCareRoutine(routineFixture(), 'care-nails.json');
    expect(routine.stages).toHaveLength(3);
    expect(routine.stages[0]?.pl.stop).toContain('Stop');
    expect(routine.sources[0]?.url).toContain('https://');
  });

  it('require the care- id prefix so ids cannot collide with exercises', () => {
    expect(() => parseCareRoutine(routineFixture({ id: 'nails' }), 'care-nails.json')).toThrow(/care-/);
  });

  it('require exactly three stages', () => {
    expect(() =>
      parseCareRoutine(routineFixture({ stages: [stageFixture(1), stageFixture(2)] }), 'x.json'),
    ).toThrow(/exactly 3 stages/);
  });

  it('reject skipped or duplicated stage ordinals', () => {
    expect(() =>
      parseCareRoutine(
        routineFixture({ stages: [stageFixture(1), stageFixture(2), stageFixture(2)] }),
        'x.json',
      ),
    ).toThrow(/must be 3/);
  });

  it('require both safety boundaries in both locales', () => {
    for (const field of ['urgent', 'professional'] as const) {
      expect(() => parseCareRoutine(routineFixture({ [field]: undefined }), 'x.json')).toThrow(field);
      const half = routineFixture({
        [field]: { pl: 'Jest treść.', en: '' },
      });
      expect(() => parseCareRoutine(half, 'x.json')).toThrow(`${field}.en`);
    }
  });

  it('require a stage-level stop line in both locales', () => {
    const missing = routineFixture({
      stages: [
        stageFixture(1),
        stageFixture(2),
        (() => {
          const stage = stageFixture(3) as Record<string, unknown>;
          const copy = { ...(stage.pl as Record<string, unknown>) };
          delete copy.stop;
          return { ...stage, pl: copy };
        })(),
      ],
    });
    expect(() => parseCareRoutine(missing, 'x.json')).toThrow('stages[2].pl.stop');
  });

  it('reject scoring, gating and environment keys structurally', () => {
    for (const key of ['criterion', 'reps', 'target', 'verdict', 'requires', 'environmentId']) {
      expect(() => parseCareRoutine(routineFixture({ [key]: 1 }), 'x.json')).toThrow(
        /participation is never scored/,
      );
    }
    const stageWithCriterion = routineFixture({
      stages: [stageFixture(1), stageFixture(2), { ...(stageFixture(3) as object), criterion: '5/5' }],
    } as Record<string, unknown>);
    expect(() => parseCareRoutine(stageWithCriterion, 'x.json')).toThrow(/participation is never scored/);
  });

  it('require at least one practice link and known gear', () => {
    expect(() => parseCareRoutine(routineFixture({ practices: [] }), 'x.json')).toThrow('practices');
    expect(() =>
      parseCareRoutine(
        routineFixture({ stages: [stageFixture(1), stageFixture(2), stageFixture(3, { gear: ['lamp'] })] }),
        'x.json',
      ),
    ).toThrow('gear');
  });

  describe('source references', () => {
    it('reject a routine with no sources', () => {
      expect(() => parseCareRoutine(routineFixture({ sources: [] }), 'x.json')).toThrow('sources');
      expect(() => parseCareRoutine(routineFixture({ sources: undefined }), 'x.json')).toThrow('sources');
    });

    it('reject more than five sources', () => {
      const many = Array.from({ length: 6 }, (_unused, index) => ({
        title: `Źródło ${index}`,
        url: `https://example.com/${index}`,
      }));
      expect(() => parseCareRoutine(routineFixture({ sources: many }), 'x.json')).toThrow('at most 5');
    });

    it('reject an untrimmed, over-long or line-broken title', () => {
      expect(() =>
        parseCareRoutine(
          routineFixture({ sources: [{ title: '  docięte  ', url: 'https://example.com' }] }),
          'x.json',
        ),
      ).toThrow('single trimmed line');
      expect(() =>
        parseCareRoutine(
          routineFixture({ sources: [{ title: 'a\nb', url: 'https://example.com' }] }),
          'x.json',
        ),
      ).toThrow('single trimmed line');
      expect(() =>
        parseCareRoutine(
          routineFixture({ sources: [{ title: 'x'.repeat(121), url: 'https://example.com' }] }),
          'x.json',
        ),
      ).toThrow('120 characters');
    });

    it('reject http, ftp, non-host, whitespace and credential urls', () => {
      for (const url of [
        'http://example.com',
        'ftp://example.com',
        'example.com/x',
        'https://example.com/a b',
        'https://user@pass.example.com',
        'https://localhost',
      ]) {
        expect(() =>
          parseCareRoutine(routineFixture({ sources: [{ title: 'Źródło', url }] }), 'x.json'),
        ).toThrow(/sources\[0\]\.url/);
      }
    });

    it('reject a duplicated url', () => {
      expect(() =>
        parseCareRoutine(
          routineFixture({
            sources: [
              { title: 'A', url: 'https://example.com/x' },
              { title: 'B', url: 'https://example.com/x' },
            ],
          }),
          'x.json',
        ),
      ).toThrow('must not repeat');
    });

    it('reject extra fields on a source and sources on a stage', () => {
      expect(() =>
        parseCareRoutine(
          routineFixture({ sources: [{ title: 'A', url: 'https://example.com', note: 'x' }] }),
          'x.json',
        ),
      ).toThrow('may only carry title and url');
      const stageWithSources = routineFixture({
        stages: [stageFixture(1), stageFixture(2), { ...(stageFixture(3) as object), sources: [] }],
      } as Record<string, unknown>);
      expect(() => parseCareRoutine(stageWithSources, 'x.json')).toThrow('sources');
    });
  });
});
