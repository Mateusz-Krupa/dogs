/**
 * Moving along the two axes of progress.
 *
 * The installation axis is the ordered steps inside one exercise. The
 * generalization axis is the ladder of environments. The rule that governs
 * both, and the reason this lives in one place, is: **only one axis moves at a
 * time, and raising one means lowering the other.**
 *
 * So finishing the step ladder does not finish the exercise. It finishes the
 * exercise *here*, and the next move is a harder place with the steps dropped
 * back — because a cue that works in a quiet room is, to the dog, a different
 * behaviour from the same cue in a park.
 */

import { ENVIRONMENTS, type EnvironmentSeed } from '../content/environments';

/** Where a dog is on one exercise: a step, in a place. */
export interface Position {
  readonly stepOrdinal: number;
  readonly environmentId: string;
}

/**
 * How far back to drop when entering a harder environment.
 *
 * Not to the beginning: the early steps of a ladder install the behaviour
 * (luring, fading the lure, adding the hand signal) and that work carries over.
 * What has to be rebuilt is the last stretch — responding to the cue itself
 * while something else is going on. Roughly the final 40% of the ladder.
 */
export function stepAfterEnvironmentChange(stepCount: number): number {
  if (!Number.isSafeInteger(stepCount) || stepCount < 1) {
    throw new RangeError(`stepCount must be a positive integer, got ${stepCount}`);
  }
  return Math.max(1, Math.ceil(stepCount * 0.6));
}

/** The rung after this one, or undefined at the top of the ladder. */
export function nextEnvironment(environmentId: string): EnvironmentSeed | undefined {
  const index = ENVIRONMENTS.findIndex((rung) => rung.id === environmentId);
  if (index === -1) {
    throw new RangeError(`unknown environment: ${environmentId}`);
  }
  return ENVIRONMENTS[index + 1];
}

/** The rung before this one, or undefined at the bottom. */
export function previousEnvironment(environmentId: string): EnvironmentSeed | undefined {
  const index = ENVIRONMENTS.findIndex((rung) => rung.id === environmentId);
  if (index === -1) {
    throw new RangeError(`unknown environment: ${environmentId}`);
  }
  return index === 0 ? undefined : ENVIRONMENTS[index - 1];
}

/** True when the step ladder has been finished in this environment. */
export function isLadderComplete(position: Position, stepCount: number): boolean {
  return position.stepOrdinal >= stepCount;
}

/**
 * True when there is nothing further to climb: the ladder is finished on the
 * hardest rung there is.
 */
export function isFullyGeneralized(position: Position, stepCount: number): boolean {
  return isLadderComplete(position, stepCount) && nextEnvironment(position.environmentId) === undefined;
}

/**
 * Apply a move of `delta` steps, rolling over onto the environment axis at the
 * ends rather than stopping dead.
 *
 * - `+1` past the last step moves to the next environment and drops the step
 *   back, never both forward at once.
 * - `-1` below the first step moves to the previous environment, landing at the
 *   point someone arriving there would have started from.
 * - At the very top and the very bottom the position is simply clamped.
 */
export function move(position: Position, stepCount: number, delta: -1 | 0 | 1): Position {
  if (delta === 0) return position;

  if (delta === 1 && position.stepOrdinal >= stepCount) {
    const harder = nextEnvironment(position.environmentId);
    if (!harder) return position;
    return { stepOrdinal: stepAfterEnvironmentChange(stepCount), environmentId: harder.id };
  }

  if (delta === -1 && position.stepOrdinal <= 1) {
    const easier = previousEnvironment(position.environmentId);
    if (!easier) return position;
    return { stepOrdinal: stepCount, environmentId: easier.id };
  }

  return {
    stepOrdinal: Math.min(stepCount, Math.max(1, position.stepOrdinal + delta)),
    environmentId: position.environmentId,
  };
}

/** How many rungs have been fully climbed, for a progress read-out. */
export function rungsCleared(position: Position, stepCount: number): number {
  const index = ENVIRONMENTS.findIndex((rung) => rung.id === position.environmentId);
  if (index === -1) return 0;
  return isLadderComplete(position, stepCount) ? index + 1 : index;
}
