import {
  BEYOND_PUPPY_SCOPE,
  ENVIRONMENTS,
  STARTING_ENVIRONMENT_ID,
  type EnvironmentSeed,
} from './environments';

const byId = new Map<string, EnvironmentSeed>(
  ENVIRONMENTS.map((environment) => [environment.id, environment])
);

describe('the distraction ladder', () => {
  it('has unique ids', () => {
    expect(byId.size).toBe(ENVIRONMENTS.length);
  });

  it('is ordered by a contiguous sortOrder starting at 1', () => {
    const orders = ENVIRONMENTS.map((environment) => environment.sortOrder);
    expect(orders).toEqual(Array.from({ length: ENVIRONMENTS.length }, (_, i) => i + 1));
  });

  it('never gets easier as you climb', () => {
    // Ties are allowed — two rungs can be equally hard for different reasons —
    // but difficulty must never drop as sortOrder rises, or "move up a rung"
    // would sometimes mean "make it easier".
    for (let i = 1; i < ENVIRONMENTS.length; i += 1) {
      const previous = ENVIRONMENTS[i - 1]!;
      const current = ENVIRONMENTS[i]!;
      expect(current.difficulty).toBeGreaterThanOrEqual(previous.difficulty);
    }
  });

  it('keeps every difficulty inside the range the database accepts', () => {
    // The `environment` table has CHECK (difficulty >= 1 AND difficulty <= 10);
    // seeding a row outside that range would fail at migration time.
    for (const environment of ENVIRONMENTS) {
      expect(environment.difficulty).toBeGreaterThanOrEqual(1);
      expect(environment.difficulty).toBeLessThanOrEqual(10);
    }
  });

  it('names every rung in both locales', () => {
    for (const environment of ENVIRONMENTS) {
      expect(environment.names.pl.length).toBeGreaterThan(0);
      expect(environment.names.en.length).toBeGreaterThan(0);
    }
  });

  it('starts somewhere that exists and is the easiest rung', () => {
    const start = byId.get(STARTING_ENVIRONMENT_ID);
    expect(start).toBeDefined();
    expect(start?.sortOrder).toBe(1);
  });

  it('only flags rungs that exist as beyond puppy scope', () => {
    for (const id of BEYOND_PUPPY_SCOPE) {
      expect(byId.has(id)).toBe(true);
    }
  });

  it('puts toys on the ladder twice, still and moving, far apart', () => {
    // The finding this encodes: a still toy is an easy early distraction, while
    // a toy in motion is near the ceiling. Collapsing them into one rung would
    // make the app wrong by about six levels.
    const still = byId.get('toy-still');
    const moving = byId.get('toy-in-motion');
    expect(still).toBeDefined();
    expect(moving).toBeDefined();
    expect(moving!.difficulty - still!.difficulty).toBeGreaterThanOrEqual(5);
    expect(still!.distractionKind).toBe('object_still');
    expect(moving!.distractionKind).toBe('object_moving');
  });

  it('gives a working distance wherever distance is the variable', () => {
    // Dogs, wildlife, food on the ground and people are worked by distance;
    // without a threshold the app cannot tell an owner how far to start.
    const distanceDriven = new Set(['dogs', 'wildlife', 'food_ground', 'people']);
    for (const environment of ENVIRONMENTS) {
      if (distanceDriven.has(environment.distractionKind)) {
        expect(environment.thresholdMetres).not.toBeNull();
        expect(environment.thresholdMetres).toBeGreaterThan(0);
      }
    }
  });

  it('reaches the top of the scale', () => {
    const hardest = ENVIRONMENTS[ENVIRONMENTS.length - 1]!;
    expect(hardest.difficulty).toBe(10);
  });
});
