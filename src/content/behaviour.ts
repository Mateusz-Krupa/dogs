/**
 * The behaviour-problem layer: what to do when the dog's issue is not a cue
 * it cannot do yet but something it does on its own — barking, fear, jumping,
 * destruction.
 *
 * The entries live in `data/behaviour/<id>.json`. Each is a card, not a
 * lesson plan: how to recognise the problem, what makes it worse (said with
 * the reason, because panic does not read fine print), what to change today,
 * how to work on it, and the welfare line where the app stops and a vet or
 * behaviourist takes over. Red-flag cases — aggression with a bite,
 * escalating resource guarding, sudden change suggesting pain, severe
 * separation panic — short-circuit straight to that line, with no DIY fix.
 */

export type { BehaviourIssue } from './schema';
export { BEHAVIOUR, behaviourById } from './load';
