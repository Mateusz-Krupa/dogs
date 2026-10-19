import { ENVIRONMENTS, STARTING_ENVIRONMENT_ID } from '../content/environments';
import {
  isFullyGeneralized,
  isLadderComplete,
  move,
  nextEnvironment,
  previousEnvironment,
  rungsCleared,
  stepAfterEnvironmentChange,
  type Position,
} from './progression';

const LAST = ENVIRONMENTS[ENVIRONMENTS.length - 1]!;
const SECOND = ENVIRONMENTS[1]!;

describe('stepAfterEnvironmentChange', () => {
  it('drops back without restarting from scratch', () => {
    // The early steps install the behaviour and carry over; only the last
    // stretch has to be rebuilt in a new place.
    expect(stepAfterEnvironmentChange(10)).toBe(6);
    expect(stepAfterEnvironmentChange(7)).toBe(5);
    expect(stepAfterEnvironmentChange(4)).toBe(3);
  });

  it('never returns a step below 1', () => {
    expect(stepAfterEnvironmentChange(1)).toBe(1);
  });

  it('rejects a nonsensical ladder length', () => {
    expect(() => stepAfterEnvironmentChange(0)).toThrow(RangeError);
    expect(() => stepAfterEnvironmentChange(-3)).toThrow(RangeError);
    expect(() => stepAfterEnvironmentChange(2.5)).toThrow(RangeError);
  });
});

describe('environment neighbours', () => {
  it('walks up and down the ladder', () => {
    expect(nextEnvironment(STARTING_ENVIRONMENT_ID)?.id).toBe(SECOND.id);
    expect(previousEnvironment(SECOND.id)?.id).toBe(STARTING_ENVIRONMENT_ID);
  });

  it('has no rung below the first or above the last', () => {
    expect(previousEnvironment(STARTING_ENVIRONMENT_ID)).toBeUndefined();
    expect(nextEnvironment(LAST.id)).toBeUndefined();
  });

  it('throws for an environment that does not exist', () => {
    expect(() => nextEnvironment('nowhere')).toThrow(RangeError);
    expect(() => previousEnvironment('nowhere')).toThrow(RangeError);
  });
});

describe('move', () => {
  const start: Position = { stepOrdinal: 1, environmentId: STARTING_ENVIRONMENT_ID };

  it('steps within the ladder without touching the environment', () => {
    const after = move({ ...start, stepOrdinal: 4 }, 10, 1);
    expect(after).toEqual({ stepOrdinal: 5, environmentId: STARTING_ENVIRONMENT_ID });
  });

  it('rolls over to a harder environment at the top of the ladder', () => {
    // This is the move the whole product exists for: finishing the steps does
    // not finish the exercise, it finishes it *here*.
    const after = move({ stepOrdinal: 10, environmentId: STARTING_ENVIRONMENT_ID }, 10, 1);
    expect(after.environmentId).toBe(SECOND.id);
    expect(after.stepOrdinal).toBe(6);
  });

  it('never advances both axes at once', () => {
    const before = { stepOrdinal: 10, environmentId: STARTING_ENVIRONMENT_ID };
    const after = move(before, 10, 1);
    // The environment went up, so the step must have come down.
    expect(after.environmentId).not.toBe(before.environmentId);
    expect(after.stepOrdinal).toBeLessThan(before.stepOrdinal);
  });

  it('rolls back to the previous environment below the first step', () => {
    const after = move({ stepOrdinal: 1, environmentId: SECOND.id }, 10, -1);
    expect(after).toEqual({ stepOrdinal: 10, environmentId: STARTING_ENVIRONMENT_ID });
  });

  it('clamps at the very bottom and the very top', () => {
    expect(move(start, 10, -1)).toEqual(start);
    const top = { stepOrdinal: 10, environmentId: LAST.id };
    expect(move(top, 10, 1)).toEqual(top);
  });

  it('is a no-op for delta 0', () => {
    const here = { stepOrdinal: 3, environmentId: SECOND.id };
    expect(move(here, 10, 0)).toBe(here);
  });

  it('stays inside the ladder for every step and both directions', () => {
    for (let step = 1; step <= 10; step += 1) {
      for (const delta of [-1, 1] as const) {
        const after = move({ stepOrdinal: step, environmentId: SECOND.id }, 10, delta);
        expect(after.stepOrdinal).toBeGreaterThanOrEqual(1);
        expect(after.stepOrdinal).toBeLessThanOrEqual(10);
        expect(ENVIRONMENTS.some((rung) => rung.id === after.environmentId)).toBe(true);
      }
    }
  });
});

describe('completion', () => {
  it('calls the ladder complete only at the last step', () => {
    expect(isLadderComplete({ stepOrdinal: 9, environmentId: SECOND.id }, 10)).toBe(false);
    expect(isLadderComplete({ stepOrdinal: 10, environmentId: SECOND.id }, 10)).toBe(true);
  });

  it('is only fully generalized on the hardest rung', () => {
    // Finishing the steps in a quiet room is not mastery — it is one rung of it.
    expect(isFullyGeneralized({ stepOrdinal: 10, environmentId: STARTING_ENVIRONMENT_ID }, 10)).toBe(false);
    expect(isFullyGeneralized({ stepOrdinal: 10, environmentId: LAST.id }, 10)).toBe(true);
    expect(isFullyGeneralized({ stepOrdinal: 9, environmentId: LAST.id }, 10)).toBe(false);
  });

  it('counts cleared rungs for a progress read-out', () => {
    expect(rungsCleared({ stepOrdinal: 5, environmentId: STARTING_ENVIRONMENT_ID }, 10)).toBe(0);
    expect(rungsCleared({ stepOrdinal: 10, environmentId: STARTING_ENVIRONMENT_ID }, 10)).toBe(1);
    expect(rungsCleared({ stepOrdinal: 6, environmentId: SECOND.id }, 10)).toBe(1);
    expect(rungsCleared({ stepOrdinal: 10, environmentId: LAST.id }, 10)).toBe(ENVIRONMENTS.length);
  });
});
