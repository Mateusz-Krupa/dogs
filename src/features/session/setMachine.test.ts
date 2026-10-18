import {
  SET_SIZE,
  verdictForSet,
  type RepOutcome,
  type Verdict,
} from '../../domain/verdict';
import {
  initialSetState,
  setReducer,
  type SetAction,
  type SetState,
} from './setMachine';

/** Applies a list of outcomes to the reducer in order. */
function recordAll(state: SetState, outcomes: readonly RepOutcome[]): SetState {
  let current = state;
  for (const outcome of outcomes) {
    current = setReducer(current, { type: 'record', outcome });
  }
  return current;
}

/** A full set of SET_SIZE reps with `hits` hits and the rest `miss`. */
function setWithHits(hits: number): RepOutcome[] {
  return [
    ...Array.from({ length: hits }, (): RepOutcome => 'hit'),
    ...Array.from({ length: SET_SIZE - hits }, (): RepOutcome => 'miss'),
  ];
}

/** The state reached after recording `hits` hits followed by misses to fill the set. */
function stateWithHits(hits: number): SetState {
  return recordAll(initialSetState(), setWithHits(hits));
}

describe('initialSetState', () => {
  it('has no reps, no verdict, and is not decided', () => {
    const state = initialSetState();
    expect(state.reps).toEqual([]);
    expect(state.verdict).toBeNull();
    expect(state.decided).toBe(false);
  });
});

describe('setReducer — record', () => {
  it('appends outcomes in order', () => {
    const state = recordAll(initialSetState(), ['hit', 'miss', 'cancelled']);
    expect(state.reps).toEqual(['hit', 'miss', 'cancelled']);
    expect(state.verdict).toBeNull();
  });

  it('reaches push after five hits and is decided', () => {
    const state = recordAll(initialSetState(), [
      'hit',
      'hit',
      'hit',
      'hit',
      'hit',
    ]);
    expect(state.verdict).toBe('push');
    expect(state.decided).toBe(true);
  });

  it('is decided after three misses while the verdict is still null', () => {
    // The combination matters: `decided` tells the UI the outcome can no longer
    // change, yet `verdict` stays null until the set is actually complete.
    const state = recordAll(initialSetState(), ['miss', 'miss', 'miss']);
    expect(state.decided).toBe(true);
    expect(state.verdict).toBeNull();
    expect(state.reps).toHaveLength(3);
  });

  it('ignores a sixth record and returns the same state by identity', () => {
    const complete = stateWithHits(3);
    expect(complete.reps).toHaveLength(SET_SIZE);

    const after = setReducer(complete, { type: 'record', outcome: 'hit' });
    expect(after).toBe(complete);
    expect(after.reps).toHaveLength(SET_SIZE);
  });
});

describe('setReducer — undo', () => {
  it('removes exactly the last rep', () => {
    const before = recordAll(initialSetState(), ['hit', 'hit', 'miss']);
    const after = setReducer(before, { type: 'undo' });
    expect(after.reps).toEqual(['hit', 'hit']);
  });

  it('recomputes the verdict so a complete set becomes undecided again', () => {
    const complete = stateWithHits(4);
    expect(complete.verdict).toBe('stick');

    const after = setReducer(complete, { type: 'undo' });
    expect(after.verdict).toBeNull();
    expect(after.reps).toHaveLength(SET_SIZE - 1);
  });

  it('is a no-op on an empty set, returning the same state by identity', () => {
    const empty = initialSetState();
    expect(setReducer(empty, { type: 'undo' })).toBe(empty);
  });
});

describe('setReducer — reset', () => {
  it.each([
    ['an empty set', initialSetState],
    ['a set in progress', (): SetState => recordAll(initialSetState(), ['hit', 'miss'])],
    ['a complete set', (): SetState => stateWithHits(5)],
    ['a decided incomplete set', (): SetState =>
      recordAll(initialSetState(), ['miss', 'miss', 'miss'])],
  ])('returns the initial state from %s', (_name, build) => {
    expect(setReducer(build(), { type: 'reset' })).toEqual(initialSetState());
  });
});

describe('setReducer — purity', () => {
  const actions: ReadonlyArray<
    readonly [label: string, action: SetAction]
  > = [
    ['record hit', { type: 'record', outcome: 'hit' }],
    ['record miss', { type: 'record', outcome: 'miss' }],
    ['undo', { type: 'undo' }],
    ['reset', { type: 'reset' }],
  ];

  it.each(actions)('%s never mutates the input reps', (_label, action) => {
    const state = recordAll(initialSetState(), ['hit', 'hit', 'miss', 'miss']);
    const snapshot = [...state.reps];

    setReducer(state, action);

    expect(state.reps).toEqual(snapshot);
    expect(state.reps).toHaveLength(4);
  });
});

describe('setReducer — agreement with the domain rule', () => {
  const hitCounts: ReadonlyArray<number> = [0, 1, 2, 3, 4, 5];

  it.each(hitCounts)(
    'a completed set with %i hit(s) reports the verdict verdictForSet gives',
    (hits) => {
      const expected: Verdict = verdictForSet(setWithHits(hits));
      expect(stateWithHits(hits).verdict).toBe(expected);
    },
  );
});
