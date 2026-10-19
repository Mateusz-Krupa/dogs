/**
 * Polish UI strings. This is the authoritative catalogue: the English one is
 * typed against `LocaleCatalogue`, so the two can never drift apart silently.
 */
export const pl = {
  common: {
    appName: 'pettrainer',
    cancel: 'Anuluj',
    back: 'Wstecz',
    next: 'Dalej',
    done: 'Gotowe',
    retry: 'Spróbuj ponownie',
  },
  session: {
    title: 'Seria treningowa',
    startSet: 'Rozpocznij serię',
    hit: 'Zaliczone',
    miss: 'Nie zaliczone',
    repCounter: 'Powtórzenie {{done}} z {{total}}',
    endSet: 'Zakończ serię',
    setComplete: 'Seria zakończona',
    criterionLabel: 'Co liczy się jako trafienie',
  },
  verdict: {
    push: {
      label: 'Podnieś poprzeczkę',
      explanation: 'Pięć na pięć. Pies opanował ten poziom — czas na trudniejszy.',
    },
    stick: {
      label: 'Jeszcze jedna seria',
      explanation: 'Dobrze, ale jeszcze nie pewnie. Powtórz na tym samym poziomie.',
    },
    drop: {
      label: 'Ułatw',
      explanation: 'Za trudne. Wróć o krok — to nie porażka, tylko regulacja.',
    },
  },
  today: {
    title: 'Dziś',
    recommended: 'Polecane ćwiczenie',
    chooseAnother: 'Wybierz inne ćwiczenie',
    noDogYet: 'Najpierw dodaj psa, żeby zacząć trening.',
  },
  dog: {
    name: 'Imię psa',
    bornOn: 'Data urodzenia',
    addDog: 'Dodaj psa',
  },
  errors: {
    generic: 'Coś poszło nie tak. Spróbuj ponownie.',
    notFound: 'Nie znaleziono tej pozycji.',
  },
};

/** The shape every locale catalogue must have. */
export type LocaleCatalogue = typeof pl;
