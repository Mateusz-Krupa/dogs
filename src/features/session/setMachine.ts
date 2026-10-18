/**
 * Pure state machine for a single training set of SET_SIZE repetitions.
 *
 * No React, no I/O. The verdict rules themselves live in `domain/verdict`; this
 * file only sequences reps and re-derives the verdict after every transition.
 */

import {
  isVerdictDecided,
  SET_SIZE,
  verdictSoFar,
  type RepOutcome,
  type Verdict,
} from '../../domain/verdict';

/** A set in progress or just finished. */
export interface SetState {
  readonly reps: readonly RepOutcome[];
  /** Set once the set is complete; null while in progress. */
  readonly verdict: Verdict | null;
  /** True when remaining reps cannot change the outcome. */
  readonly decided: boolean;
}

/** What the owner can do on the set screen. */
export type SetAction =
  | { type: 'record'; outcome: RepOutcome }
  | { type: 'undo' }
  | { type: 'reset' };

/** Builds a state from reps, deriving verdict and decided from them. */
function stateFromReps(reps: readonly RepOutcome[]): SetState {
  return {
    reps,
    verdict: verdictSoFar(reps),
    decided: isVerdictDecided(reps),
  };
}

/** A set with no reps recorded. */
export function initialSetState(): SetState {
  return stateFromReps([]);
}

/**
 * Applies an action. Pure: never mutates its input.
 *
 * - `record` appends an outcome. Ignored (returns the same state) once the set
 *   already holds SET_SIZE reps — the UI must never be able to record a sixth.
 * - `undo` removes the last rep. On an empty set it is a no-op.
 * - `reset` returns to the initial state.
 *
 * `verdict` is recomputed from the reps on every transition, never stored
 * incrementally, so it can never drift from the reps that produced it.
 */
export function setReducer(state: SetState, action: SetAction): SetState {
  switch (action.type) {
    case 'record': {
      if (state.reps.length >= SET_SIZE) {
        return state;
      }
      return stateFromReps([...state.reps, action.outcome]);
    }
    case 'undo': {
      if (state.reps.length === 0) {
        return state;
      }
      return stateFromReps(state.reps.slice(0, -1));
    }
    case 'reset':
      return initialSetState();
  }
}
