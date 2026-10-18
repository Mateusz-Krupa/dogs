/**
 * Push / Drop / Stick verdict rules for a single training set.
 *
 * Pure domain logic: no I/O, no React, no database. The thresholds here are the
 * product's core rule and come from Jean Donaldson's "Push, Drop, Stick" system.
 */

/** Result recorded for one repetition. A cancelled rep counts as a failure. */
export type RepOutcome = 'hit' | 'miss' | 'cancelled';

/** What to do next: make it harder, repeat the level, or make it easier. */
export type Verdict = 'push' | 'stick' | 'drop';

/** A training set is always exactly this many repetitions. */
export const SET_SIZE = 5;

/** Hits needed to advance. Five out of five — four is `stick`, not `push`. */
const PUSH_HITS = 5;

/** Hits needed to stay at the level rather than go back a step. */
const STICK_HITS = 3;

/** Number of reps that count as correct. 'hit' counts; 'miss' and 'cancelled' do not. */
export function countHits(reps: readonly RepOutcome[]): number {
  let hits = 0;
  for (const rep of reps) {
    if (rep === 'hit') {
      hits += 1;
    }
  }
  return hits;
}

/** Maps a number of correct reps onto the verdict band it falls in. */
function verdictFromHits(hits: number): Verdict {
  if (hits >= PUSH_HITS) {
    return 'push';
  }
  if (hits >= STICK_HITS) {
    return 'stick';
  }
  return 'drop';
}

/** Throws when a completed set does not have exactly SET_SIZE reps. */
function assertFullSet(reps: readonly RepOutcome[]): void {
  if (reps.length !== SET_SIZE) {
    throw new RangeError(`expected ${SET_SIZE} reps, got ${reps.length}`);
  }
}

/** Throws when more reps are given than a single set can hold. */
function assertAtMostSetSize(reps: readonly RepOutcome[]): void {
  if (reps.length > SET_SIZE) {
    throw new RangeError(`expected at most ${SET_SIZE} reps, got ${reps.length}`);
  }
}

/**
 * Verdict for a completed set.
 * Throws RangeError if reps.length !== SET_SIZE.
 */
export function verdictForSet(reps: readonly RepOutcome[]): Verdict {
  assertFullSet(reps);
  return verdictFromHits(countHits(reps));
}

/**
 * Verdict for a set that may still be in progress.
 * Returns null when fewer than SET_SIZE reps have been recorded.
 * Throws RangeError if more than SET_SIZE reps are given.
 */
export function verdictSoFar(reps: readonly RepOutcome[]): Verdict | null {
  assertAtMostSetSize(reps);
  if (reps.length < SET_SIZE) {
    return null;
  }
  return verdictFromHits(countHits(reps));
}

/**
 * True once the remaining reps cannot change the verdict, so the UI may offer
 * to end the set early. Throws RangeError if more than SET_SIZE reps are given.
 */
export function isVerdictDecided(reps: readonly RepOutcome[]): boolean {
  assertAtMostSetSize(reps);
  const hits = countHits(reps);
  const remaining = SET_SIZE - reps.length;
  // Verdicts are monotonic in the hit count, so the outcome is decided exactly
  // when the worst-case and best-case final scores land in the same band.
  return verdictFromHits(hits) === verdictFromHits(hits + remaining);
}

/**
 * Apply a verdict to a position on a ladder of difficulty steps. `push` moves
 * +1, `drop` moves -1, `stick` stays. The result is clamped to [0, maxIndex].
 * Throws RangeError if currentIndex is outside [0, maxIndex], if maxIndex < 0,
 * or if either argument is not a safe integer.
 */
export function nextStepIndex(
  currentIndex: number,
  maxIndex: number,
  verdict: Verdict,
): number {
  if (!Number.isSafeInteger(maxIndex)) {
    throw new RangeError(`maxIndex must be a safe integer, got ${maxIndex}`);
  }
  if (maxIndex < 0) {
    throw new RangeError(`maxIndex must be at least 0, got ${maxIndex}`);
  }
  if (!Number.isSafeInteger(currentIndex)) {
    throw new RangeError(
      `currentIndex must be a safe integer, got ${currentIndex}`,
    );
  }
  if (currentIndex < 0 || currentIndex > maxIndex) {
    throw new RangeError(
      `currentIndex must be within [0, ${maxIndex}], got ${currentIndex}`,
    );
  }

  let target: number;
  if (verdict === 'push') {
    target = currentIndex + 1;
  } else if (verdict === 'drop') {
    target = currentIndex - 1;
  } else {
    target = currentIndex;
  }
  return Math.min(maxIndex, Math.max(0, target));
}
