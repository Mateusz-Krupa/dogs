/**
 * `siad` / sit — the first exercise.
 *
 * ## Where this comes from
 *
 * The *method* is standard force-free practice and is not anyone's property:
 * lure the movement, pay the moment the behaviour happens, fade the lure, add
 * the hand signal, and only then attach a word. The step-by-step progression
 * below is written for this app from several sources rather than copied from
 * any single one:
 *
 * - Push/Drop/Stick, the sets-of-five advancement rule — Jean Donaldson,
 *   *Train Your Dog Like a Pro* (2010). Method only; none of her wording.
 * - "The verbal cue comes late, and always *before* the hand signal, never
 *   during or after" — the same source and standard marker-training practice.
 * - Polish cue vocabulary — ZKwP / PT-1 regulations and Polish puppy-school
 *   curricula (John Dog, Projekt Pies). `siad` is unambiguous across all of them.
 * - Session length and puppy attention spans — AVSAB puppy guidance plus Polish
 *   puppy-school syllabi.
 *
 * ## Why the first steps look like they are not about sitting
 *
 * Steps 1–3 pay the puppy for craning its neck upward, not for sitting. The sit
 * is a side effect of the head going up and back: the rear drops because that is
 * the comfortable way to keep looking up. Paying the neck-crane first builds the
 * movement that produces the sit, which is why a puppy trained this way sits
 * faster than one pushed into position.
 *
 * Never push a puppy's rear down. Pressure on the hips produces resistance and
 * teaches the dog to brace against hands — the opposite of what every later
 * handling exercise needs.
 */

import type { ExerciseCategory } from '../../db/schema';

/** One micro-step on the installation ladder. */
export interface StepSeed {
  /** 1-based position in the ladder. */
  readonly ordinal: number;
  readonly pl: {
    readonly instruction: string;
    /** What counts as a correct rep. The owner scores against exactly this. */
    readonly criterion: string;
  };
  readonly en: {
    readonly instruction: string;
    readonly criterion: string;
  };
}

/** An exercise with everything needed to seed it. */
export interface ExerciseSeed {
  readonly id: string;
  readonly category: ExerciseCategory;
  readonly sortOrder: number;
  /** Advisory only — the app recommends, it never blocks. */
  readonly requires: readonly string[];
  readonly names: {
    readonly pl: { readonly name: string; readonly description: string };
    readonly en: { readonly name: string; readonly description: string };
  };
  readonly steps: readonly StepSeed[];
}

export const SIT: ExerciseSeed = {
  id: 'sit',
  category: 'foundation',
  sortOrder: 1,
  requires: [],
  names: {
    pl: {
      name: 'siad',
      description:
        'Pies siada i zostaje w siadzie, dopóki go nie zwolnisz. Najprostsza rzecz, jakiej możesz go nauczyć, i zastępuje połowę kłopotów: skakanie na ludzi, szarpanie przy drzwiach, żebranie przy stole.',
    },
    en: {
      name: 'sit',
      description:
        'The dog sits and stays sitting until you release them. The simplest thing you can teach, and it replaces half of the everyday nuisances: jumping on people, barging through doors, begging at the table.',
    },
  },
  steps: [
    {
      ordinal: 1,
      pl: {
        instruction:
          'Trzymaj smakołyk tuż nad nosem psa, na tyle nisko, żeby nie podskakiwał. Nie cofaj ręki. Policz do dwóch i daj smakołyk, gdy pies wciąż wyciąga szyję w górę. Pies nie musi jeszcze siadać — płacisz za wyciągniętą szyję.',
        criterion: 'Pies przez dwie sekundy sięga nosem w górę, nie podskakując i nie odchodząc.',
      },
      en: {
        instruction:
          'Hold a treat just above the puppy’s nose, low enough that they do not jump for it. Keep your hand still. Count to two and feed while the neck is still stretched upward. They do not need to sit yet — you are paying for the stretch.',
        criterion: 'The puppy reaches up with their nose for two seconds without jumping or walking off.',
      },
    },
    {
      ordinal: 2,
      pl: {
        instruction:
          'To samo, ale licz do czterech. Jeśli w którymś momencie zobaczysz, że tylne nogi się uginają — płać natychmiast, nie czekaj do końca liczenia.',
        criterion: 'Cztery sekundy wyciągniętej szyi albo wcześniejsze ugięcie kolan.',
      },
      en: {
        instruction:
          'The same, but count to four. If at any point the back legs start to fold, pay immediately — do not wait for the count to finish.',
        criterion: 'Four seconds of reaching up, or an earlier bend of the knees.',
      },
    },
    {
      ordinal: 3,
      pl: {
        instruction:
          'Policz do ośmiu. Jeśli to za długo i pies rezygnuje, podziel różnicę: wróć do sześciu, a gdy wyjdzie pięć na pięć, spróbuj ośmiu ponownie.',
        criterion: 'Osiem sekund wyciągniętej szyi albo ugięcie kolan.',
      },
      en: {
        instruction:
          'Count to eight. If that is too long and the puppy gives up, split the difference: go back to six, and once you get five out of five, try eight again.',
        criterion: 'Eight seconds of reaching up, or a bend of the knees.',
      },
    },
    {
      ordinal: 4,
      pl: {
        instruction:
          'Teraz czekaj na wyraźniejsze ugięcie tylnych nóg i płać dokładnie w momencie ugięcia. Moment ma znaczenie bardziej niż cokolwiek innego — nagroda spóźniona o sekundę uczy czegoś innego, niż chciałeś.',
        criterion: 'Tylne nogi wyraźnie się uginają, a smakołyk pada w momencie ugięcia.',
      },
      en: {
        instruction:
          'Now wait for a clearer fold of the back legs and pay exactly as it happens. Timing matters more than anything else here — a reward a second late teaches something other than what you intended.',
        criterion: 'The back legs clearly fold, and the treat lands at the moment they do.',
      },
    },
    {
      ordinal: 5,
      pl: {
        instruction:
          'Czekaj na pełny siad — zad na ziemi. Jeśli pies podskakuje albo się cofa, zabierz smakołyk i zacznij powtórzenie od nowa. Nie powtarzaj wtedy nic na głos.',
        criterion: 'Zad dotyka ziemi, przednie łapy zostają na miejscu.',
      },
      en: {
        instruction:
          'Hold out for a full sit — rear on the ground. If the puppy jumps or backs up, take the treat away and restart the repetition. Say nothing when you do.',
        criterion: 'The rear touches the ground and the front feet stay where they were.',
      },
    },
    {
      ordinal: 6,
      pl: {
        instruction:
          'Przełóż smakołyk do drugiej ręki i schowaj ją za plecy. Zrób ten sam ruch pustą ręką. Gdy pies usiądzie, pochwal i nagródź z tej drugiej ręki — karm tak, żeby zjadł w siadzie, nie wstając.',
        criterion: 'Pies siada na ruch pustej ręki i zjada nagrodę, nie wstając.',
      },
      en: {
        instruction:
          'Move the treat to your other hand and put it behind your back. Make the same motion with the empty hand. When they sit, praise and feed from the other hand — feed so they eat while still sitting.',
        criterion: 'The puppy sits to the empty-hand motion and eats without standing up.',
      },
    },
    {
      ordinal: 7,
      pl: {
        instruction:
          'Zrób ten ruch szybciej i mniejszym gestem — to od teraz Twój sygnał ręką na siad. Nagroda nadal z drugiej ręki, zza pleców.',
        criterion: 'Pies siada na wyraźny, krótki gest ręką.',
      },
      en: {
        instruction:
          'Make the motion faster and smaller — from now on this is your hand signal for sit. The reward still comes from the other hand, from behind your back.',
        criterion: 'The puppy sits to a short, distinct hand signal.',
      },
    },
    {
      ordinal: 8,
      pl: {
        instruction:
          'Dopiero teraz wchodzi słowo. Powiedz „siad" raz, odczekaj całą sekundę, i dopiero potem zrób gest. Zawsze w tej kolejności: słowo, pauza, gest. Nigdy w trakcie gestu i nigdy po nim.',
        criterion: 'Pies siada po sekwencji słowo-pauza-gest. Liczy się każdy siad, także ten po geście.',
      },
      en: {
        instruction:
          'Only now does the word come in. Say “sit” once, wait a full second, and only then give the hand signal. Always in that order: word, pause, signal. Never during the signal and never after it.',
        criterion: 'The puppy sits after the word-pause-signal sequence. Any sit counts here, including one that needed the signal.',
      },
    },
    {
      ordinal: 9,
      pl: {
        instruction:
          'Powiedz „siad" i czekaj trzy sekundy bez gestu. Jeśli pies usiądzie — nagródź. Jeśli nie, zrób gest, pochwal, ale tym razem nie nagradzaj smakołykiem. Nagradzasz tylko reakcję na samo słowo.',
        criterion: 'Pies siada w ciągu trzech sekund po samym słowie, bez gestu. Siad po geście liczy się jako pudło.',
      },
      en: {
        instruction:
          'Say “sit” and wait three seconds with no hand signal. If the puppy sits, pay. If not, give the signal and praise, but do not feed this time. You are only paying for a response to the word alone.',
        criterion: 'The puppy sits within three seconds of the word alone. A sit that needed the signal counts as a miss.',
      },
    },
    {
      ordinal: 10,
      pl: {
        instruction:
          'Zmień swoją pozycję: powiedz „siad" siedząc na krześle, potem kucając, potem odwrócony bokiem. Dla psa Twoja sylwetka jest częścią komendy — dopóki tego nie przećwiczycie, „siad" znaczy „siad, gdy stoisz przede mną".',
        criterion: 'Pies siada na samo słowo przy zmienionej pozycji Twojego ciała.',
      },
      en: {
        instruction:
          'Change your own posture: say “sit” while sitting on a chair, then crouching, then turned sideways. To a dog your silhouette is part of the cue — until you practise this, “sit” means “sit while you stand in front of me”.',
        criterion: 'The puppy sits to the word alone while your body position is different.',
      },
    },
  ],
};
