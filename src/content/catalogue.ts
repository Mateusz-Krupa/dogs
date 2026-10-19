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

import type { GearId } from '../ui/Gear';
import type { Pose } from '../ui/DogPose';
import { SIT, type ExerciseSeed } from './exercises/sit';
import { STEPS } from './exercises/steps';

/** An exercise plus the illustration that represents it. */
export interface CatalogueEntry extends ExerciseSeed {
  readonly pose: Pose;
  /**
   * Four or five words for the list card. The full description is written for
   * the exercise screen, where there is room to read; a card is scanned, not
   * read, and a paragraph on it reads as noise.
   */
  readonly tagline: { readonly pl: string; readonly en: string };
  /** What to have to hand before starting. Shown as icons on the exercise screen. */
  readonly gear: readonly GearId[];
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
  steps: STEPS.look!,
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
  steps: STEPS.down!,
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

const NAME: ExerciseSeed = {
  id: 'name',
  category: 'foundation',
  sortOrder: 0,
  requires: [],
  names: {
    pl: {
      name: 'imię',
      description:
        'Pies odwraca się do Ciebie, słysząc swoje imię. To fundament pod wszystko inne — bez tego każda komenda zaczyna się od walki o uwagę. Imię to prośba o spojrzenie, nie nagana; jeśli używasz go przy upominaniu, przestaje działać.',
    },
    en: {
      name: 'name',
      description:
        'The dog turns to you on hearing their name. Everything else is built on it. A name is a request for attention, never a telling-off — use it to scold and it stops working.',
    },
  },
  steps: STEPS.name!,
};

const WAIT: ExerciseSeed = {
  id: 'wait',
  category: 'impulse_control',
  sortOrder: 8,
  requires: ['sit'],
  names: {
    pl: {
      name: 'czekaj',
      description:
        'Pies wstrzymuje się przed progiem, miską albo otwartym bagażnikiem, dopóki nie pozwolisz. To nie to samo co „zostań" — tu chodzi o krótkie wstrzymanie przed czymś, nie o trzymanie pozycji.',
    },
    en: {
      name: 'wait',
      description:
        'The dog holds back at a doorway, a bowl or an open boot until released. Not the same as stay: this is a short pause before something, not holding a position.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Przy zamkniętych drzwiach poproś o siad i zacznij powoli naciskać klamkę. Gdy pies wstanie — puść klamkę bez słowa. Gdy zostanie — otwórz na centymetr i nagródź.',
        criterion: 'Pies zostaje w siadzie, gdy dotykasz klamki.',
      },
      en: {
        instruction:
          'At a closed door, ask for a sit and slowly start pressing the handle. If the dog gets up, let go without a word. If they hold, open a centimetre and pay.',
        criterion: 'The dog stays sitting while you touch the handle.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Uchyl drzwi na dłoń. Każde wstanie zamyka drzwi — bez komentarza, bez „nie".',
        criterion: 'Pies zostaje przy drzwiach uchylonych na szerokość dłoni.',
      },
      en: {
        instruction: 'Open the door a hand’s width. Any getting up closes it again — no comment, no “no”.',
        criterion: 'The dog holds with the door open a hand’s width.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Otwórz całe drzwi. Dopiero po chwili zwolnij psa słowem „koniec" i pozwól wyjść.',
        criterion: 'Pies czeka przy całkowicie otwartych drzwiach do zwolnienia.',
      },
      en: {
        instruction: 'Open the door fully. After a beat, release with “okay” and let them through.',
        criterion: 'The dog waits at a fully open door until released.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction:
          'To samo z miską: trzymaj ją w rękach i opuszczaj powoli. Ruch psa w stronę miski podnosi ją z powrotem.',
        criterion: 'Miska dotyka podłogi, a pies nie rusza się, dopóki nie pozwolisz.',
      },
      en: {
        instruction:
          'The same with a food bowl: hold it and lower it slowly. Any move toward it lifts the bowl back up.',
        criterion: 'The bowl reaches the floor and the dog does not move until released.',
      },
    },
  ],
};

const LEASH: ExerciseSeed = {
  id: 'leash',
  category: 'impulse_control',
  sortOrder: 9,
  requires: ['name'],
  names: {
    pl: {
      name: 'luźna smycz',
      description:
        'Smycz wisi luźno w kształcie litery U. To nie jest „noga" — pies nie musi iść w konkretnej pozycji, ma tylko nie ciągnąć. Jedyna reguła: ciągnięcie nigdy nie może zadziałać, bo jeśli raz zadziała, uczy się na całe życie.',
    },
    en: {
      name: 'loose lead',
      description:
        'The lead hangs in a U. This is not heel — the dog need not hold a position, only stop pulling. One rule: pulling must never work, because a single success teaches it for good.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'W domu, ze smyczą, zrób trzy kroki. Dopóki smycz wisi luźno — nagradzaj co kilka kroków, podając smakołyk przy swojej nodze.',
        criterion: 'Trzy kroki z luźną smyczą.',
      },
      en: {
        instruction:
          'Indoors on the lead, take three steps. While the lead stays loose, pay every few steps, delivering the treat at your leg.',
        criterion: 'Three steps with a loose lead.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction:
          'Gdy smycz się napnie, zatrzymaj się i stój. Nie szarp i nie ciągnij do siebie. Ruszasz dopiero, gdy smycz znów zwiotczeje.',
        criterion: 'Pies sam rozluźnia smycz i ruszacie dalej.',
      },
      en: {
        instruction:
          'When the lead goes tight, stop and stand still. No jerking, no reeling in. You move again only once it slackens.',
        criterion: 'The dog releases the tension themselves and you move on.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Dziesięć kroków w ogrodzie albo na podjeździe.',
        criterion: 'Dziesięć kroków bez napięcia smyczy.',
      },
      en: {
        instruction: 'Ten steps in the garden or on the driveway.',
        criterion: 'Ten steps with no tension on the lead.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction:
          'Spokojna ulica, krótki odcinek. Pozwól psu wąchać — wąchanie jest nagrodą, a spacer bez wąchania to dla psa kara.',
        criterion: 'Dwadzieścia kroków na ulicy z luźną smyczą.',
      },
      en: {
        instruction:
          'A quiet street, a short stretch. Let the dog sniff — sniffing is the reward, and a walk without it is a punishment from the dog’s side.',
        criterion: 'Twenty steps on the street with a loose lead.',
      },
    },
  ],
};

const DROP: ExerciseSeed = {
  id: 'drop',
  category: 'impulse_control',
  sortOrder: 10,
  requires: ['leave'],
  names: {
    pl: {
      name: 'puść',
      description:
        'Pies oddaje to, co już ma w pysku. Osobna komenda od „zostaw" i ważniejsza, niż się wydaje: to ona ratuje psa, który podniósł coś niebezpiecznego. Nigdy nie wyrywaj siłą — od tego zaczyna się pilnowanie zasobów.',
    },
    en: {
      name: 'drop it',
      description:
        'The dog gives up what is already in their mouth. A separate cue from leave it, and the one that matters when they pick up something dangerous. Never prise it out — that is how resource guarding starts.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Daj psu coś nudnego do trzymania. Podsuń pod nos smakołyk wyraźnie lepszy niż to, co ma. Gdy otworzy pysk — chwal i daj smakołyk, a potem oddaj mu zabawkę z powrotem.',
        criterion: 'Pies wypuszcza przedmiot z pyska.',
      },
      en: {
        instruction:
          'Give the dog something dull to hold. Offer a treat clearly better than what they have. When the mouth opens, praise, pay, then give the toy straight back.',
        criterion: 'The dog releases the item.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction:
          'Oddawanie zabawki po każdym powtórzeniu jest najważniejszą częścią. Pies musi się nauczyć, że „puść" nie oznacza straty.',
        criterion: 'Pies wypuszcza i od razu chętnie bierze zabawkę ponownie.',
      },
      en: {
        instruction:
          'Giving the toy back every single time is the important part. The dog has to learn that “drop” does not mean loss.',
        criterion: 'The dog releases and willingly takes the toy again.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Dodaj słowo „puść" tuż przed podaniem smakołyka.',
        criterion: 'Pies wypuszcza po usłyszeniu komendy.',
      },
      en: {
        instruction: 'Add the cue “drop it” just before offering the treat.',
        criterion: 'The dog releases on hearing the cue.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Spróbuj z czymś, co pies lubi bardziej. Jeśli nie puszcza — wróć do nudniejszego przedmiotu.',
        criterion: 'Pies wypuszcza ulubioną zabawkę na samo słowo.',
      },
      en: {
        instruction: 'Try something the dog likes more. If they will not let go, go back to a duller item.',
        criterion: 'The dog releases a favourite toy on the word alone.',
      },
    },
  ],
};

const HANDLING: ExerciseSeed = {
  id: 'handling',
  category: 'foundation',
  sortOrder: 11,
  requires: [],
  names: {
    pl: {
      name: 'obsługa',
      description:
        'Pies spokojnie znosi dotykanie łap, uszu, pyska i sierści. Najbardziej niedoceniane ćwiczenie w całym wychowaniu: decyduje o tym, czy wizyta u weterynarza i obcinanie pazurów będą rutyną, czy walką przez następne piętnaście lat.',
    },
    en: {
      name: 'handling',
      description:
        'The dog accepts having paws, ears, mouth and coat touched. The most underrated exercise there is: it decides whether vet visits and nail trims are routine or a fight for the next fifteen years.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Dotknij ramienia psa na sekundę i od razu nagródź. Jeśli pies się odsuwa — skróć dotyk, nie przytrzymuj.',
        criterion: 'Pies pozwala dotknąć ramienia i nie odsuwa się.',
      },
      en: {
        instruction:
          'Touch the dog’s shoulder for a second and pay immediately. If they move away, shorten the touch — never hold them in place.',
        criterion: 'The dog accepts a shoulder touch without moving away.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Przesuń dłoń na łapę. Dotknij, policz do jednego, nagródź.',
        criterion: 'Pies pozwala dotknąć łapy.',
      },
      en: {
        instruction: 'Move to a paw. Touch, count one, pay.',
        criterion: 'The dog accepts a paw touch.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Podnieś łapę na sekundę i odłóż. Potem drugą. Nagradzaj każdą.',
        criterion: 'Pies pozwala podnieść i odłożyć łapę.',
      },
      en: {
        instruction: 'Lift a paw for a second and set it down. Then another. Pay each one.',
        criterion: 'The dog lets you lift and lower a paw.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Unieś ucho i zajrzyj do środka. Potem odchyl wargę i obejrzyj zęby.',
        criterion: 'Pies spokojnie znosi obejrzenie ucha i zębów.',
      },
      en: {
        instruction: 'Lift an ear and look inside. Then lift a lip and look at the teeth.',
        criterion: 'The dog calmly accepts an ear and teeth check.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction:
          'Dotknij pazura nożyczkami albo obcinaczką, nie obcinając. Nagródź. Samo narzędzie ma przewidywać coś dobrego.',
        criterion: 'Pies spokojnie znosi dotknięcie pazura narzędziem.',
      },
      en: {
        instruction:
          'Touch a nail with the clippers without cutting. Pay. The tool itself has to predict something good.',
        criterion: 'The dog calmly accepts the clippers touching a nail.',
      },
    },
  ],
};

/** Every exercise the app ships, in teaching order. */
export const CATALOGUE: readonly CatalogueEntry[] = [
  {
    ...NAME,
    pose: 'look',
    tagline: { pl: 'Fundament pod wszystko', en: 'Everything is built on it' },
    gear: ['treats'],
  },
  {
    ...SIT,
    pose: 'sit',
    tagline: { pl: 'Od tego się zaczyna', en: 'Where everyone starts' },
    gear: ['treats'],
  },
  {
    ...LOOK,
    pose: 'look',
    tagline: { pl: 'Uwaga na Ciebie, nie na psa obok', en: 'Eyes on you, not the other dog' },
    gear: ['treats'],
  },
  {
    ...DOWN,
    pose: 'down',
    tagline: { pl: 'Pozycja na dłużej', en: 'The one they can hold' },
    gear: ['treats', 'mat'],
  },
  {
    ...STAY,
    pose: 'stay',
    tagline: { pl: 'Czas, potem dystans, potem hałas', en: 'Duration, then distance, then noise' },
    gear: ['treats'],
  },
  {
    ...COME,
    pose: 'come',
    tagline: { pl: 'Ta jedna ratuje życie', en: 'The one that saves lives' },
    gear: ['treats', 'longline', 'helper'],
  },
  {
    ...LEAVE,
    pose: 'leave',
    tagline: { pl: 'Nie bierz tego z chodnika', en: 'Not off the pavement' },
    gear: ['treats'],
  },
  {
    ...MAT,
    pose: 'mat',
    tagline: { pl: 'Rozwiązuje gości i obiad', en: 'Solves visitors and dinner' },
    gear: ['treats', 'mat'],
  },
  {
    ...WAIT,
    pose: 'stay',
    tagline: { pl: 'Nie wyrywaj się przez próg', en: 'No bolting through doors' },
    gear: ['treats', 'door', 'bowl'],
  },
  {
    ...LEASH,
    pose: 'come',
    tagline: { pl: 'Spacer bez ciągnięcia', en: 'A walk without the pulling' },
    gear: ['treats', 'lead'],
  },
  {
    ...DROP,
    pose: 'leave',
    tagline: { pl: 'Oddaj to, co już masz', en: 'Give back what you took' },
    gear: ['treats', 'toy'],
  },
  {
    ...HANDLING,
    pose: 'stand',
    tagline: { pl: 'Żeby weterynarz nie był walką', en: 'So the vet is not a fight' },
    gear: ['treats', 'clippers'],
  },
];

/** Look up one exercise by id. */
export function exerciseById(id: string): CatalogueEntry | undefined {
  return CATALOGUE.find((entry) => entry.id === id);
}
