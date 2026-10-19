/**
 * Which version of the movement a given step is actually practising.
 *
 * The ladder changes what your hand is doing three times: first it holds food
 * the dog follows, then it makes the same shape empty, and finally it does
 * nothing at all while the word carries the cue. Playing the food lure on step
 * nine would contradict the instruction printed directly underneath it.
 */

export type LureStage = 'lure' | 'empty-hand' | 'verbal';

/**
 * Where each exercise stops luring with food, and where the hand drops out.
 *
 * Exercises missing from this table never fade a lure in the first place —
 * recall, loose lead and handling are food-led the whole way through — so they
 * stay on `lure` and simply show where the food is.
 */
const BOUNDARIES: Readonly<Record<string, { readonly lureUntil: number; readonly handUntil: number }>> = {
  sit: { lureUntil: 5, handUntil: 7 },
  down: { lureUntil: 3, handUntil: 4 },
  look: { lureUntil: 2, handUntil: 3 },
  mat: { lureUntil: 2, handUntil: 3 },
  leave: { lureUntil: 4, handUntil: 4 },
  name: { lureUntil: 0, handUntil: 0 },
  stay: { lureUntil: 0, handUntil: 0 },
  wait: { lureUntil: 0, handUntil: 0 },
};

/** The stage a step is at. Exercises with no fade stay on `lure`. */
export function lureStageFor(exerciseId: string, stepOrdinal: number): LureStage {
  const bounds = BOUNDARIES[exerciseId];
  if (!bounds) return 'lure';
  if (stepOrdinal <= bounds.lureUntil) return 'lure';
  if (stepOrdinal <= bounds.handUntil) return 'empty-hand';
  return 'verbal';
}
