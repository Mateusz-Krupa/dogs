import type { LocaleCatalogue } from './pl';

/**
 * English UI strings. Typed as `LocaleCatalogue`, so TypeScript rejects a key
 * that exists only here or one missing from this file.
 */
export const en: LocaleCatalogue = {
  common: {
    appName: 'pettrainer',
    cancel: 'Cancel',
    back: 'Back',
    next: 'Next',
    done: 'Done',
    retry: 'Try again',
  },
  session: {
    title: 'Training set',
    startSet: 'Start the set',
    hit: 'Got it',
    miss: 'Missed',
    repCounter: 'Rep {{done}} of {{total}}',
    endSet: 'End the set',
    setComplete: 'Set complete',
    criterionLabel: 'What counts as a hit',
  },
  gear: {
    title: 'What you need',
    treats: 'Treats',
    lead: 'Lead',
    longline: 'Long line',
    mat: 'Mat or bed',
    towel: 'A towel',
    box: 'Box and newspaper',
    toy: 'A toy',
    cups: 'A few cups',
    clippers: 'Nail clippers',
    bowl: 'Food bowl',
    helper: 'A second person',
    door: 'A door',
    grass: 'Grass',
    nothing: 'Nothing but the dog',
  },
  nosework: {
    title: 'Nosework',
    subtitle: 'Not scored — the dog solves this alone',
    level: 'Level {{n}} of {{total}}',
    setup: 'Set up',
    how: 'How to do it',
    watchFor: 'What to watch for',
    minutes: '{{n}} min',
    done: 'Done',
    notScored:
      'No hits and misses here. Sniffing pays for itself, and scoring it tempts you to help — and the whole value is that the dog works it out alone.',
  },
  verdict: {
    push: {
      label: 'Push',
      explanation: 'Five out of five. Your dog has this level — make it harder.',
    },
    stick: {
      label: 'Stick',
      explanation: 'Good, but not solid yet. Repeat at the same level.',
    },
    drop: {
      label: 'Drop',
      explanation: 'Too hard. Go back a step — this is a correction, not a failure.',
    },
  },
  today: {
    title: 'Today',
    recommended: 'Recommended exercise',
    chooseAnother: 'Choose another exercise',
    noDogYet: 'Add a dog to start training.',
  },
  dog: {
    name: 'Dog name',
    bornOn: 'Date of birth',
    addDog: 'Add a dog',
  },
  errors: {
    generic: 'Something went wrong. Try again.',
    notFound: 'That item could not be found.',
  },
};
