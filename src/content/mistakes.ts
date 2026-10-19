/**
 * The "why isn't this working" layer, per exercise.
 *
 * The entries live in `data/mistakes/<exercise-id>.json`, one file per exercise
 * that has any. Each entry is written the way a trainer actually answers: name
 * the symptom the owner would describe, say what is really going on, then give
 * one concrete change. Not a list of rules — a diagnosis.
 *
 * Grounded in the troubleshooting research (AVSAB, ASPCA, Cornell, Best Friends
 * and certified-trainer sources) plus standard force-free practice. Anything
 * that could be a medical problem says so and sends the owner to a vet, because
 * the app must never talk someone out of a check-up.
 */

export type { Mistake } from './schema';
export { MISTAKES, mistakesFor } from './load';
