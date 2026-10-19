/**
 * The distraction ladder — the generalization axis of the app.
 *
 * The rungs live in `data/environments.json`. A rung is not a place. It is a
 * place *times* a kind of distraction, because that is how difficulty actually
 * behaves: a quiet park at dawn and the same park when a loose dog runs past are
 * not the same exercise.
 *
 * Difficulty is 1–10 and is only ordinal. It exists so the app can tell whether
 * a move is up or down, and by how much. The numbers come from published
 * trainer scales (Pat Miller's kindergarten/college/PhD tiers, Susan Garrett's
 * 0–10 environment scale, Company of Animals' per-trigger threshold distances);
 * no source publishes this exact ladder, so treat the ordering as considered
 * synthesis, not a quoted standard.
 *
 * Two things in here are easy to get wrong and are deliberate:
 *
 * 1. **Toys appear twice.** A still toy on the floor is an easy early
 *    distraction; a toy in motion is near the top of the ladder. The same
 *    arousal that makes a toy a good reward makes a moving toy one of the
 *    hardest things to work around.
 * 2. **Food on the ground ranks high for a different reason than everything
 *    else.** It is self-reinforcing on a single failure: if the puppy gets the
 *    food, ignoring the cue was just paid, handsomely.
 *
 * `thresholdMetres` is the distance at which that trigger is usually workable
 * for a dog that is not yet fluent. Null where distance is not the relevant
 * variable.
 */

export type { DistractionKind, EnvironmentSeed } from './schema';
export {
  BEYOND_PUPPY_SCOPE,
  CATEGORY_ORDER,
  ENVIRONMENTS,
  STARTING_ENVIRONMENT_ID,
} from './load';
