/**
 * Step ladders in the structured form: setup, one repetition, one note.
 *
 * Split out of `catalogue.ts` so the exercise definitions there stay readable
 * while the copy — which is the bulk of this app — lives together and can be
 * reviewed as a body of writing rather than scattered between data structures.
 *
 * The shape is the same everywhere:
 *
 * - **setup** — at most three imperatives, things you arrange before the dog is
 *   involved. Never repeats what the gear row already shows.
 * - **reps** — three or four numbered actions that are *one* repetition, start
 *   to finish. If a step needs more than four, it is really two steps.
 * - **note** — one sentence, and only where there is a real trap. It always
 *   carries the reason, because a bare prohibition is forgotten and a mechanism
 *   is not.
 */

import type { StepSeed } from './sit';

export const STEPS: Readonly<Record<string, readonly StepSeed[]>> = {
  name: [
    {
      ordinal: 1,
      pl: {
        instruction: 'Imię jest prośbą o spojrzenie, nie wezwaniem.',
        setup: ['Cichy pokój', 'Pies spokojny i zajęty czymś swoim'],
        reps: ['Powiedz imię psa — raz, pogodnym tonem', 'Czekaj, aż odwróci głowę', 'Nagródź natychmiast'],
        note:
          'Jeśli pies nie zareaguje, nie powtarzaj. Każde kolejne wywołanie uczy, że pierwsze nic nie znaczyło — odczekaj chwilę i spróbuj później.',
        criterion: 'Pies odwraca głowę w Twoją stronę po jednym wypowiedzeniu imienia.',
      },
      en: {
        instruction: 'A name is a request for attention, not a summons.',
        setup: ['A quiet room', 'The dog calm and busy with their own thing'],
        reps: ['Say the dog’s name — once, in a bright tone', 'Wait for the head to turn', 'Pay immediately'],
        note:
          'If nothing happens, do not repeat it. Every extra call teaches that the first one meant nothing — wait and try again later.',
        criterion: 'The dog turns their head toward you after one call.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'To samo, gdy pies jest lekko czymś zajęty.',
        setup: ['Ten sam pokój', 'Poczekaj, aż pies zacznie coś wąchać albo oglądać'],
        reps: ['Powiedz imię — raz', 'Czekaj na odwrócenie się', 'Nagródź i pozwól wrócić do swojego zajęcia'],
        note:
          'Puszczenie psa z powrotem do tego, co robił, jest częścią nagrody. Inaczej imię zacznie zapowiadać koniec zabawy.',
        criterion: 'Pies odrywa się od zajęcia i patrzy po jednym wypowiedzeniu imienia.',
      },
      en: {
        instruction: 'The same while the dog is mildly busy.',
        setup: ['The same room', 'Wait until they start sniffing or watching something'],
        reps: ['Say the name — once', 'Wait for them to turn', 'Pay, then let them go back to it'],
        note:
          'Letting them return to what they were doing is part of the reward. Otherwise the name starts to predict the end of the fun.',
        criterion: 'The dog disengages and looks after one call.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Z innego pokoju, poza zasięgiem wzroku.',
        setup: ['Drzwi otwarte', 'Smakołyk gotowy w ręce, zanim zawołasz'],
        reps: ['Wyjdź do drugiego pokoju', 'Powiedz imię — raz', 'Nagródź, gdy pies przyjdzie albo wyraźnie zareaguje'],
        criterion: 'Pies przychodzi lub wyraźnie reaguje, nie widząc Cię.',
      },
      en: {
        instruction: 'From another room, out of sight.',
        setup: ['Doors open', 'The treat ready in your hand before you call'],
        reps: ['Step into the next room', 'Say the name — once', 'Pay when they come or clearly respond'],
        criterion: 'The dog comes or clearly responds without seeing you.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Na dworze, gdzie jest co wąchać.',
        setup: ['Ogród albo spokojna ulica', 'Smakołyki lepsze niż zwykle'],
        reps: ['Pozwól psu chwilę powęszyć', 'Powiedz imię — raz', 'Nagródź hojnie i pozwól wrócić do węszenia'],
        note:
          'Na dworze konkurencja dla Ciebie jest dużo silniejsza niż w domu. To moment na najlepsze smakołyki, jakie masz, nie na suchą karmę.',
        criterion: 'Pies odwraca się po jednym wypowiedzeniu imienia na dworze.',
      },
      en: {
        instruction: 'Outdoors, where there is something to smell.',
        setup: ['The garden or a quiet street', 'Better treats than usual'],
        reps: ['Let them sniff for a moment', 'Say the name — once', 'Pay generously and let them go back to sniffing'],
        note:
          'Outdoors the competition for their attention is far stronger than indoors. This is the moment for the best food you have, not kibble.',
        criterion: 'The dog turns after one call outdoors.',
      },
    },
  ],

  look: [
    {
      ordinal: 1,
      pl: {
        instruction: 'Nagroda ma być przy Twoim oku, nie przy psim nosie.',
        setup: ['Pies przed Tobą, swobodnie', 'Smakołyk między palcami'],
        reps: ['Podnieś smakołyk do swojego oka', 'Czekaj, aż pies spojrzy Ci w oczy', 'Chwal i nagródź'],
        note: 'Nie mów jeszcze nic. Słowo wejdzie dopiero w kroku 4, gdy patrzenie samo w sobie będzie już pewne.',
        criterion: 'Pies przenosi wzrok ze smakołyka na Twoje oczy.',
      },
      en: {
        instruction: 'The reward goes beside your eye, not under their nose.',
        setup: ['The dog loose in front of you', 'A treat between your fingers'],
        reps: ['Raise the treat to your own eye', 'Wait until they meet your eyes', 'Praise and pay'],
        note: 'Say nothing yet. The word arrives at step 4, once looking is already reliable on its own.',
        criterion: 'The dog shifts their gaze from the treat to your eyes.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Dwie sekundy nieprzerwanego kontaktu.',
        setup: ['To samo ustawienie'],
        reps: ['Podnieś smakołyk do oka', 'Policz do dwóch, patrząc psu w oczy', 'Nagródź, gdy kontakt wciąż trwa'],
        criterion: 'Dwie sekundy nieprzerwanego kontaktu wzrokowego.',
      },
      en: {
        instruction: 'Two unbroken seconds.',
        setup: ['The same setup'],
        reps: ['Raise the treat to your eye', 'Count to two while holding their gaze', 'Pay while contact is still held'],
        criterion: 'Two unbroken seconds of eye contact.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Smakołyk do kieszeni — czekasz, aż pies sam spojrzy.',
        setup: ['Smakołyki w kieszeni, ręce opuszczone', 'Stań spokojnie i nic nie rób'],
        reps: ['Czekaj w bezruchu', 'Pies prędzej czy później spojrzy Ci w oczy', 'W tej sekundzie chwal i nagródź'],
        note:
          'To jest moment, w którym patrzenie na Ciebie przestaje być Twoim pomysłem, a staje się psim. Bywa, że pierwsze spojrzenie trwa pół minuty — czekaj.',
        criterion: 'Pies sam nawiązuje kontakt wzrokowy, bez smakołyka w polu widzenia.',
      },
      en: {
        instruction: 'Treat in the pocket — you wait for them to offer it.',
        setup: ['Treats in your pocket, hands down', 'Stand still and do nothing'],
        reps: ['Wait, completely still', 'Sooner or later they will look at your eyes', 'Praise and pay in that second'],
        note:
          'This is where looking at you stops being your idea and becomes theirs. The first offer can take half a minute — wait it out.',
        criterion: 'The dog offers eye contact with no treat in sight.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Słowo wchodzi na gotowe zachowanie.',
        setup: ['Smakołyki w kieszeni'],
        reps: ['Obserwuj psa i wyczuj moment, gdy zaraz spojrzy', 'Powiedz „patrz" tuż przed tym', 'Nagródź spojrzenie'],
        note:
          'Mówisz słowo tuż przed czymś, co i tak się wydarzy. Pies kojarzy je z zachowaniem, zamiast uczyć się go w próżni.',
        criterion: 'Pies patrzy w ciągu dwóch sekund po słowie.',
      },
      en: {
        instruction: 'The word attaches to a behaviour that already exists.',
        setup: ['Treats in your pocket'],
        reps: ['Watch them and sense when a look is coming', 'Say “look” just before it', 'Pay the look'],
        note:
          'You are saying the word just before something that was going to happen anyway. The dog pairs it with the behaviour instead of learning it in a vacuum.',
        criterion: 'The dog looks within two seconds of the word.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction: 'Poproś o „patrz", gdy pies jest czymś zajęty.',
        setup: ['Pies węszy albo się rozgląda', 'Smakołyki gotowe'],
        reps: ['Powiedz „patrz" — raz', 'Czekaj dwie sekundy', 'Nagródź oderwanie się i spojrzenie'],
        criterion: 'Pies odrywa się od tego, co robił, i patrzy.',
      },
      en: {
        instruction: 'Ask for “look” while they are busy with something.',
        setup: ['The dog sniffing or glancing around', 'Treats ready'],
        reps: ['Say “look” — once', 'Wait two seconds', 'Pay the disengagement and the look'],
        criterion: 'The dog disengages from what they were doing and looks.',
      },
    },
  ],

  down: [
    {
      ordinal: 1,
      pl: {
        instruction: 'Smakołyk prosto w dół, między przednie łapy.',
        setup: ['Pies w siadzie', 'Dywan albo koc — nie zimny kafelek'],
        reps: ['Przyłóż smakołyk do nosa', 'Poprowadź go prosto w dół do podłogi', 'Płać za każde wyraźne opuszczenie głowy'],
        note:
          'Zimne lub śliskie podłoże to najczęstszy prawdziwy powód, dla którego pies nie chce się położyć. Sprawdź dywan, zanim uznasz to za upór.',
        criterion: 'Głowa schodzi wyraźnie w dół za smakołykiem.',
      },
      en: {
        instruction: 'The treat goes straight down, between the front paws.',
        setup: ['The dog sitting', 'A rug or blanket — not cold tile'],
        reps: ['Put the treat to their nose', 'Draw it straight down to the floor', 'Pay any clear lowering of the head'],
        note:
          'Cold or slippery flooring is the most common real reason a dog will not lie down. Try a rug before you call it stubbornness.',
        criterion: 'The head follows the treat clearly downward.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction: 'Po dojściu do podłogi — powoli do siebie.',
        setup: ['To samo miękkie podłoże'],
        reps: ['Poprowadź smakołyk w dół jak poprzednio', 'Przy podłodze ciągnij go powoli do siebie', 'Płać, gdy łokieć dotknie ziemi'],
        note:
          'Jeśli pies kuca, ale łokcie zostają w górze, smakołyk idzie w dół, ale nie do przodu — klatka nie ma powodu iść za nim.',
        criterion: 'Co najmniej jeden łokieć dotyka podłogi.',
      },
      en: {
        instruction: 'Once at the floor — slowly toward you.',
        setup: ['The same soft surface'],
        reps: ['Draw the treat down as before', 'At the floor, draw it slowly toward you', 'Pay when an elbow touches down'],
        note:
          'If they crouch but the elbows stay up, the treat went down but not forward — the chest has no reason to follow.',
        criterion: 'At least one elbow touches the floor.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction: 'Pełne położenie — łokcie i klatka na ziemi.',
        setup: ['To samo miejsce'],
        reps: ['Zrób pełny ruch w dół i do siebie', 'Czekaj na łokcie i klatkę na ziemi', 'Chwal i nagródź w pozycji leżącej'],
        note: 'Jeśli pies wstaje, zabierz smakołyk bez słowa i zacznij od nowa. Żadnego komentarza — cisza niesie informację.',
        criterion: 'Łokcie i klatka na ziemi.',
      },
      en: {
        instruction: 'The full down — elbows and chest on the ground.',
        setup: ['The same place'],
        reps: ['Make the full down-and-toward motion', 'Wait for elbows and chest to land', 'Praise and feed while they are down'],
        note: 'If they stand up, take the treat away without a word and restart. No comment — silence carries the information.',
        criterion: 'Elbows and chest on the ground.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction: 'Pusta ręka prowadzi, nagroda z drugiej.',
        setup: ['Smakołyki przełóż do drugiej ręki, za plecy'],
        reps: ['Zrób ten sam ruch pustą ręką', 'Czekaj na pełne położenie', 'Nagródź z ręki zza pleców, pies zjada leżąc'],
        criterion: 'Pies kładzie się na ruch pustej ręki.',
      },
      en: {
        instruction: 'The empty hand leads, the reward comes from the other.',
        setup: ['Treats moved to the other hand, behind your back'],
        reps: ['Make the same motion with the empty hand', 'Wait for the full down', 'Feed from behind your back, eaten lying down'],
        criterion: 'The dog lies down to the empty-hand motion.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction: 'Słowo, pauza, gest — zawsze w tej kolejności.',
        setup: ['Nagroda w drugiej ręce'],
        reps: ['Powiedz „leżeć" — raz', 'Odczekaj sekundę w ciszy', 'Zrób gest, pochwal, nagródź'],
        note: 'Nigdy w trakcie gestu i nigdy po nim. Słowo razem z ruchem ręki uczy psa patrzeć na rękę i nie słuchać.',
        criterion: 'Pies kładzie się po sekwencji słowo-pauza-gest.',
      },
      en: {
        instruction: 'Word, pause, signal — always in that order.',
        setup: ['The reward in your other hand'],
        reps: ['Say “down” — once', 'Wait a second in silence', 'Give the signal, praise, pay'],
        note: 'Never during the signal and never after it. The word landing with the hand teaches the dog to watch and not listen.',
        criterion: 'The dog lies down after the word-pause-signal sequence.',
      },
    },
    {
      ordinal: 6,
      pl: {
        instruction: 'Samo słowo. Położenie po geście to pudło.',
        setup: ['Ręce opuszczone wzdłuż ciała'],
        reps: ['Powiedz „leżeć" i czekaj trzy sekundy', 'Położył się — nagródź hojnie', 'Nie położył się — zrób gest, pochwal, bez smakołyka'],
        criterion: 'Pies kładzie się po samym słowie, w ciągu trzech sekund.',
      },
      en: {
        instruction: 'The word alone. A down that needed the signal is a miss.',
        setup: ['Hands at your sides'],
        reps: ['Say “down” and wait three seconds', 'If they go down, pay generously', 'If not, signal and praise — no treat'],
        criterion: 'The dog lies down to the word alone, within three seconds.',
      },
    },
    {
      ordinal: 7,
      pl: {
        instruction: 'Sprawdź dwa różne podłoża.',
        setup: ['Jedno miękkie podłoże i jedno twarde', 'Ten sam pokój, żeby zmieniać tylko jedną rzecz'],
        reps: ['Poproś o „leżeć" na dywanie', 'Przejdź na podłogę i poproś ponownie', 'Nagradzaj obie wersje tak samo'],
        note:
          'Jeśli na dywanie idzie, a na kuchennej podłodze nie, to nie jest nieposłuszeństwo. Zimno i śliskość są realnym powodem — nie przepychaj, znajdź matę.',
        criterion: 'Pies kładzie się na samo słowo na dwóch różnych podłożach.',
      },
      en: {
        instruction: 'Try two different surfaces.',
        setup: ['One soft surface and one hard', 'The same room, so only one thing changes'],
        reps: ['Ask for a down on the rug', 'Move to the floor and ask again', 'Pay both the same'],
        note:
          'If it works on the rug and fails on the kitchen floor, that is not disobedience. Cold and slippery are real reasons — do not push, find a mat.',
        criterion: 'The dog lies down to the word alone on two different surfaces.',
      },
    },
  ],
};
