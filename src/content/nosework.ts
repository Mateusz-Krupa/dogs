/**
 * Nosework: scent games, deliberately not scored.
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

import type { Pose } from '../ui/DogPose';

/** One stage of a scent game. */
export interface NoseworkLevel {
  readonly ordinal: number;
  /** Suggested length in minutes. Scent work is tiring; short is correct. */
  readonly minutes: number;
  readonly pl: {
    readonly title: string;
    /** How to set it up before the dog is involved. */
    readonly setup: string;
    /** What you do once the dog is in. */
    readonly how: string;
    /** What success looks like — and what "too hard" looks like. */
    readonly watchFor: string;
  };
  readonly en: {
    readonly title: string;
    readonly setup: string;
    readonly how: string;
    readonly watchFor: string;
  };
}

export interface NoseworkActivity {
  readonly id: string;
  readonly pose: Pose;
  readonly sortOrder: number;
  readonly names: {
    readonly pl: { readonly name: string; readonly description: string };
    readonly en: { readonly name: string; readonly description: string };
  };
  readonly tagline: { readonly pl: string; readonly en: string };
  readonly levels: readonly NoseworkLevel[];
}

const SCATTER: NoseworkActivity = {
  id: 'scatter',
  pose: 'sniff',
  sortOrder: 1,
  names: {
    pl: {
      name: 'rozsypka',
      description:
        'Garść karmy rozrzucona w trawie albo na dywanie. Najprostsza gra węchowa, jaka istnieje, i zarazem ta, od której wszystkie inne się zaczynają. Działa od pierwszego dnia w domu, nie wymaga niczego oprócz jedzenia i nie da się jej zrobić źle.',
    },
    en: {
      name: 'scatter',
      description:
        'A handful of kibble thrown into grass or onto a rug. The simplest scent game there is, and the one every other one grows from. It works from the first day home, needs nothing but food, and cannot really be done wrong.',
    },
  },
  tagline: { pl: 'Od tego zaczyna się praca nosem', en: 'Where nosework begins' },
  levels: [
    {
      ordinal: 1,
      minutes: 3,
      pl: {
        title: 'Na dywanie',
        setup: 'Odlicz garść karmy z dziennej porcji. Wybierz dywan albo matę — na gładkiej podłodze jedzenie się rozjedzie i będzie za łatwo.',
        how: 'Rozrzuć karmę na powierzchni mniej więcej metr na metr, powiedz „szukaj" i odejdź. Nie pokazuj, nie podpowiadaj, nie poprawiaj.',
        watchFor:
          'Pies opuszcza nos i pracuje systematycznie. Jeśli podnosi głowę i patrzy na Ciebie — to prośba o pomoc; odwróć wzrok i daj mu chwilę, zanim uznasz, że za trudne.',
      },
      en: {
        title: 'On a rug',
        setup: 'Count out a handful from the daily ration. Use a rug or a mat — on a smooth floor the food skates away and it is too easy.',
        how: 'Scatter it over roughly a square metre, say “find it”, and step back. Do not point, hint or correct.',
        watchFor:
          'The nose goes down and the dog works methodically. A head lifting to look at you is a request for help — look away and give them a moment before deciding it is too hard.',
      },
    },
    {
      ordinal: 2,
      minutes: 5,
      pl: {
        title: 'W trawie',
        setup: 'Kawałek trawy w ogrodzie albo na spokojnym skwerze, wysokość mniej więcej do kostki.',
        how: 'Ta sama garść, obszar dwa na dwa metry. Trawa chowa zapach i jedzenie, więc trudność rośnie sama.',
        watchFor: 'Dłuższa praca niż na dywanie i wyraźnie wolniejsze tempo. To jest cel, nie problem.',
      },
      en: {
        title: 'In grass',
        setup: 'A patch of garden or a quiet green, roughly ankle-high.',
        how: 'The same handful over two metres square. Grass hides both the scent and the food, so difficulty rises by itself.',
        watchFor: 'Longer work than on the rug and a noticeably slower pace. That is the goal, not a problem.',
      },
    },
    {
      ordinal: 3,
      minutes: 8,
      pl: {
        title: 'Po spacerze, na wyciszenie',
        setup: 'Przygotuj rozsypkę przed wyjściem, żeby po powrocie nie było przerwy.',
        how: 'Wracacie ze spaceru i od razu idzie rozsypka. To zamienia koniec spaceru z pobudzenia w wyciszenie.',
        watchFor: 'Pies po skończeniu kładzie się sam. Jeśli nadal chodzi po domu — skróć spacer, nie wydłużaj rozsypki.',
      },
      en: {
        title: 'After a walk, to wind down',
        setup: 'Set the scatter up before you leave, so there is no gap when you get back.',
        how: 'You come in from the walk and the scatter starts immediately. It turns the end of a walk from arousal into settling.',
        watchFor: 'The dog lies down on their own afterwards. If they are still pacing, shorten the walk rather than lengthening the scatter.',
      },
    },
  ],
};

const SNUFFLE: NoseworkActivity = {
  id: 'snuffle',
  pose: 'sniff',
  sortOrder: 2,
  names: {
    pl: {
      name: 'mata węchowa',
      description:
        'Jedzenie schowane w gęstej tkaninie. Nie musisz jej kupować — zrolowany ręcznik działa tak samo. Dobre na deszczowy dzień i na psa, który nie może jeszcze dużo chodzić.',
    },
    en: {
      name: 'snuffle mat',
      description:
        'Food hidden in thick fabric. You do not need to buy one — a rolled towel works the same. Good for a rainy day and for a dog that cannot yet walk far.',
    },
  },
  tagline: { pl: 'Dziesięć minut i pies śpi', en: 'Ten minutes and they sleep' },
  levels: [
    {
      ordinal: 1,
      minutes: 4,
      pl: {
        title: 'Zrolowany ręcznik',
        setup: 'Rozłóż ręcznik, rozsyp na nim karmę, zroluj luźno.',
        how: 'Postaw przed psem i pozwól rozwiązać. Nie rozwijaj za niego, nawet jeśli długo mu idzie.',
        watchFor: 'Pies rozwija ręcznik nosem i łapami. Frustracja wygląda jak szarpanie i gryzienie — wtedy zroluj luźniej.',
      },
      en: {
        title: 'A rolled towel',
        setup: 'Lay a towel flat, scatter kibble on it, roll it up loosely.',
        how: 'Put it down and let them solve it. Do not unroll it for them, however long it takes.',
        watchFor: 'The dog unrolls it with nose and paws. Frustration looks like tugging and biting — roll it looser next time.',
      },
    },
    {
      ordinal: 2,
      minutes: 6,
      pl: {
        title: 'Ciasno zwinięty',
        setup: 'Ten sam ręcznik, ale zwinięty ciaśniej i zawiązany na luźny węzeł.',
        how: 'Jak wyżej. Trudność rośnie przez opór materiału, nie przez ilość jedzenia.',
        watchFor: 'Dłuższa praca i więcej kombinowania. Pies powinien kończyć zmęczony, nie poirytowany.',
      },
      en: {
        title: 'Rolled tight',
        setup: 'The same towel, rolled tighter and tied in a loose knot.',
        how: 'As above. The difficulty comes from the fabric, not from more food.',
        watchFor: 'Longer work and more problem-solving. They should finish tired, not irritated.',
      },
    },
    {
      ordinal: 3,
      minutes: 8,
      pl: {
        title: 'Pudło z gazetami',
        setup: 'Karton, kilka zgniecionych gazet, karma schowana między nimi.',
        how: 'Postaw i odejdź. Bałagan jest częścią ćwiczenia — posprzątasz potem.',
        watchFor: 'Pies wyciąga gazety i szuka pod spodem. Jeśli od razu je gazety, wróć do ręcznika.',
      },
      en: {
        title: 'A box of newspaper',
        setup: 'A cardboard box, a few crumpled sheets of newspaper, kibble tucked between them.',
        how: 'Put it down and walk away. The mess is part of the exercise — tidy up afterwards.',
        watchFor: 'The dog pulls paper out and searches underneath. If they just eat the paper, go back to the towel.',
      },
    },
  ],
};

const CUPS: NoseworkActivity = {
  id: 'cups',
  pose: 'sniff',
  sortOrder: 3,
  names: {
    pl: {
      name: 'kubki',
      description:
        'Smakołyk pod jednym z kilku kubków. Pierwsza gra, w której pies musi świadomie **wybrać**, a nie tylko znaleźć — i pierwsza, w której zobaczysz, że naprawdę używa nosa, a nie pamięci.',
    },
    en: {
      name: 'the cups',
      description:
        'A treat under one of several cups. The first game where the dog has to **choose** rather than simply find — and the first where you will see them genuinely use their nose rather than their memory.',
    },
  },
  tagline: { pl: 'Pierwszy świadomy wybór', en: 'Their first real choice' },
  levels: [
    {
      ordinal: 1,
      minutes: 3,
      pl: {
        title: 'Dwa kubki, pies patrzy',
        setup: 'Dwa identyczne kubki odwrócone dnem do góry, w odległości pół metra.',
        how: 'Pozwól psu zobaczyć, pod który chowasz smakołyk. Powiedz „szukaj". Gdy trąci właściwy — podnieś i pozwól zjeść.',
        watchFor: 'Pies trąca nosem albo łapą jeden kubek. Trącanie obu po kolei też jest w porządku na tym poziomie.',
      },
      en: {
        title: 'Two cups, dog watching',
        setup: 'Two identical cups upside down, half a metre apart.',
        how: 'Let the dog see which one you hide the treat under. Say “find it”. When they nudge the right one, lift it and let them eat.',
        watchFor: 'A nudge with nose or paw. Checking both in turn is fine at this level.',
      },
    },
    {
      ordinal: 2,
      minutes: 4,
      pl: {
        title: 'Trzy kubki, pies nie patrzy',
        setup: 'Trzy kubki. Pies czeka w drugim pokoju albo za rogiem.',
        how: 'Schowaj smakołyk, przyprowadź psa, powiedz „szukaj". Teraz nos jest jedynym źródłem informacji.',
        watchFor: 'Pies sprawdza kubki po kolei nosem. To moment, w którym widać, że pracuje węchem, a nie zgaduje.',
      },
      en: {
        title: 'Three cups, dog out of the room',
        setup: 'Three cups. The dog waits in another room or round a corner.',
        how: 'Hide the treat, bring the dog in, say “find it”. Now the nose is the only source of information.',
        watchFor: 'The dog checks the cups in turn with their nose. This is where you can see scent working rather than guessing.',
      },
    },
    {
      ordinal: 3,
      minutes: 5,
      pl: {
        title: 'Pięć kubków, przestawione',
        setup: 'Pięć kubków w nieregularnym układzie. Po schowaniu poprzestawiaj kilka z nich.',
        how: 'Przestawianie usuwa resztki pamięci wzrokowej — zostaje czysta praca nosem.',
        watchFor: 'Pies idzie prosto do właściwego kubka, pomijając część pozostałych. To znaczy, że zapach prowadzi.',
      },
      en: {
        title: 'Five cups, shuffled',
        setup: 'Five cups in an irregular layout. After hiding, move a few of them around.',
        how: 'Shuffling removes whatever visual memory was left — what remains is pure scent work.',
        watchFor: 'The dog goes straight to the right cup, skipping some of the others. That means scent is leading.',
      },
    },
  ],
};

const FIND_TOY: NoseworkActivity = {
  id: 'find-toy',
  pose: 'search',
  sortOrder: 4,
  names: {
    pl: {
      name: 'szukaj zabawki',
      description:
        'Pies szuka konkretnego przedmiotu, nie jedzenia. Trudniejsze, bo zabawka pachnie słabiej niż kiełbasa — i ciekawsze, bo buduje prawdziwe poszukiwanie przedmiotu, od którego zaczyna się nosework sportowy.',
    },
    en: {
      name: 'find the toy',
      description:
        'The dog searches for a specific object rather than food. Harder, because a toy smells far weaker than sausage — and more interesting, because it builds the object search that competitive nosework grows from.',
    },
  },
  tagline: { pl: 'Szukanie przedmiotu, nie jedzenia', en: 'An object, not a snack' },
  levels: [
    {
      ordinal: 1,
      minutes: 4,
      pl: {
        title: 'Widoczna, metr dalej',
        setup: 'Weź zabawkę, którą pies lubi i którą często trzyma w pysku — ta jest już nią nasiąknięta.',
        how: 'Połóż ją metr dalej, na widoku. Powiedz „szukaj". Gdy podejdzie — krótka zabawa jako nagroda, nie smakołyk.',
        watchFor: 'Pies idzie do zabawki i bierze ją. Nagrodą jest zabawa, inaczej gra zamienia się w kolejne szukanie karmy.',
      },
      en: {
        title: 'Visible, a metre away',
        setup: 'Use a toy the dog likes and often carries — it is already soaked in their own scent.',
        how: 'Place it a metre away in plain sight. Say “find it”. When they reach it, a short game is the reward, not a treat.',
        watchFor: 'The dog goes and takes it. The reward has to be play, or the game turns into another food search.',
      },
    },
    {
      ordinal: 2,
      minutes: 5,
      pl: {
        title: 'Za zasłoną',
        setup: 'Pies poza pokojem. Schowaj zabawkę za kanapą, pod poduszką, za nogą stołu.',
        how: 'Wprowadź psa i powiedz „szukaj". Nie patrz w stronę kryjówki — psy czytają kierunek Twojego wzroku lepiej, niż myślisz.',
        watchFor: 'Pies systematycznie obwąchuje pokój. Chodzenie w kółko bez opuszczania nosa znaczy, że jest za trudno.',
      },
      en: {
        title: 'Out of sight',
        setup: 'Dog outside the room. Hide the toy behind the sofa, under a cushion, behind a table leg.',
        how: 'Bring the dog in and say “find it”. Do not look at the hiding place — dogs read the direction of your gaze better than you think.',
        watchFor: 'A methodical sweep of the room. Circling with the head up means it is too hard.',
      },
    },
    {
      ordinal: 3,
      minutes: 7,
      pl: {
        title: 'Inny pokój',
        setup: 'Schowaj zabawkę w pomieszczeniu, w którym psa nie było.',
        how: 'Wypuść psa z korytarza i pozwól przeszukać całe mieszkanie.',
        watchFor: 'Pies przechodzi z pokoju do pokoju z nosem przy ziemi. Przerwij, zanim się znudzi — kończ na sukcesie.',
      },
      en: {
        title: 'Another room',
        setup: 'Hide the toy in a room the dog has not been in.',
        how: 'Release them from the hallway and let them search the whole flat.',
        watchFor: 'Room-to-room movement with the nose down. Stop before boredom — end on a find.',
      },
    },
  ],
};

const FIND_PERSON: NoseworkActivity = {
  id: 'find-person',
  pose: 'search',
  sortOrder: 5,
  names: {
    pl: {
      name: 'szukaj mnie',
      description:
        'Chowany z psem. Wygląda jak zabawa i nią jest, ale po cichu buduje najważniejszą rzecz w całym wychowaniu: że szukanie Cię i znajdowanie Cię zawsze się opłaca. To jest fundament przywołania, zbudowany od drugiej strony.',
    },
    en: {
      name: 'find me',
      description:
        'Hide and seek with your dog. It looks like a game and it is one, but it quietly builds the most valuable thing you own: that looking for you and finding you always pays. It is recall, built from the other end.',
    },
  },
  tagline: { pl: 'Przywołanie w przebraniu zabawy', en: 'Recall wearing a disguise' },
  levels: [
    {
      ordinal: 1,
      minutes: 4,
      pl: {
        title: 'Za rogiem',
        setup: 'Potrzebujesz drugiej osoby, która przytrzyma psa, albo psa, który już umie „czekaj".',
        how: 'Schowaj się za framugą, tak żeby pies widział dokąd idziesz. Zawołaj raz. Gdy przybiegnie — duża radość i smakołyk.',
        watchFor: 'Pies biegnie prosto do Ciebie. Reakcja ma być wyraźnie przesadzona, to jest cała nagroda.',
      },
      en: {
        title: 'Round a corner',
        setup: 'You need a second person to hold the dog, or a dog that already knows “wait”.',
        how: 'Hide just behind a doorframe where the dog can see you go. Call once. When they arrive, big celebration and a treat.',
        watchFor: 'A straight run to you. Overdo the welcome — that is the whole reward.',
      },
    },
    {
      ordinal: 2,
      minutes: 5,
      pl: {
        title: 'Inny pokój, bez podglądania',
        setup: 'Pies zostaje, Ty wychodzisz niewidoczny.',
        how: 'Zawołaj raz z drugiego pokoju i zamilknij. Niech pies szuka, nie nawołuj po raz drugi.',
        watchFor: 'Pies szuka po zapachu i dźwięku. Cisza po jednym zawołaniu jest ważna — inaczej uczy się iść za głosem, nie za nosem.',
      },
      en: {
        title: 'Another room, no peeking',
        setup: 'The dog stays; you leave out of sight.',
        how: 'Call once from another room, then go quiet. Let them search — do not call again.',
        watchFor: 'Searching by scent and sound. The silence after one call matters, or they learn to follow your voice rather than their nose.',
      },
    },
    {
      ordinal: 3,
      minutes: 6,
      pl: {
        title: 'W ogrodzie, bez wołania',
        setup: 'Ogrodzony teren. Schowaj się za drzewem albo rogiem budynku.',
        how: 'Nie wołaj wcale. Pozwól psu zorientować się, że zniknąłeś, i znaleźć Cię samodzielnie.',
        watchFor:
          'Pies zauważa Twoją nieobecność i zaczyna szukać. Jeśli panikuje — wyjdź natychmiast; celem jest pewność siebie, nie stres.',
      },
      en: {
        title: 'In the garden, no calling',
        setup: 'A fenced area. Hide behind a tree or the corner of a building.',
        how: 'Do not call at all. Let the dog notice you are gone and find you on their own.',
        watchFor:
          'They notice and start searching. If they panic, step out at once — the point is confidence, not stress.',
      },
    },
  ],
};

const TRACK: NoseworkActivity = {
  id: 'track',
  pose: 'search',
  sortOrder: 6,
  names: {
    pl: {
      name: 'pierwszy ślad',
      description:
        'Pies idzie po śladzie Twoich stóp. Najbardziej zaawansowana rzecz w tej kategorii i jednocześnie najprostsza do zrobienia w ogrodzie. To wstęp do tropienia, które w Polsce jest osobną dyscypliną — ale na tym poziomie to po prostu bardzo dobra zabawa.',
    },
    en: {
      name: 'first track',
      description:
        'The dog follows the trail of your footsteps. The most advanced thing in this category and also the easiest to set up in a garden. It is the start of tracking as a sport — but at this level it is simply a very good game.',
    },
  },
  tagline: { pl: 'Pies idzie Twoim śladem', en: 'Following your footsteps' },
  levels: [
    {
      ordinal: 1,
      minutes: 5,
      pl: {
        title: 'Dziesięć kroków w trawie',
        setup: 'Wilgotna trawa trzyma zapach najlepiej — rano albo po deszczu. Pies czeka przywiązany albo z drugą osobą.',
        how: 'Przejdź dziesięć kroków w linii prostej, przydeptując trawę. Na końcu połóż garść karmy. Wróć **tą samą drogą**. Przyprowadź psa na start i powiedz „szukaj".',
        watchFor: 'Pies idzie z nosem przy ziemi wzdłuż śladu. Jeśli idzie górnym wiatrem na skróty — ślad jest za świeży albo za krótki.',
      },
      en: {
        title: 'Ten paces in grass',
        setup: 'Damp grass holds scent best — early morning or after rain. The dog waits tied or with a second person.',
        how: 'Walk ten paces in a straight line, treading the grass down. Drop a handful of kibble at the end. Return **along the same line**. Bring the dog to the start and say “find it”.',
        watchFor: 'Nose down, following the line. Cutting across on the wind means the track is too fresh or too short.',
      },
    },
    {
      ordinal: 2,
      minutes: 8,
      pl: {
        title: 'Dwadzieścia kroków, odczekane',
        setup: 'Ten sam układ, ale po położeniu śladu odczekaj dziesięć minut.',
        how: 'Starszy ślad jest trudniejszy, bo zapach słabnie i rozwiewa się. Dłuższe odczekanie to główna oś trudności w tropieniu.',
        watchFor: 'Wolniejsza, dokładniejsza praca. Zgubienie śladu i odnalezienie go to sukces, nie porażka.',
      },
      en: {
        title: 'Twenty paces, aged',
        setup: 'The same setup, but wait ten minutes after laying the track.',
        how: 'An older track is harder because the scent fades and drifts. Ageing is the main difficulty axis in tracking.',
        watchFor: 'Slower, more careful work. Losing the line and recovering it is a success, not a failure.',
      },
    },
    {
      ordinal: 3,
      minutes: 10,
      pl: {
        title: 'Ślad z zakrętem',
        setup: 'Trzydzieści kroków z jednym zakrętem pod kątem prostym. Karma w kilku miejscach wzdłuż trasy, nie tylko na końcu.',
        how: 'Zakręt jest realnym wyzwaniem — pies zwykle przestrzeliwuje i musi sam się cofnąć.',
        watchFor:
          'Pies przestrzeliwuje zakręt, zatrzymuje się i wraca. To najlepszy moment w całej kategorii: widać, jak pies myśli.',
      },
      en: {
        title: 'A track with a corner',
        setup: 'Thirty paces with one right-angle turn. Kibble at a few points along the way, not only at the end.',
        how: 'The corner is the real challenge — most dogs overshoot and have to work their way back.',
        watchFor:
          'They overshoot, stop and come back. This is the best moment in the whole category: you can watch the dog think.',
      },
    },
  ],
};

/** Every scent game, easiest first. */
export const NOSEWORK: readonly NoseworkActivity[] = [
  SCATTER,
  SNUFFLE,
  CUPS,
  FIND_TOY,
  FIND_PERSON,
  TRACK,
];

/** Look up one activity by id. */
export function noseworkById(id: string): NoseworkActivity | undefined {
  return NOSEWORK.find((activity) => activity.id === id);
}
