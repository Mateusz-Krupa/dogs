/**
 * `siad` / sit — the first exercise.
 *
 * The ladder itself is `data/exercises/sit.json`; the types are in `../schema`.
 * What is worth keeping next to the code is why the ladder looks the way it
 * does, because that is the part a future editor would otherwise undo.
 *
 * ## Where this comes from
 *
 * The *method* is standard force-free practice and is not anyone's property:
 * lure the movement, pay the moment the behaviour happens, fade the lure, add
 * the hand signal, and only then attach a word. The step-by-step progression
 * below is written for this app from several sources rather than copied from
 * any single one:
 *
 * - Push/Drop/Stick, the sets-of-five advancement rule — Jean Donaldson,
 *   *Train Your Dog Like a Pro* (2010). Method only; none of her wording.
 * - "The verbal cue comes late, and always *before* the hand signal, never
 *   during or after" — the same source and standard marker-training practice.
 * - Polish cue vocabulary — ZKwP / PT-1 regulations and Polish puppy-school
 *   curricula (John Dog, Projekt Pies). `siad` is unambiguous across all of them.
 * - Session length and puppy attention spans — AVSAB puppy guidance plus Polish
 *   puppy-school syllabi.
 *
 * ## Why the first steps look like they are not about sitting
 *
 * Steps 1–3 pay the puppy for craning its neck upward, not for sitting. The sit
 * is a side effect of the head going up and back: the rear drops because that is
 * the comfortable way to keep looking up. Paying the neck-crane first builds the
 * movement that produces the sit, which is why a puppy trained this way sits
 * faster than one pushed into position.
 *
 * Never push a puppy's rear down. Pressure on the hips produces resistance and
 * teaches the dog to brace against hands — the opposite of what every later
 * handling exercise needs.
 *
 * ## Why the copy is split into setup / repetition / note
 *
 * One paragraph has to carry four different jobs: what to prepare, what to do,
 * how long to wait, and what not to do. Read once, on a phone, with a puppy
 * already in front of you, the middle of that paragraph is lost. Actions belong
 * in a list; reasons do not — "do not raise your hand too high" is forgettable,
 * "do not raise it too high *because the dog follows their nose and will jump*"
 * is not. So the actions are bullets and the reason is a sentence.
 */

export type { StepCopy, ExerciseSeed, StepSeed } from '../schema';
export { SIT } from '../load';
