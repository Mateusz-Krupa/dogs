/**
 * The exercise catalogue.
 *
 * Polish cue words follow the pet-market register (`leżeć`, not the ZKwP
 * regulation word `waruj`), because this app is for someone raising a family
 * puppy, not preparing for a PT-1 exam. Where the two registers differ the
 * sport word is named in the description, so nobody is surprised at a club.
 *
 * Prerequisites are advisory. They change what the app recommends and what it
 * warns about. They never lock anything.
 */

import type { Pose } from '../ui/DogPose';
import { SIT, type ExerciseSeed } from './exercises/sit';

/** An exercise plus the illustration that represents it. */
export interface CatalogueEntry extends ExerciseSeed {
  readonly pose: Pose;
}

const LOOK: ExerciseSeed = {
  id: 'look',
  category: 'foundation',
  sortOrder: 2,
  requires: [],
  names: {
    pl: {
      name: 'patrz',
      description:
        'Pies nawiązuje i utrzymuje kontakt wzrokowy na prośbę. Brzmi błaho, a jest najbardziej użyteczną rzeczą na spacerze: pies, który patrzy na Ciebie, nie patrzy na tamtego psa po drugiej stronie ulicy.',
    },
    en: {
      name: 'look at me',
      description:
        'The dog makes and holds eye contact on request. It sounds trivial and it is the most useful thing you own outdoors: a dog looking at you is not looking at the other dog across the road.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Trzymaj smakołyk przy swoim oku. W momencie, w którym pies spojrzy Ci w oczy — chwal i nagródź. Nie mów jeszcze nic.',
        criterion: 'Pies przenosi wzrok ze smakołyka na Twoje oczy.',
      },
      en: {
        instruction:
          'Hold a treat beside your own eye. The instant the dog meets your eyes, praise and pay. Say nothing yet.',
        criterion: 'The dog shifts their gaze from the treat to your eyes.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'To samo, ale czekaj na dwie sekundy kontaktu, zanim nagrodzisz.',
        criterion: 'Dwie sekundy nieprzerwanego kontaktu wzrokowego.',
      },
      en: {
        instruction: 'The same, but wait for two seconds of contact before paying.',
        criterion: 'Two unbroken seconds of eye contact.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction:
          'Schowaj smakołyk do kieszeni. Czekaj, aż pies sam spojrzy Ci w oczy — i wtedy płać. To moment, w którym patrzenie staje się pomysłem psa, nie Twoim.',
        criterion: 'Pies sam nawiązuje kontakt wzrokowy, bez smakołyka w polu widzenia.',
      },
      en: {
        instruction:
          'Put the treat in your pocket. Wait for the dog to offer eye contact on their own, then pay. This is where looking at you becomes the dog’s idea rather than yours.',
        criterion: 'The dog offers eye contact with no treat in sight.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Powiedz „patrz" tuż zanim pies i tak by spojrzał. Słowo wchodzi na gotowe zachowanie.',
        criterion: 'Pies patrzy w ciągu dwóch sekund po słowie.',
      },
      en: {
        instruction:
          'Say “look” just before the dog would have looked anyway. The word attaches to a behaviour that already exists.',
        criterion: 'The dog looks within two seconds of the word.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction: 'Poproś o „patrz", gdy pies jest lekko czymś zajęty — węszy, rozgląda się.',
        criterion: 'Pies odrywa się od tego, co robił, i patrzy.',
      },
      en: {
        instruction: 'Ask for “look” while the dog is mildly busy — sniffing, glancing around.',
        criterion: 'The dog disengages from what they were doing and looks.',
      },
    },
  ],
};

const DOWN: ExerciseSeed = {
  id: 'down',
  category: 'foundation',
  sortOrder: 3,
  requires: ['sit'],
  names: {
    pl: {
      name: 'leżeć',
      description:
        'Pies kładzie się łokciami i klatką na ziemi i zostaje, dopóki go nie zwolnisz. W sporcie i na egzaminach ZKwP ta sama komenda brzmi „waruj" — to ta sama pozycja, inne słowo.',
    },
    en: {
      name: 'down',
      description:
        'Elbows and chest on the ground, held until released. The position a dog can actually hold for a long time, which makes it the one worth having in a café or a waiting room.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Z psem w siadzie poprowadź smakołyk od nosa prosto w dół, do podłogi między jego przednimi łapami. Płać za każde opuszczenie głowy, nawet jeśli nie położy się do końca.',
        criterion: 'Głowa schodzi wyraźnie w dół za smakołykiem.',
      },
      en: {
        instruction:
          'With the dog sitting, draw a treat from their nose straight down to the floor between their front paws. Pay any clear lowering of the head, even without a full down.',
        criterion: 'The head follows the treat clearly downward.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Po dojściu do podłogi poprowadź smakołyk powoli do siebie. Łokcie powinny pójść w dół.',
        criterion: 'Co najmniej jeden łokieć dotyka podłogi.',
      },
      en: {
        instruction: 'Once at the floor, draw the treat slowly toward you. The elbows should follow down.',
        criterion: 'At least one elbow touches the floor.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction:
          'Czekaj na pełne położenie: łokcie i klatka na ziemi. Jeśli pies wstaje, zabierz smakołyk bez słowa i zacznij powtórzenie od nowa.',
        criterion: 'Łokcie i klatka na ziemi.',
      },
      en: {
        instruction:
          'Hold out for the full down: elbows and chest on the ground. If the dog stands up, take the treat away without a word and restart the repetition.',
        criterion: 'Elbows and chest on the ground.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Zrób ten sam ruch pustą ręką, nagródź z drugiej ręki.',
        criterion: 'Pies kładzie się na ruch pustej ręki.',
      },
      en: {
        instruction: 'Make the same motion with an empty hand and pay from the other one.',
        criterion: 'The dog lies down to the empty-hand motion.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction: 'Powiedz „leżeć", odczekaj sekundę, dopiero potem gest. Zawsze w tej kolejności.',
        criterion: 'Pies kładzie się po sekwencji słowo-pauza-gest.',
      },
      en: {
        instruction: 'Say “down”, wait a second, then give the signal. Always in that order.',
        criterion: 'The dog lies down after the word-pause-signal sequence.',
      },
    },
    {
      ordinal: 6,
      pl: {
        instruction:
          'Powiedz „leżeć" i czekaj trzy sekundy bez gestu. Siad po geście nie liczy się jako trafienie.',
        criterion: 'Pies kładzie się po samym słowie, w ciągu trzech sekund.',
      },
      en: {
        instruction:
          'Say “down” and wait three seconds with no signal. A down that needed the signal does not count.',
        criterion: 'The dog lies down to the word alone, within three seconds.',
      },
    },
    {
      ordinal: 7,
      pl: {
        instruction:
          'Sprawdź podłoże. Wielu psów nie chce kłaść się na zimnym kafelku albo śliskim panelu — jeśli na dywanie idzie, a na kuchennej podłodze nie, to nie jest nieposłuszeństwo.',
        criterion: 'Pies kładzie się na samo słowo na dwóch różnych podłożach.',
      },
      en: {
        instruction:
          'Check the surface. Plenty of dogs will not lie on cold tile or slippery laminate — if it works on a rug and fails in the kitchen, that is not disobedience.',
        criterion: 'The dog lies down to the word alone on two different surfaces.',
      },
    },
  ],
};

const STAY: ExerciseSeed = {
  id: 'stay',
  category: 'impulse_control',
  sortOrder: 4,
  requires: ['sit', 'down'],
  names: {
    pl: {
      name: 'zostań',
      description:
        'Pies trzyma pozycję, dopóki go nie zwolnisz — mimo że Ty się ruszasz. Rośnie po jednej osi naraz: najpierw czas, potem dystans, na końcu rozproszenia. Nigdy dwie naraz.',
    },
    en: {
      name: 'stay',
      description:
        'The dog holds position until released, even while you move. It grows along one axis at a time: duration first, then distance, then distraction. Never two at once.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction: 'Poproś o siad. Odlicz trzy sekundy, nagródź, zwolnij słowem „koniec".',
        criterion: 'Trzy sekundy w siadzie bez wstawania.',
      },
      en: {
        instruction: 'Ask for a sit. Count three seconds, pay, then release with “okay”.',
        criterion: 'Three seconds in the sit without getting up.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Dziesięć sekund. Stój nieruchomo, nie oddalaj się jeszcze.',
        criterion: 'Dziesięć sekund bez wstawania.',
      },
      en: {
        instruction: 'Ten seconds. Stand still — do not add distance yet.',
        criterion: 'Ten seconds without getting up.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction:
          'Wróć do trzech sekund, ale zrób jeden krok w bok i wróć. Podnosząc dystans, skracasz czas — to nie jest cofanie się, tylko reguła.',
        criterion: 'Pies zostaje przez jeden Twój krok w bok.',
      },
      en: {
        instruction:
          'Go back to three seconds but take one step sideways and return. When you raise distance you shorten duration — that is the rule, not a setback.',
        criterion: 'The dog holds while you take one step sideways.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Trzy kroki w tył i powrót, wciąż trzy sekundy.',
        criterion: 'Pies zostaje przez trzy Twoje kroki i powrót.',
      },
      en: {
        instruction: 'Three steps back and return, still three seconds.',
        criterion: 'The dog holds through three steps and your return.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction: 'Połącz: dziesięć sekund i trzy kroki. Jeśli się sypie, zdejmij jedną z osi, nie obie.',
        criterion: 'Dziesięć sekund przy trzech krokach dystansu.',
      },
      en: {
        instruction: 'Combine: ten seconds at three steps. If it falls apart, drop one axis, not both.',
        criterion: 'Ten seconds at three steps of distance.',
      },
    },
  ],
};

const COME: ExerciseSeed = {
  id: 'come',
  category: 'impulse_control',
  sortOrder: 5,
  requires: ['look'],
  names: {
    pl: {
      name: 'do mnie',
      description:
        'Pies biegnie do Ciebie na wezwanie. Jedyna komenda, która ratuje życie — i jedyna, którą najłatwiej zepsuć na zawsze. Zasada bez wyjątku: powrót nigdy nie może skończyć się czymś nieprzyjemnym.',
    },
    en: {
      name: 'come',
      description:
        'The dog runs to you when called. The one cue that saves lives, and the easiest one to ruin permanently. One rule, no exceptions: coming back must never cost the dog anything.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'W domu, z odległości dwóch kroków, powiedz imię psa i „do mnie" radosnym tonem. Gdy przyjdzie — nagródź hojnie i pozwól mu odejść z powrotem do swoich spraw.',
        criterion: 'Pies przychodzi w ciągu trzech sekund.',
      },
      en: {
        instruction:
          'Indoors, from two steps away, say the dog’s name and “come” in a bright voice. When they arrive, pay generously and let them go back to what they were doing.',
        criterion: 'The dog comes within three seconds.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Pięć kroków, z innego pokoju, gdy pies Cię nie widzi.',
        criterion: 'Pies przybiega z innego pokoju.',
      },
      en: {
        instruction: 'Five steps, from another room, out of sight.',
        criterion: 'The dog comes from another room.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction:
          'Złap psa za obrożę przy nagradzaniu i od razu puść. Pies musi nauczyć się, że sięgnięcie po obrożę nie oznacza końca zabawy.',
        criterion: 'Pies przychodzi i spokojnie znosi dotknięcie obroży.',
      },
      en: {
        instruction:
          'Take hold of the collar as you pay, then release immediately. The dog has to learn that a hand on the collar does not mean the fun is over.',
        criterion: 'The dog comes and accepts the collar touch calmly.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction:
          'W ogrodzie, na długiej lince. Nigdy nie wołaj, jeśli nie masz jak dokończyć — przywołanie bez reakcji uczy, że „do mnie" jest opcjonalne.',
        criterion: 'Pies przybiega z pięciu metrów na lince.',
      },
      en: {
        instruction:
          'In the garden on a long line. Never call if you cannot follow through — a recall that goes unanswered teaches that “come” is optional.',
        criterion: 'The dog comes from five metres on the line.',
      },
    },
  ],
};

const LEAVE: ExerciseSeed = {
  id: 'leave',
  category: 'impulse_control',
  sortOrder: 6,
  requires: ['look'],
  names: {
    pl: {
      name: 'zostaw',
      description:
        'Pies nie bierze i nie dotyka tego, co wskażesz. Polskie szkoły używają też „nie rusz" — wybierz jedno słowo i trzymaj się go. To ćwiczenie dotyczy rzeczy, których pies jeszcze nie ma w pysku; na oddanie tego, co już wziął, jest osobna komenda.',
    },
    en: {
      name: 'leave it',
      description:
        'The dog does not take or touch the thing you name. This covers things not yet in the mouth — getting something back out of it is a different cue.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Zamknij smakołyk w dłoni i podsuń psu. Czekaj. Pies będzie lizał i trącał — nie mów nic. W sekundzie, w której się odsunie, chwal i nagródź z DRUGIEJ ręki.',
        criterion: 'Pies odsuwa nos od zamkniętej dłoni choć na chwilę.',
      },
      en: {
        instruction:
          'Close a treat in your fist and offer it. Wait. The dog will lick and nudge — say nothing. The second they back off, praise and pay from your OTHER hand.',
        criterion: 'The dog moves their nose away from the closed fist, even briefly.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Czekaj, aż pies odsunie się i spojrzy na Ciebie, zanim nagrodzisz.',
        criterion: 'Pies odsuwa się i nawiązuje kontakt wzrokowy.',
      },
      en: {
        instruction: 'Wait for the dog to back off and look at you before paying.',
        criterion: 'The dog backs off and makes eye contact.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Otwórz dłoń. Jeśli pies sięga — zamknij ją. Płać za wycofanie się przy otwartej dłoni.',
        criterion: 'Pies nie sięga po smakołyk na otwartej dłoni.',
      },
      en: {
        instruction: 'Open your hand. If the dog lunges, close it. Pay for backing off from the open palm.',
        criterion: 'The dog does not reach for the treat on an open palm.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Połóż smakołyk na podłodze i przykryj stopą. Ta sama zasada: płacisz za odsunięcie się.',
        criterion: 'Pies odsuwa się od smakołyka na podłodze.',
      },
      en: {
        instruction: 'Put the treat on the floor and cover it with your foot. Same rule: pay for backing off.',
        criterion: 'The dog backs away from the treat on the floor.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction: 'Dopiero teraz dodaj słowo „zostaw", mówiąc je tuż przed podsunięciem smakołyka.',
        criterion: 'Pies nie sięga po usłyszeniu „zostaw".',
      },
      en: {
        instruction: 'Only now add the word “leave it”, said just before you present the treat.',
        criterion: 'The dog does not reach after hearing the cue.',
      },
    },
  ],
};

const MAT: ExerciseSeed = {
  id: 'mat',
  category: 'impulse_control',
  sortOrder: 7,
  requires: ['down'],
  names: {
    pl: {
      name: 'na miejsce',
      description:
        'Pies idzie na swoje posłanie i tam zostaje. Najbardziej praktyczna komenda w domu: rozwiązuje gości w drzwiach, obiad przy stole i kuriera jednym ruchem.',
    },
    en: {
      name: 'place',
      description:
        'The dog goes to their bed or mat and stays there. The most practical cue in the house: it solves visitors, dinner and the doorbell in one move.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction: 'Rzuć smakołyk na matę. Gdy pies na nią wejdzie — chwal i daj drugi smakołyk, już na macie.',
        criterion: 'Cztery łapy na macie.',
      },
      en: {
        instruction: 'Toss a treat onto the mat. When the dog steps on, praise and feed a second treat on the mat.',
        criterion: 'All four feet on the mat.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Czekaj, aż pies położy się na macie sam. Nie proś — płać za decyzję.',
        criterion: 'Pies kładzie się na macie bez komendy.',
      },
      en: {
        instruction: 'Wait for the dog to lie down on the mat by themselves. Do not ask — pay the decision.',
        criterion: 'The dog lies down on the mat without being cued.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Odejdź o krok i wróć, nagradzając psa leżącego na macie.',
        criterion: 'Pies zostaje na macie przez jeden Twój krok.',
      },
      en: {
        instruction: 'Step away and return, paying the dog while they are still on the mat.',
        criterion: 'The dog stays on the mat through one step away.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Dodaj słowo „na miejsce", mówiąc je, gdy pies już idzie w stronę maty.',
        criterion: 'Pies idzie na matę po usłyszeniu komendy.',
      },
      en: {
        instruction: 'Add the cue “place”, said as the dog is already heading for the mat.',
        criterion: 'The dog goes to the mat on hearing the cue.',
      },
    },
  ],
};

/** Every exercise the app ships, in teaching order. */
export const CATALOGUE: readonly CatalogueEntry[] = [
  { ...SIT, pose: 'sit' },
  { ...LOOK, pose: 'look' },
  { ...DOWN, pose: 'down' },
  { ...STAY, pose: 'stay' },
  { ...COME, pose: 'come' },
  { ...LEAVE, pose: 'leave' },
  { ...MAT, pose: 'mat' },
];

/** Look up one exercise by id. */
export function exerciseById(id: string): CatalogueEntry | undefined {
  return CATALOGUE.find((entry) => entry.id === id);
}
