/**
 * Validation tests for the content loader.
 *
 * Fixtures rather than the real files: a rejection test has to know which field
 * it broke, and it has to be built from something the validator accepts first. The
 * assertions are on the message, because the message is what a person editing JSON
 * gets — a bare `toThrow()` would pass on an error that tells them nothing.
 */

import { parseCatalogueEntry, parseExercise } from './schema';
import { parseEnvironments, parseEnvironmentSet } from './schema/environments';
import { parseMistakes } from './schema/mistakes';
import { parseNoseworkActivity } from './schema/nosework';

// `title` is empty exactly as it is in every shipped exercise file: the key is
// there, the wording is not written yet.
const STEP = {
  title: '',
  instruction: 'Powiedz „siad" raz, poczekaj sekundę i nagródź.',
  criterion: 'Pies siada po samym słowie.',
};

function exerciseFixture(override: Record<string, unknown> = {}): unknown {
  return {
    id: 'sit',
    category: 'foundation',
    sortOrder: 1,
    pose: 'sit',
    requires: [],
    gear: ['treats'],
    names: {
      pl: { name: 'siad', description: 'Pies siada i zostaje.' },
      en: { name: 'sit', description: 'The dog sits and stays.' },
    },
    tagline: { pl: 'Od tego się zaczyna', en: 'Where everyone starts' },
    steps: [{ ordinal: 1, pl: STEP, en: STEP }],
    ...override,
  };
}

function levelFixture(override: Record<string, unknown> = {}): unknown {
  return {
    id: 'scatter',
    pose: 'sniff',
    sortOrder: 1,
    names: {
      pl: { name: 'rozsypka', description: 'Garść karmy w trawie.' },
      en: { name: 'scatter', description: 'Kibble scattered in grass.' },
    },
    tagline: { pl: 'Od tego zaczyna się praca nosem', en: 'Where nosework begins' },
    levels: [
      {
        ordinal: 1,
        minutes: 3,
        gear: ['treats'],
        pl: { title: 'Na dywanie', setup: 'Rozłóż matę.', how: 'Rozrzuć karmę.', watchFor: 'Nos w dół.' },
        en: { title: 'On a rug', setup: 'Lay out a mat.', how: 'Scatter the kibble.', watchFor: 'Nose down.' },
      },
    ],
    ...override,
  };
}

const RUNG = {
  id: 'quiet-room',
  difficulty: 1,
  distractionKind: 'none',
  sortOrder: 1,
  thresholdMetres: null,
  names: { pl: 'Cichy pokój', en: 'Quiet room' },
};

const DIAGNOSIS = { symptom: 'Pies nie siada', why: 'Za wysoka ręka.', fix: 'Obniż dłoń.' };

/** Rejection asserts the message, not just the throw: the message is the UX. */
function expectInvalid(check: () => unknown, source: string, ...fragments: string[]): void {
  let message = '';
  try {
    check();
  } catch (error) {
    expect(error).toBeInstanceOf(TypeError);
    message = (error as TypeError).message;
  }
  expect(message).not.toBe('');
  expect(message).toContain(source);
  for (const fragment of fragments) {
    expect(message).toContain(fragment);
  }
}

describe('the validators', () => {
  it('accept the well-formed fixtures they are tested against', () => {
    expect(() => parseExercise(exerciseFixture(), 'sit.json')).not.toThrow();
    expect(() => parseNoseworkActivity(levelFixture(), 'scatter.json')).not.toThrow();
    expect(() => parseEnvironments([RUNG], 'environments.json')).not.toThrow();
    expect(() => parseMistakes([{ pl: DIAGNOSIS, en: DIAGNOSIS }], 'sit.json')).not.toThrow();
  });

  it('reject a step with no criterion, naming the file and the path', () => {
    const copy = { ...STEP } as Record<string, unknown>;
    delete copy.criterion;
    expectInvalid(
      () => parseExercise(exerciseFixture({ steps: [{ ordinal: 1, pl: copy, en: STEP }] }), 'sit.json'),
      'sit.json',
      'steps[0].pl.criterion',
    );
  });

  it('pass a step’s diagram overrides through to the seed', () => {
    const seed = parseExercise(
      exerciseFixture({
        steps: [{ ordinal: 1, motion: 'return', pose: 'stand', sound: true, pl: STEP, en: STEP }],
      }),
      'sit.json',
    );
    expect(seed.steps[0]).toMatchObject({ motion: 'return', pose: 'stand', sound: true });
  });

  it('leave diagram fields off a step that does not need them', () => {
    const seed = parseExercise(exerciseFixture(), 'sit.json');
    expect(seed.steps[0]).not.toHaveProperty('motion');
    expect(seed.steps[0]).not.toHaveProperty('pose');
    expect(seed.steps[0]).not.toHaveProperty('sound');
  });

  it('reject a diagram motion the drawings cannot render', () => {
    expectInvalid(
      () => parseExercise(
        exerciseFixture({ steps: [{ ordinal: 1, motion: 'backflip', pl: STEP, en: STEP }] }),
        'sit.json',
      ),
      'sit.json',
      'steps[0].motion',
    );
  });

  it('reject a diagram pose no silhouette exists for', () => {
    expectInvalid(
      () => parseExercise(
        exerciseFixture({ steps: [{ ordinal: 1, pose: 'rollover', pl: STEP, en: STEP }] }),
        'sit.json',
      ),
      'sit.json',
      'steps[0].pose',
    );
  });

  it('reject a sound flag that is not true or false', () => {
    expectInvalid(
      () => parseExercise(
        exerciseFixture({ steps: [{ ordinal: 1, sound: 'yes', pl: STEP, en: STEP }] }),
        'sit.json',
      ),
      'sit.json',
      'steps[0].sound',
    );
  });

  it('reject an empty criterion rather than shipping a blank instruction', () => {
    expectInvalid(
      () => parseExercise(exerciseFixture({
        steps: [{ ordinal: 1, pl: { ...STEP, criterion: '   ' }, en: STEP }],
      }), 'sit.json'),
      'sit.json',
      'steps[0].pl.criterion',
      'non-empty',
    );
  });

  it('reject an untranslatable step', () => {
    expectInvalid(
      () => parseExercise(exerciseFixture({ steps: [{ ordinal: 1, pl: STEP }] }), 'sit.json'),
      'sit.json',
      'steps[0].en',
    );
  });

  it('reject a ladder with a hole in it', () => {
    expectInvalid(
      () =>
        parseExercise(
          exerciseFixture({
            steps: [
              { ordinal: 1, pl: STEP, en: STEP },
              { ordinal: 3, pl: STEP, en: STEP },
            ],
          }),
          'sit.json',
        ),
      'sit.json',
      'steps[1].ordinal',
      'must be 2',
    );
  });

  it('reject a category that is not one of the three', () => {
    expectInvalid(
      () => parseExercise(exerciseFixture({ category: 'obedience' }), 'sit.json'),
      'sit.json',
      'category',
      'foundation',
    );
  });

  it('reject prerequisites that are not exercise ids', () => {
    expectInvalid(
      () => parseExercise(exerciseFixture({ requires: [42] }), 'sit.json'),
      'sit.json',
      'requires[0]',
    );
  });

  it('reject gear no icon exists for', () => {
    expectInvalid(
      () => parseCatalogueEntry(exerciseFixture({ gear: ['whistle'] }), 'sit.json'),
      'sit.json',
      'gear[0]',
    );
  });

  it('reject a scent game whose level has no how', () => {
    const broken = levelFixture() as { levels: { en: Record<string, unknown> }[] };
    delete broken.levels[0]!.en.how;
    expectInvalid(() => parseNoseworkActivity(broken, 'scatter.json'), 'scatter.json', 'levels[0].en.how');
  });

  it('reject a ladder whose difficulty goes down as it climbs', () => {
    expectInvalid(
      () =>
        parseEnvironments(
          [
            { ...RUNG, difficulty: 5 },
            { ...RUNG, id: 'own-garden', sortOrder: 2, difficulty: 3 },
          ],
          'environments.json',
        ),
      'environments.json',
      'difficulty',
      'must not be below',
    );
  });

  it("reject a starting rung that is not on the ladder", () => {
    expectInvalid(
      () =>
        parseEnvironmentSet(
          {
            startingEnvironmentId: 'missing-room',
            beyondPuppyScope: [],
            categoryOrder: ['foundation'],
            environments: [RUNG],
          },
          'environments.json',
        ),
      'environments.json',
      'startingEnvironmentId',
      'missing-room',
    );
  });

  it('reject a diagnosis that names a symptom without fixing it', () => {
    const entry = { pl: { symptom: 'Pies nie siada', why: 'Za wysoka ręka.', fix: 'Obniż dłoń.' } };
    expectInvalid(() => parseMistakes([entry], 'sit.json'), 'sit.json', '[0].en');
  });
});
