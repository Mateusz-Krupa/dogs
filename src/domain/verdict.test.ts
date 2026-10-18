import {
  countHits,
  isVerdictDecided,
  nextStepIndex,
  SET_SIZE,
  verdictForSet,
  verdictSoFar,
  type RepOutcome,
  type Verdict,
} from './verdict';

/** Builds a full set of SET_SIZE reps with `hits` hits and the rest `filler`. */
function setWithHits(hits: number, filler: RepOutcome = 'miss'): RepOutcome[] {
  return [
    ...Array.from({ length: hits }, (): RepOutcome => 'hit'),
    ...Array.from({ length: SET_SIZE - hits }, () => filler),
  ];
}

/** The rule table: correct reps out of 5 mapped onto the verdict they produce. */
const VERDICT_TABLE: ReadonlyArray<readonly [hits: number, expected: Verdict]> =
  [
    [5, 'push'],
    [4, 'stick'],
    [3, 'stick'],
    [2, 'drop'],
    [1, 'drop'],
    [0, 'drop'],
  ];

describe('SET_SIZE', () => {
  it('is a set of five repetitions', () => {
    expect(SET_SIZE).toBe(5);
  });
});

describe('countHits', () => {
  it('counts only hits, treating misses and cancellations alike', () => {
    expect(countHits([])).toBe(0);
    expect(countHits(['miss', 'miss', 'miss', 'miss', 'miss'])).toBe(0);
    expect(countHits(['cancelled', 'cancelled', 'cancelled', 'cancelled', 'cancelled'])).toBe(0);
    expect(countHits(['hit', 'hit', 'hit', 'hit', 'hit'])).toBe(5);
    expect(countHits(['hit', 'miss', 'hit', 'cancelled', 'hit'])).toBe(3);
  });
});

describe('verdictForSet', () => {
  it.each(VERDICT_TABLE)(
    'maps a set with %i hit(s) to %s',
    (hits, expected) => {
      expect(verdictForSet(setWithHits(hits))).toBe(expected);
    },
  );

  it('requires a perfect set to push: 4 hits is stick, not push', () => {
    // This is the rule most often got wrong. The widely-copied "push on 4 or 5"
    // variant is an 80% threshold; `stick` is a two-wide band covering 3 and 4.
    const fourHits = setWithHits(4);
    expect(verdictForSet(fourHits)).toBe('stick');
    expect(verdictForSet(fourHits)).not.toBe('push');
    expect(verdictForSet(setWithHits(5))).toBe('push');
  });

  it('counts a cancelled rep as a failure, exactly like a miss', () => {
    const cancelled: RepOutcome[] = ['hit', 'hit', 'hit', 'cancelled', 'cancelled'];
    const missed: RepOutcome[] = ['hit', 'hit', 'hit', 'miss', 'miss'];
    expect(verdictForSet(cancelled)).toBe(verdictForSet(missed));
    expect(countHits(cancelled)).toBe(countHits(missed));
    expect(verdictSoFar(cancelled)).toBe(verdictSoFar(missed));
    expect(isVerdictDecided(cancelled)).toBe(isVerdictDecided(missed));
    expect(verdictForSet(cancelled)).toBe('stick');
  });

  it('does not depend on the order of outcomes within the set', () => {
    const permutations: RepOutcome[][] = [
      ['hit', 'hit', 'hit', 'miss', 'miss'],
      ['miss', 'hit', 'miss', 'hit', 'hit'],
      ['miss', 'miss', 'hit', 'hit', 'hit'],
      ['hit', 'miss', 'hit', 'miss', 'hit'],
      ['miss', 'hit', 'miss', 'miss', 'hit'],
    ];
    const verdicts = permutations.map((permutation) =>
      verdictForSet(permutation),
    );
    expect(verdicts).toEqual(['stick', 'stick', 'stick', 'stick', 'drop']);
  });

  it('throws RangeError for a set that is not exactly five reps', () => {
    expect(() => verdictForSet([])).toThrow(RangeError);
    expect(() => verdictForSet(['hit', 'hit', 'hit'])).toThrow(RangeError);
    expect(() => verdictForSet(['hit', 'hit', 'hit', 'hit'])).toThrow(RangeError);
    expect(() => verdictForSet(setWithHits(5).concat(['hit']))).toThrow(RangeError);
    expect(() => verdictForSet(setWithHits(9))).toThrow(RangeError);
  });

  it('reports the offending length in the message', () => {
    expect(() => verdictForSet(setWithHits(5).concat(['miss']))).toThrow(
      'expected 5 reps, got 6',
    );
  });
});

describe('verdictSoFar', () => {
  it.each([0, 1, 2, 3, 4])('returns null after %i rep(s)', (count) => {
    const partial = Array.from({ length: count }, (): RepOutcome => 'hit');
    expect(verdictSoFar(partial)).toBeNull();
  });

  it('returns null for an empty set', () => {
    expect(verdictSoFar([])).toBeNull();
  });

  it('returns the final verdict at exactly five reps', () => {
    expect(verdictSoFar(setWithHits(5))).toBe('push');
    expect(verdictSoFar(setWithHits(4))).toBe('stick');
    expect(verdictSoFar(setWithHits(3))).toBe('stick');
    expect(verdictSoFar(setWithHits(2))).toBe('drop');
    expect(verdictSoFar(setWithHits(1))).toBe('drop');
    expect(verdictSoFar(setWithHits(0))).toBe('drop');
  });

  it('agrees with verdictForSet once the set is complete', () => {
    for (const [hits, expected] of VERDICT_TABLE) {
      expect(verdictSoFar(setWithHits(hits))).toBe(expected);
      expect(verdictSoFar(setWithHits(hits))).toBe(verdictForSet(setWithHits(hits)));
    }
  });

  it('throws RangeError for more than five reps', () => {
    expect(() => verdictSoFar(setWithHits(5).concat(['hit']))).toThrow(RangeError);
    expect(() => verdictSoFar(setWithHits(8))).toThrow(RangeError);
    expect(() => verdictSoFar(setWithHits(6, 'cancelled'))).toThrow(RangeError);
  });
});

describe('isVerdictDecided', () => {
  it('is false for an empty set', () => {
    expect(isVerdictDecided([])).toBe(false);
  });

  it('is true once three failures have occurred', () => {
    const threeFailures: RepOutcome[] = ['miss', 'miss', 'cancelled'];
    expect(isVerdictDecided(threeFailures)).toBe(true);
    expect(isVerdictDecided(['cancelled', 'hit', 'miss', 'miss'])).toBe(true);
    expect(isVerdictDecided(['miss', 'miss', 'hit', 'hit', 'miss'])).toBe(true);
  });

  it('is true once the set is complete', () => {
    expect(isVerdictDecided(setWithHits(5))).toBe(true);
    expect(isVerdictDecided(setWithHits(3))).toBe(true);
    expect(isVerdictDecided(setWithHits(0))).toBe(true);
  });

  it('is false for a partial set that could still go either way', () => {
    // 3 hits in 3 reps: all-hits ends as push, any miss ends as stick.
    expect(isVerdictDecided(['hit', 'hit', 'hit'])).toBe(false);
    // 2 hits in 3 reps: could still land on stick or drop.
    expect(isVerdictDecided(['hit', 'hit', 'miss'])).toBe(false);
    // 1 hit in 2 reps: drop or stick is still open.
    expect(isVerdictDecided(['hit', 'miss'])).toBe(false);
    // 2 hits in 4 reps: push is out of reach, but stick and drop both remain.
    expect(isVerdictDecided(['hit', 'miss', 'hit', 'miss'])).toBe(false);
  });

  it('throws RangeError for more than five reps', () => {
    expect(() => isVerdictDecided(setWithHits(5).concat(['hit']))).toThrow(
      RangeError,
    );
    expect(() => isVerdictDecided(setWithHits(7))).toThrow(RangeError);
  });
});

describe('nextStepIndex', () => {
  it('moves one step up on push', () => {
    expect(nextStepIndex(2, 5, 'push')).toBe(3);
    expect(nextStepIndex(0, 5, 'push')).toBe(1);
  });

  it('moves one step down on drop', () => {
    expect(nextStepIndex(2, 5, 'drop')).toBe(1);
    expect(nextStepIndex(5, 5, 'drop')).toBe(4);
  });

  it('stays put on stick', () => {
    expect(nextStepIndex(2, 5, 'stick')).toBe(2);
    expect(nextStepIndex(0, 5, 'stick')).toBe(0);
    expect(nextStepIndex(5, 5, 'stick')).toBe(5);
  });

  it('clamps at the top of the ladder instead of throwing', () => {
    expect(nextStepIndex(5, 5, 'push')).toBe(5);
    expect(nextStepIndex(4, 4, 'push')).toBe(4);
    expect(nextStepIndex(0, 0, 'push')).toBe(0);
  });

  it('clamps at the bottom of the ladder instead of throwing', () => {
    expect(nextStepIndex(0, 5, 'drop')).toBe(0);
    expect(nextStepIndex(1, 1, 'drop')).toBe(0);
    expect(nextStepIndex(0, 0, 'drop')).toBe(0);
  });

  it('stays within the ladder for every index, verdict and step', () => {
    for (let maxIndex = 0; maxIndex < SET_SIZE; maxIndex += 1) {
      for (let index = 0; index <= maxIndex; index += 1) {
        for (const verdict of ['push', 'stick', 'drop'] as const) {
          const next = nextStepIndex(index, maxIndex, verdict);
          expect(next).toBeGreaterThanOrEqual(0);
          expect(next).toBeLessThanOrEqual(maxIndex);
        }
      }
    }
  });

  it('throws RangeError when currentIndex is outside [0, maxIndex]', () => {
    expect(() => nextStepIndex(-1, 5, 'push')).toThrow(RangeError);
    expect(() => nextStepIndex(6, 5, 'push')).toThrow(RangeError);
    expect(() => nextStepIndex(1, 0, 'stick')).toThrow(RangeError);
  });

  it('throws RangeError for a negative maxIndex', () => {
    expect(() => nextStepIndex(0, -1, 'push')).toThrow(RangeError);
  });

  it('throws RangeError for arguments that are not safe integers', () => {
    expect(() => nextStepIndex(1.5, 5, 'push')).toThrow(RangeError);
    expect(() => nextStepIndex(1, 4.5, 'push')).toThrow(RangeError);
    expect(() => nextStepIndex(Number.NaN, 5, 'push')).toThrow(RangeError);
    expect(() => nextStepIndex(1, Number.NaN, 'push')).toThrow(RangeError);
    expect(() => nextStepIndex(Number.POSITIVE_INFINITY, 5, 'push')).toThrow(
      RangeError,
    );
    expect(() => nextStepIndex(1, Number.POSITIVE_INFINITY, 'push')).toThrow(
      RangeError,
    );
    expect(() => nextStepIndex(2 ** 53, 2 ** 53, 'stick')).toThrow(RangeError);
  });

  it('reports the offending value in the message', () => {
    expect(() => nextStepIndex(6, 5, 'push')).toThrow(
      'currentIndex must be within [0, 5], got 6',
    );
    expect(() => nextStepIndex(0, -1, 'push')).toThrow(
      'maxIndex must be at least 0, got -1',
    );
    expect(() => nextStepIndex(1, 4.5, 'push')).toThrow(
      'maxIndex must be a safe integer, got 4.5',
    );
  });
});
