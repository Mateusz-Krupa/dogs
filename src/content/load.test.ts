import type { GearId } from '../ui/Gear';
import {
  BEHAVIOUR,
  CATALOGUE,
  ENVIRONMENTS,
  MISTAKES,
  NOSEWORK,
  SIT,
  STARTING_ENVIRONMENT_ID,
  behaviourById,
  exerciseById,
  practicesProblems,
  mistakesFor,
} from './load';

/**
 * The loader is the only thing standing between a hand-edited JSON file and the
 * screens that render it, so these tests check both directions: the shipped
 * content is well-formed, and a file that is not gets rejected with a message
 * naming the field. The parity counts at the bottom are the ones that catch a
 * record dropped in a reformat — the app still works, it just quietly teaches
 * one step less.
 */

/** Kept exhaustive by the compiler: if `GearId` changes, this stops building. */
const GEAR_UNION: Record<GearId, true> = {
  treats: true,
  lead: true,
  longline: true,
  mat: true,
  towel: true,
  box: true,
  toy: true,
  cups: true,
  clippers: true,
  bowl: true,
  helper: true,
  door: true,
  grass: true,
  nothing: true,
};
const GEAR_IDS = Object.keys(GEAR_UNION);

describe('the exercise catalogue', () => {
  it('names and describes every exercise in both locales', () => {
    for (const entry of CATALOGUE) {
      for (const locale of ['pl', 'en'] as const) {
        expect(entry.names[locale].name.trim().length).toBeGreaterThan(0);
        expect(entry.names[locale].description.trim().length).toBeGreaterThan(0);
        expect(entry.tagline[locale].trim().length).toBeGreaterThan(0);
      }
    }
  });

  it('numbers every ladder contiguously from 1', () => {
    for (const entry of CATALOGUE) {
      const ordinals = entry.steps.map((step) => step.ordinal);
      expect(ordinals).toEqual(Array.from({ length: entry.steps.length }, (_, i) => i + 1));
    }
  });

  it('requires only exercises that exist', () => {
    const ids = new Set(CATALOGUE.map((entry) => entry.id));
    for (const entry of CATALOGUE) {
      for (const required of entry.requires) {
        expect(ids.has(required)).toBe(true);
        expect(required).not.toBe(entry.id);
      }
    }
  });

  it('lists gear the icons can actually draw', () => {
    for (const entry of CATALOGUE) {
      for (const gear of entry.gear) {
        expect(GEAR_IDS).toContain(gear);
      }
    }
    for (const activity of NOSEWORK) {
      for (const level of activity.levels) {
        for (const gear of level.gear) {
          expect(GEAR_IDS).toContain(gear);
        }
      }
    }
  });

  it('writes every step in both locales', () => {
    for (const entry of CATALOGUE) {
      for (const step of entry.steps) {
        for (const locale of ['pl', 'en'] as const) {
          expect(step[locale].instruction.trim().length).toBeGreaterThan(0);
          expect(step[locale].criterion.trim().length).toBeGreaterThan(0);
        }
      }
    }
  });

  it('looks up exercises by id', () => {
    expect(exerciseById('sit')?.id).toBe(SIT.id);
    expect(exerciseById('nope')).toBeUndefined();
  });
});

describe('the troubleshooting entries', () => {
  it('keys every entry to a real exercise', () => {
    const ids = new Set(CATALOGUE.map((entry) => entry.id));
    for (const key of Object.keys(MISTAKES)) {
      expect(ids.has(key)).toBe(true);
    }
  });

  it('answers for every exercise that has entries', () => {
    for (const entry of CATALOGUE) {
      const mistakes = mistakesFor(entry.id);
      expect(mistakes).toEqual(MISTAKES[entry.id] ?? []);
      for (const mistake of mistakes) {
        for (const locale of ['pl', 'en'] as const) {
          expect(mistake[locale].symptom.trim().length).toBeGreaterThan(0);
          expect(mistake[locale].why.trim().length).toBeGreaterThan(0);
          expect(mistake[locale].fix.trim().length).toBeGreaterThan(0);
        }
      }
    }
    expect(mistakesFor('nope')).toEqual([]);
  });
});

describe('the distraction ladder', () => {
  it('steps through contiguous sortOrder without ever getting easier', () => {
    ENVIRONMENTS.forEach((environment, index) => {
      expect(environment.sortOrder).toBe(index + 1);
      const previous = ENVIRONMENTS[index - 1];
      if (previous !== undefined) {
        expect(environment.difficulty).toBeGreaterThanOrEqual(previous.difficulty);
      }
    });
  });

  it('starts on a rung that exists', () => {
    expect(ENVIRONMENTS.some((environment) => environment.id === STARTING_ENVIRONMENT_ID)).toBe(true);
  });
});

describe('content parity with the TypeScript that came before', () => {
  it('ships the same twelve exercises', () => {
    expect(CATALOGUE.length).toBe(12);
    expect(CATALOGUE.map((entry) => entry.id)).toEqual([
      'name',
      'sit',
      'look',
      'down',
      'stay',
      'come',
      'leave',
      'mat',
      'wait',
      'leash',
      'drop',
      'handling',
    ]);
  });

  it('keeps every step of every ladder', () => {
    const stepsPerExercise = Object.fromEntries(CATALOGUE.map((entry) => [entry.id, entry.steps.length]));
    expect(stepsPerExercise).toEqual({
      name: 4,
      sit: 10,
      look: 5,
      down: 7,
      stay: 5,
      come: 4,
      leave: 5,
      mat: 4,
      wait: 4,
      leash: 4,
      drop: 4,
      handling: 5,
    });
  });

  it('keeps the troubleshooting counts per exercise', () => {
    expect(Object.fromEntries(CATALOGUE.map((entry) => [entry.id, mistakesFor(entry.id).length]))).toEqual({
      name: 2,
      sit: 3,
      look: 1,
      down: 3,
      stay: 2,
      come: 3,
      leave: 2,
      mat: 1,
      wait: 1,
      leash: 2,
      drop: 1,
      handling: 2,
    });
  });

  it('keeps six scent games of three levels each', () => {
    expect(NOSEWORK.map((activity) => activity.id)).toEqual([
      'scatter',
      'snuffle',
      'cups',
      'find-toy',
      'find-person',
      'track',
    ]);
    expect(Object.fromEntries(NOSEWORK.map((activity) => [activity.id, activity.levels.length]))).toEqual({
      scatter: 3,
      snuffle: 3,
      cups: 3,
      'find-toy': 3,
      'find-person': 3,
      track: 3,
    });
  });

  it('keeps all twenty-three rungs', () => {
    expect(ENVIRONMENTS.length).toBe(23);
  });
});

describe('behaviour problems', () => {
  it('ships ten cards in browse order', () => {
    expect(BEHAVIOUR.map((issue) => issue.id)).toEqual([
      'bark-door',
      'bark-window',
      'jumping',
      'nipping',
      'stealing',
      'bolting',
      'reactivity',
      'traffic',
      'noise',
      'alone',
    ]);
  });

  it('writes every card in both locales', () => {
    for (const issue of BEHAVIOUR) {
      for (const locale of ['pl', 'en'] as const) {
        expect(issue.names[locale].name.trim().length).toBeGreaterThan(0);
        expect(issue.names[locale].tagline.trim().length).toBeGreaterThan(0);
        expect(issue.recognizes[locale].trim().length).toBeGreaterThan(0);
        expect(issue.urgent[locale].trim().length).toBeGreaterThan(0);
        expect(issue.avoid[locale].length).toBeGreaterThanOrEqual(2);
        expect(issue.now[locale].length).toBeGreaterThanOrEqual(2);
        expect(issue.work[locale].length).toBeGreaterThanOrEqual(2);
        expect(issue.professional[locale].trim().length).toBeGreaterThan(0);
      }
    }
  });

  it('looks each one up by id', () => {
    expect(behaviourById('traffic')?.sortOrder).toBe(8);
    expect(behaviourById('nope')).toBeUndefined();
  });

  it('points every practice link at an exercise that exists', () => {
    for (const issue of BEHAVIOUR) {
      for (const id of issue.practices) expect(exerciseById(id)).toBeDefined();
    }
  });
});

describe('diagram bindings per lesson', () => {
  const byId = (id: string) => exerciseById(id)!;

  it('draws the down-and-toward shape for the steps that pull the dog down', () => {
    expect(byId('down').steps.map((step) => step.motion)).toEqual([
      'down',
      'draw',
      'draw',
      'draw',
      'draw',
      'down',
      'down',
    ]);
  });

  it('pays loose-lead steps at the leg, never out in front', () => {
    const steps = byId('leash').steps;
    expect(steps.map((step) => step.motion)).toEqual(['leg', 'hold', 'leg', 'leg']);
    expect(steps[1]!.pose).toBe('stand');
    expect(steps[3]!.pose).toBe('sniff');
  });

  it('shows the mat under the steps about the mat', () => {
    const steps = byId('mat').steps;
    expect(steps[0]!.motion).toBe('toss');
    expect(steps[0]!.pose).toBe('stand');
    expect(steps[3]!.motion).toBe('toss');
  });

  it('marks the drop steps that say the word with a sound mark', () => {
    const steps = byId('drop').steps;
    expect(steps[2]!.sound).toBe(true);
    expect(steps[3]!.sound).toBe(true);
    expect(steps[0]!.sound).toBeUndefined();
  });

  it('flags a practice link that names no exercise', () => {
    const fake = [{ id: 'x', practices: ['sit', 'ghost'] }] as never;
    expect(practicesProblems(fake, new Set(['sit', 'look']))).toEqual([
      "behaviour/x points at unknown exercise 'ghost'",
    ]);
    expect(practicesProblems(BEHAVIOUR, new Set(CATALOGUE.map((entry) => entry.id)))).toEqual([]);
  });
});
