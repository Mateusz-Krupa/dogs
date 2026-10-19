/**
 * Which version of the movement a given step is actually practising.
 *
 * The ladder changes what your hand is doing three times: first it holds food
 * the dog follows, then it makes the same shape empty, and finally it does
 * nothing at all while the word carries the cue. Playing the food lure on step
 * nine would contradict the instruction printed directly underneath it.
 */

export type LureStage = 'lure' | 'empty-hand' | 'verbal';

/** Where each exercise stops luring, and where the hand drops out entirely. */
const BOUNDARIES: Readonly<Record<string, { readonly lureUntil: number; readonly handUntil: number }>> = {
  // sit: 1–5 lure with food, 6–7 the same shape with an empty hand, 8–10 the word.
  sit: { lureUntil: 5, handUntil: 7 },
  // down: 1–3 lure, 4 empty hand, 5–7 the word.
  down: { lureUntil: 3, handUntil: 4 },
};

/** The stage for a step, or null when this exercise has no animation. */
export function lureStageFor(exerciseId: string, stepOrdinal: number): LureStage | null {
  const bounds = BOUNDARIES[exerciseId];
  if (!bounds) return null;
  if (stepOrdinal <= bounds.lureUntil) return 'lure';
  if (stepOrdinal <= bounds.handUntil) return 'empty-hand';
  return 'verbal';
}

/** True when this exercise has an animation at all. */
export function hasLureAnimation(exerciseId: string): boolean {
  return exerciseId in BOUNDARIES;
}
