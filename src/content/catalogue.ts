/**
 * The exercise catalogue.
 *
 * The content lives in `data/exercises/<id>.json`, one file per exercise, and is
 * validated by `schema/exercise.ts`. Polish cue words follow the pet-market
 * register (`leżeć`, not the ZKwP regulation word `waruj`), because this app is
 * for someone raising a family puppy, not preparing for a PT-1 exam. Where the
 * two registers differ the sport word is named in the description, so nobody is
 * surprised at a club.
 *
 * Prerequisites are advisory. They change what the app recommends and what it
 * warns about. They never lock anything.
 */

export type { CatalogueEntry } from './schema';
export { CATALOGUE, exerciseById } from './load';
