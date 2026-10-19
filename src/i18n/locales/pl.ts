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
    yourCall: 'Twoja decyzja — nic nie jest zablokowane',
    easierStep: 'Łatwiejszy krok',
    sameAgain: 'Jeszcze raz to samo',
    nextStep: 'Następny krok',
    suggested: 'sugerowane',
    harderPlace: 'Trudniejsze miejsce',
    easierPlace: 'Łatwiejsze miejsce',
    masteredHere: 'Opanowane tutaj',
    fullyMastered: 'Opanowane wszędzie',
    rungs: 'Miejsce {{n}} z {{total}}',
    newPlaceTitle: 'Nowe miejsce — kroki cofnięte celowo',
    newPlaceBody:
      'Dla psa ta sama komenda w nowym otoczeniu to w praktyce nowe zadanie. Wracamy kawałek, żeby odbudować ją tutaj — pójdzie szybciej niż za pierwszym razem.',
    easierPlaceTitle: 'Łatwiejsze miejsce — kroki podniesione',
    easierPlaceBody:
      'W prostszym otoczeniu pies radzi sobie z trudniejszym krokiem. To nie jest cofnięcie się, tylko zdjęcie jednej zmiennej.',
  },
  gear: {
    title: 'Czego potrzebujesz',
    treats: 'Smakołyki',
    lead: 'Smycz',
    longline: 'Długa linka',
    mat: 'Mata lub legowisko',
    towel: 'Ręcznik',
    box: 'Karton i gazety',
    toy: 'Zabawka',
    cups: 'Kilka kubków',
    clippers: 'Obcinaczka do pazurów',
    bowl: 'Miska',
    helper: 'Druga osoba',
    door: 'Drzwi',
    grass: 'Trawa',
    nothing: 'Nic poza psem',
  },
  nosework: {
    title: 'Praca nosem',
    subtitle: 'Bez oceniania — pies rozwiązuje to sam',
    level: 'Poziom {{n}} z {{total}}',
    setup: 'Przygotowanie',
    how: 'Jak to zrobić',
    watchFor: 'Na co patrzeć',
    minutes: '{{n}} min',
    done: 'Zrobione',
    notScored:
      'Tu nie ma trafień i pudeł. Węszenie nagradza się samo, a ocenianie go kusi, żeby psu pomagać — a cała wartość jest w tym, że rozwiązuje to sam.',
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
