/**
 * The distraction ladder — the generalization axis of the app.
 *
 * A rung is not a place. It is a place *times* a kind of distraction, because
 * that is how difficulty actually behaves: a quiet park at dawn and the same
 * park when a loose dog runs past are not the same exercise.
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

import type { ExerciseCategory } from '../db/schema';

/** What makes a rung hard, independent of where it is. */
export type DistractionKind =
  | 'none'
  | 'household'
  | 'handler'
  | 'object_still'
  | 'object_moving'
  | 'outdoor_novelty'
  | 'people'
  | 'children'
  | 'food_ground'
  | 'wildlife'
  | 'dogs';

/** One rung of the ladder, with its names per locale. */
export interface EnvironmentSeed {
  readonly id: string;
  readonly difficulty: number;
  readonly distractionKind: DistractionKind;
  readonly sortOrder: number;
  /** Working distance from the trigger, in metres, where that is the variable. */
  readonly thresholdMetres: number | null;
  readonly names: {
    readonly pl: string;
    readonly en: string;
  };
}

/**
 * The ladder, easiest first. `sortOrder` is contiguous from 1 so the app can
 * step through rungs without sorting by difficulty, which has ties.
 */
export const ENVIRONMENTS: readonly EnvironmentSeed[] = [
  {
    id: 'quiet-room',
    difficulty: 1,
    distractionKind: 'none',
    sortOrder: 1,
    thresholdMetres: null,
    names: {
      pl: 'Cichy pokój, tylko wy dwoje',
      en: 'Quiet room, just the two of you',
    },
  },
  {
    id: 'other-rooms',
    difficulty: 1.5,
    distractionKind: 'none',
    sortOrder: 2,
    thresholdMetres: null,
    names: {
      pl: 'Inne pokoje w domu',
      en: 'Other rooms in the house',
    },
  },
  {
    id: 'home-household-active',
    difficulty: 2,
    distractionKind: 'household',
    sortOrder: 3,
    thresholdMetres: null,
    names: {
      pl: 'Dom, domownicy w ruchu, gra radio',
      en: 'Home with family moving about, radio on',
    },
  },
  {
    id: 'handler-distractions',
    difficulty: 2.5,
    distractionKind: 'handler',
    sortOrder: 4,
    thresholdMetres: null,
    names: {
      pl: 'Rozpraszasz sam: klaśnięcie, podskok, kucnięcie',
      en: 'You are the distraction: clap, hop, crouch',
    },
  },
  {
    id: 'toy-still',
    difficulty: 3,
    distractionKind: 'object_still',
    sortOrder: 5,
    thresholdMetres: 3,
    names: {
      pl: 'Nieruchoma zabawka leży po drugiej stronie pokoju',
      en: 'A still toy lying across the room',
    },
  },
  {
    id: 'doorway',
    difficulty: 3,
    distractionKind: 'household',
    sortOrder: 6,
    thresholdMetres: null,
    names: {
      pl: 'Próg drzwi wejściowych, korytarz',
      en: 'Front doorway, hallway',
    },
  },
  {
    id: 'own-garden-quiet',
    difficulty: 3.5,
    distractionKind: 'outdoor_novelty',
    sortOrder: 7,
    thresholdMetres: null,
    names: {
      pl: 'Własny ogród, spokojnie',
      en: 'Your own garden, quiet',
    },
  },
  {
    id: 'garden-planted-distractions',
    difficulty: 4,
    distractionKind: 'object_still',
    sortOrder: 8,
    thresholdMetres: 3,
    names: {
      pl: 'Ogród z podłożonymi rozproszeniami',
      en: 'Garden with distractions you placed',
    },
  },
  {
    id: 'driveway-street-visible',
    difficulty: 4.5,
    distractionKind: 'outdoor_novelty',
    sortOrder: 9,
    thresholdMetres: null,
    names: {
      pl: 'Podjazd, ulica widoczna z oddali',
      en: 'Driveway, street visible at a distance',
    },
  },
  {
    id: 'quiet-street',
    difficulty: 5,
    distractionKind: 'outdoor_novelty',
    sortOrder: 10,
    thresholdMetres: null,
    names: {
      pl: 'Spokojna ulica osiedlowa poza szczytem',
      en: 'Quiet residential street, off-peak',
    },
  },
  {
    id: 'novel-surfaces',
    difficulty: 5.5,
    distractionKind: 'outdoor_novelty',
    sortOrder: 11,
    thresholdMetres: null,
    names: {
      pl: 'Parking, pusty plac — nowe podłoża i zapachy',
      en: 'Car park or empty yard — new surfaces and smells',
    },
  },
  {
    id: 'park-quiet-hour',
    difficulty: 6,
    distractionKind: 'outdoor_novelty',
    sortOrder: 12,
    thresholdMetres: null,
    names: {
      pl: 'Park wczesnym rankiem, pusto',
      en: 'Park at a quiet hour',
    },
  },
  {
    id: 'people-distant',
    difficulty: 6.5,
    distractionKind: 'people',
    sortOrder: 13,
    thresholdMetres: 30,
    names: {
      pl: 'Ludzie widoczni w oddali, ponad 30 m',
      en: 'People visible over 30 m away',
    },
  },
  {
    id: 'food-on-ground',
    difficulty: 7,
    distractionKind: 'food_ground',
    sortOrder: 14,
    thresholdMetres: 5,
    names: {
      pl: 'Jedzenie na ziemi — okruchy, resztki po pikniku',
      en: 'Food on the ground — crumbs, picnic leftovers',
    },
  },
  {
    id: 'people-passing-fast',
    difficulty: 7.5,
    distractionKind: 'people',
    sortOrder: 15,
    thresholdMetres: 10,
    names: {
      pl: 'Biegacze, rowery, hulajnogi mijają was',
      en: 'Joggers, bikes and scooters passing',
    },
  },
  {
    id: 'children-playing',
    difficulty: 8,
    distractionKind: 'children',
    sortOrder: 16,
    thresholdMetres: 15,
    names: {
      pl: 'Biegające, piszczące dzieci',
      en: 'Children running and squealing',
    },
  },
  {
    id: 'wildlife-still',
    difficulty: 8,
    distractionKind: 'wildlife',
    sortOrder: 17,
    thresholdMetres: 50,
    names: {
      pl: 'Wiewiórki i ptaki w oddali, nieruchome',
      en: 'Squirrels and birds at a distance, still',
    },
  },
  {
    id: 'dogs-distant',
    difficulty: 8.5,
    distractionKind: 'dogs',
    sortOrder: 18,
    thresholdMetres: 20,
    names: {
      pl: 'Inne psy w oddali, spokojne, na smyczy',
      en: 'Other dogs at a distance, calm, on lead',
    },
  },
  {
    id: 'people-greeting',
    difficulty: 8.5,
    distractionKind: 'people',
    sortOrder: 19,
    thresholdMetres: 2,
    names: {
      pl: 'Ktoś podchodzi, żeby pogłaskać psa',
      en: 'Someone approaching to greet your dog',
    },
  },
  {
    id: 'dogs-close',
    difficulty: 9,
    distractionKind: 'dogs',
    sortOrder: 20,
    thresholdMetres: 10,
    names: {
      pl: 'Mijanie innego psa czołowo, blisko',
      en: 'Passing another dog head-on, close',
    },
  },
  {
    id: 'toy-in-motion',
    difficulty: 9,
    distractionKind: 'object_moving',
    sortOrder: 21,
    thresholdMetres: 5,
    names: {
      pl: 'Zabawka w ruchu — rzucona, piszcząca',
      en: 'A toy in motion — thrown, squeaking',
    },
  },
  {
    id: 'dogs-playing',
    difficulty: 9.5,
    distractionKind: 'dogs',
    sortOrder: 22,
    thresholdMetres: 15,
    names: {
      pl: 'Psy w luźnej zabawie obok, płot wybiegu',
      en: 'Dogs playing off-lead nearby, dog-park fence',
    },
  },
  {
    id: 'wildlife-fleeing',
    difficulty: 10,
    distractionKind: 'wildlife',
    sortOrder: 23,
    thresholdMetres: 50,
    names: {
      pl: 'Zwierzę w ucieczce — wiewiórka przez ścieżkę',
      en: 'An animal bolting — a squirrel across the path',
    },
  },
];

/**
 * Rungs a puppy under six months should not be asked to work at yet.
 *
 * They stay in the ladder because they are the destination, and because an
 * owner may well find themselves in one by accident. The app shows them, but
 * does not recommend them for a puppy — consistent with the rule that nothing
 * is ever locked, only advised.
 */
export const BEYOND_PUPPY_SCOPE: readonly string[] = [
  'dogs-close',
  'toy-in-motion',
  'dogs-playing',
  'wildlife-fleeing',
];

/** The rung every exercise starts on. */
export const STARTING_ENVIRONMENT_ID = 'quiet-room';

/**
 * Categories in the order a puppy curriculum introduces them. Advanced work is
 * listed for completeness; it is an adult-dog track.
 */
export const CATEGORY_ORDER: readonly ExerciseCategory[] = [
  'foundation',
  'impulse_control',
  'advanced',
];
