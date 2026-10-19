/**
 * Step ladders in the structured form: setup, one repetition, one note.
 *
 * The copy lives in the exercise files under `../data/exercises/`; this module
 * keeps the `STEPS` view the older code uses, keyed by exercise id. The shape is
 * the same everywhere:
 *
 * - **setup** — at most three imperatives, things you arrange before the dog is
 *   involved. Never repeats what the gear row already shows.
 * - **reps** — three or four numbered actions that are *one* repetition, start
 *   to finish. If a step needs more than four, it is really two steps.
 * - **note** — one sentence, and only where there is a real trap. It always
 *   carries the reason, because a bare prohibition is forgotten and a mechanism
 *   is not.
 */

export { STEPS } from '../load';
