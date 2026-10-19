/**
 * Nosework: scent games, deliberately not scored.
 *
 * The games live in `data/nosework/<id>.json`, one file per game.
 *
 * ## Why these have no hit/miss
 *
 * Everywhere else the app counts five repetitions and computes a verdict. Here
 * it does not, and that is a design decision rather than an omission.
 *
 * Sniffing is self-reinforcing — the dog is paid by the act itself, so there is
 * nothing for an owner to judge. Worse, scoring it would invite the owner to
 * help, correct and hurry, and the entire value of nosework is that the dog
 * solves it alone, at their own speed, without being managed. A dog that has
 * just worked out where the food is has done something no cue can teach.
 *
 * So the only thing recorded is: did you do it, and for how long.
 *
 * ## Why it is worth a whole category
 *
 * Fifteen minutes of searching tires a dog more than an hour's walk, and it
 * lowers arousal instead of raising it — the opposite of fetch. For a puppy
 * that cannot yet be walked far, or a dog that comes home from a walk more
 * wound up than when it left, this is the most useful thing in the app.
 *
 * Levels raise difficulty, but the dog decides the pace. A level that is too
 * hard looks like a dog wandering off, not a dog failing.
 */

export type { NoseworkActivity, NoseworkLevel } from './schema';
export { NOSEWORK, noseworkById } from './load';
