/**
 * The "why isn't this working" layer, per exercise.
 *
 * Each entry is written the way a trainer actually answers: name the symptom
 * the owner would describe, say what is really going on, then give one concrete
 * change. Not a list of rules — a diagnosis.
 *
 * Grounded in the troubleshooting research (AVSAB, ASPCA, Cornell, Best Friends
 * and certified-trainer sources) plus standard force-free practice. Anything
 * that could be a medical problem says so and sends the owner to a vet, because
 * the app must never talk someone out of a check-up.
 */

export interface Mistake {
  readonly pl: { readonly symptom: string; readonly why: string; readonly fix: string };
  readonly en: { readonly symptom: string; readonly why: string; readonly fix: string };
}

/** Keyed by exercise id. An exercise with no entry simply shows no section. */
export const MISTAKES: Readonly<Record<string, readonly Mistake[]>> = {
  name: [
    {
      pl: {
        symptom: 'Pies przestał reagować na imię',
        why: 'Najczęściej dlatego, że imię zaczęło zapowiadać koniec zabawy, kąpiel albo upomnienie. Pies nie ignoruje — nauczył się, że to się nie opłaca.',
        fix: 'Przez dwa tygodnie używaj imienia wyłącznie wtedy, gdy masz czym nagrodzić. Do upominania nie używaj imienia nigdy.',
      },
      en: {
        symptom: 'The dog stopped responding to their name',
        why: 'Usually because the name started predicting the end of fun, a bath or a telling-off. They are not ignoring you — they learned it does not pay.',
        fix: 'For two weeks use the name only when you have something to pay with. Never use it to scold.',
      },
    },
    {
      pl: {
        symptom: 'Powtarzam imię po kilka razy',
        why: 'Każde powtórzenie uczy psa, że pierwsze wywołanie nie ma znaczenia. Imię zamienia się w tło.',
        fix: 'Jedno wywołanie. Brak reakcji — odczekaj, podejdź bliżej, zmniejsz rozproszenia i spróbuj za minutę.',
      },
      en: {
        symptom: 'I end up calling the name several times',
        why: 'Each repeat teaches the dog the first call does not matter. The name becomes background noise.',
        fix: 'One call. No response means wait, move closer, lower the distractions and try again in a minute.',
      },
    },
  ],

  sit: [
    {
      pl: {
        symptom: 'Pies podskakuje do smakołyka zamiast siadać',
        why: 'Ręka jest za wysoko. Pies idzie za nosem — jeśli nos musi iść w górę ponad wygodny zasięg, ciało rusza za nim.',
        fix: 'Opuść rękę tak nisko, żeby pies tylko wyciągał szyję, bez odrywania przednich łap.',
      },
      en: {
        symptom: 'The dog jumps for the treat instead of sitting',
        why: 'Your hand is too high. The dog follows their nose — if the nose has to go above comfortable reach, the body follows.',
        fix: 'Lower your hand until they only stretch the neck, with the front feet staying down.',
      },
    },
    {
      pl: {
        symptom: 'Pies cofa się zamiast siadać',
        why: 'Ręka wędruje do tyłu nad głową psa, więc pies odsuwa się, żeby zachować równowagę.',
        fix: 'Trzymaj rękę nieruchomo, dokładnie nad nosem. Możesz stanąć tak, żeby pies miał ścianę za sobą.',
      },
      en: {
        symptom: 'The dog backs up instead of sitting',
        why: 'Your hand is drifting backwards over their head, so they step back to keep their balance.',
        fix: 'Keep your hand still, directly above the nose. Working with a wall behind the dog helps.',
      },
    },
    {
      pl: {
        symptom: 'Skanduję komendę: „siad, siad, SIAD!"',
        why: 'To najczęstszy błąd początkujących. Pies uczy się, że komenda brzmi „siadsiadSIAD" i że pierwsze wypowiedzenie nic nie znaczy.',
        fix: 'Słowo raz, potem cisza i sekunda przerwy. Jeśli pies nie siada, to znaczy, że za wcześnie na samo słowo — wróć o krok.',
      },
      en: {
        symptom: 'I chant the cue: “sit, sit, SIT!”',
        why: 'The classic beginner mistake. The dog learns the cue is “sitsitSIT” and that the first one means nothing.',
        fix: 'Say it once, then be quiet for a second. If no sit comes, the word arrived too early — go back a step.',
      },
    },
  ],

  look: [
    {
      pl: {
        symptom: 'Pies patrzy na smakołyk, nie na mnie',
        why: 'Nagroda jest zbyt widoczna i zbyt blisko twarzy, więc wygrywa z Twoimi oczami.',
        fix: 'Schowaj smakołyk w zaciśniętej dłoni i odsuń rękę w bok. Płać dopiero za spojrzenie w oczy.',
      },
      en: {
        symptom: 'The dog stares at the treat, not at me',
        why: 'The reward is too visible and too close to your face, so it outcompetes your eyes.',
        fix: 'Close the treat in your fist and move your hand out to the side. Pay only for eye contact.',
      },
    },
  ],

  down: [
    {
      pl: {
        symptom: 'Pies nie chce się położyć, choć siad zna świetnie',
        why: 'Bardzo często to podłoże, nie upór. Zimny kafelek, śliski panel albo twarda podłoga są po prostu nieprzyjemne.',
        fix: 'Spróbuj na dywanie albo na kocu. Jeśli na miękkim idzie od ręki, masz odpowiedź.',
      },
      en: {
        symptom: 'The dog will not lie down even though the sit is solid',
        why: 'Very often the surface, not stubbornness. Cold tile, slippery laminate or a hard floor are simply unpleasant.',
        fix: 'Try it on a rug or a blanket. If it works instantly on something soft, you have your answer.',
      },
    },
    {
      pl: {
        symptom: 'Pies nagle przestał się kłaść, choć wcześniej umiał',
        why: 'Nagła utrata wyuczonego zachowania bywa pierwszym objawem bólu — stawów, kręgosłupa albo brzucha. To nie jest problem treningowy.',
        fix: 'Zanim wrócisz do ćwiczeń, umów wizytę u weterynarza. Zwłaszcza jeśli pies niechętnie wchodzi po schodach albo wstaje wolniej.',
      },
      en: {
        symptom: 'The dog suddenly stopped lying down though they knew it',
        why: 'A sudden loss of a trained behaviour is often the first sign of pain — joints, spine or abdomen. This is not a training problem.',
        fix: 'See a vet before training again, especially if stairs or getting up have also become slower.',
      },
    },
    {
      pl: {
        symptom: 'Pies kuca, ale nie kładzie łokci',
        why: 'Smakołyk idzie w dół, ale nie do przodu, więc nie ma powodu, żeby klatka poszła za nim.',
        fix: 'Po dojściu do podłogi poprowadź smakołyk powoli do siebie, wzdłuż ziemi.',
      },
      en: {
        symptom: 'The dog crouches but the elbows never land',
        why: 'The treat goes down but not forward, so there is no reason for the chest to follow.',
        fix: 'Once at the floor, draw the treat slowly toward you, along the ground.',
      },
    },
  ],

  stay: [
    {
      pl: {
        symptom: 'Pies wstaje, gdy tylko się odwrócę',
        why: 'Podniosłeś dwie osie naraz — dystans i czas. Przy zmianie jednej, druga musi spaść.',
        fix: 'Wróć do trzech sekund i jednego kroku. Rośnij tylko po jednej osi, nigdy po dwóch jednocześnie.',
      },
      en: {
        symptom: 'The dog gets up the moment I turn away',
        why: 'You raised two axes at once — distance and duration. When one goes up, the other has to come down.',
        fix: 'Go back to three seconds and one step. Grow one axis at a time, never both.',
      },
    },
    {
      pl: {
        symptom: 'Pies podpełza w moją stronę',
        why: 'Nagroda przychodzi po powrocie, więc pies uczy się, że skracanie dystansu przyspiesza wypłatę.',
        fix: 'Wracaj do psa i nagradzaj go dokładnie tam, gdzie został, zanim go zwolnisz.',
      },
      en: {
        symptom: 'The dog creeps toward me',
        why: 'The reward arrives after you come back, so closing the gap looks like it speeds up payday.',
        fix: 'Walk back and pay the dog exactly where they stayed, before you release them.',
      },
    },
  ],

  come: [
    {
      pl: {
        symptom: 'W domu przychodzi, w parku kompletnie mnie nie słyszy',
        why: 'To nie nieposłuszeństwo. Pies nie generalizuje kontekstu — „do mnie" w salonie i „do mnie" w parku to dla niego dwie różne rzeczy.',
        fix: 'Wróć na długą linkę i przejdź całą drabinę środowisk od nowa. Idzie szybciej za drugim razem.',
      },
      en: {
        symptom: 'Comes indoors, completely deaf in the park',
        why: 'Not disobedience. Dogs do not generalize context — “come” in the living room and “come” in the park are two different things to them.',
        fix: 'Go back to a long line and climb the environment ladder again. It goes faster the second time.',
      },
    },
    {
      pl: {
        symptom: 'Pies przychodzi wolno albo zatrzymuje się poza zasięgiem',
        why: 'Powrót kiedyś skończył się czymś nieprzyjemnym — smyczą, kąpielą, końcem spaceru, upomnieniem. To nazywa się zatrute przywołanie.',
        fix: 'Zmień słowo na nowe i naucz od zera. Starego nie da się naprawić, a każde kolejne użycie pogłębia problem.',
      },
      en: {
        symptom: 'The dog comes slowly or stops just out of reach',
        why: 'Coming back once cost them something — the lead, a bath, the end of the walk, a telling-off. This is a poisoned recall.',
        fix: 'Pick a brand-new word and teach it from scratch. The old one cannot be repaired, and every further use deepens the damage.',
      },
    },
    {
      pl: {
        symptom: 'Wołam, pies nie reaguje, więc wołam dalej',
        why: 'Każde wywołanie bez reakcji uczy, że „do mnie" jest opcjonalne. To najszybszy sposób na zepsucie tej komendy.',
        fix: 'Nie wołaj, jeśli nie masz jak dokończyć. Masz linkę — użyj jej. Nie masz — podejdź po psa bez wołania.',
      },
      en: {
        symptom: 'I call, nothing happens, so I keep calling',
        why: 'Every unanswered call teaches that “come” is optional. It is the fastest way to ruin this cue.',
        fix: 'Do not call unless you can follow through. If you have a line, use it. If not, walk over without calling.',
      },
    },
  ],

  leave: [
    {
      pl: {
        symptom: 'Mówię „zostaw" i pies i tak bierze',
        why: 'Słowo weszło za wcześnie — zanim samo zachowanie było pewne. Komenda nic wtedy nie znaczy.',
        fix: 'Zdejmij słowo na kilka dni i wróć do płacenia za odsunięcie się. Słowo dołóż dopiero przy pięciu na pięć.',
      },
      en: {
        symptom: 'I say “leave it” and the dog takes it anyway',
        why: 'The word arrived before the behaviour was solid, so the cue means nothing yet.',
        fix: 'Drop the word for a few days and go back to paying the back-off. Add it again only at five out of five.',
      },
    },
    {
      pl: {
        symptom: 'Pies zjada rzeczy znalezione na ulicy',
        why: 'Jedzenie z ziemi nagradza się samo przy jednej porażce. Jeśli raz uda się połknąć, zignorowanie komendy właśnie dostało jackpota.',
        fix: 'Na ulicy trzymaj smycz krótko i pracuj od dużego dystansu. Zanim to będzie pewne, zarządzaj — nie testuj.',
      },
      en: {
        symptom: 'The dog eats things found on the street',
        why: 'Food on the ground is self-rewarding on a single failure. One successful swallow just paid a jackpot for ignoring you.',
        fix: 'Keep the lead short outdoors and work from a long distance. Until it is solid, manage the situation — do not test it.',
      },
    },
  ],

  drop: [
    {
      pl: {
        symptom: 'Pies ucieka z przedmiotem albo warczy, gdy sięgam',
        why: 'To sygnał pilnowania zasobów. Wyrywanie i gonienie pogłębiają problem — pies uczy się, że musi bronić tego, co ma.',
        fix: 'Przestań sięgać. Wymieniaj na coś lepszego i zawsze oddawaj przedmiot. Jeśli pies warczy przy jedzeniu lub legowisku, skonsultuj się z behawiorystą — nie karz warczenia, bo to ostrzeżenie, które chcesz zachować.',
      },
      en: {
        symptom: 'The dog runs off with the item, or growls when I reach',
        why: 'That is resource guarding. Prising and chasing make it worse — the dog learns they have to defend what they hold.',
        fix: 'Stop reaching. Trade for something better and always give the item back. If the growling involves food or a bed, see a behaviourist — and never punish a growl, it is a warning worth keeping.',
      },
    },
  ],

  wait: [
    {
      pl: {
        symptom: 'Pies wyrywa się przez drzwi, mimo że „czekaj" zna',
        why: 'Drzwi otwierają się zbyt szybko. Kryterium skoczyło z uchylenia na pełne otwarcie bez kroków pośrednich.',
        fix: 'Wróć do samego dotykania klamki. Każde wstanie zamyka drzwi — bez słowa, bez upominania.',
      },
      en: {
        symptom: 'The dog bolts through the door even though they know “wait”',
        why: 'The door opens too fast. The criterion jumped from a crack to wide open with nothing in between.',
        fix: 'Go back to just touching the handle. Any getting up closes the door — no word, no telling-off.',
      },
    },
  ],

  leash: [
    {
      pl: {
        symptom: 'Pies ciągnie przez cały spacer',
        why: 'Ciągnięcie działa: pies ciągnie, idziecie dalej, czyli zachowanie zostaje nagrodzone kilkaset razy dziennie.',
        fix: 'Zatrzymuj się przy każdym napięciu smyczy. Pierwsze spacery będą krótkie i nudne — to normalne i to działa.',
      },
      en: {
        symptom: 'The dog pulls for the whole walk',
        why: 'Pulling works: the dog pulls, you keep walking, and the behaviour gets paid a few hundred times a day.',
        fix: 'Stop every time the lead goes tight. The first walks will be short and boring — that is normal and it works.',
      },
    },
    {
      pl: {
        symptom: 'Pies ciągnie tylko na początku spaceru',
        why: 'Początek to szczyt pobudzenia. To nie jest problem treningowy, tylko stan psa.',
        fix: 'Zacznij od minuty wąchania przy domu, zanim ruszycie. Obniżenie pobudzenia robi więcej niż kolejne powtórzenia.',
      },
      en: {
        symptom: 'The dog only pulls at the start of the walk',
        why: 'The start is peak arousal. This is not a training gap, it is the dog’s state.',
        fix: 'Spend a minute sniffing near the house before you set off. Lowering arousal does more than more repetitions.',
      },
    },
  ],

  mat: [
    {
      pl: {
        symptom: 'Pies wchodzi na matę i od razu z niej schodzi',
        why: 'Nagroda przychodzi za wejście, więc pies odkrywa pętlę: wejść, zejść, wejść znowu.',
        fix: 'Nagradzaj na macie, kilka razy pod rząd, gdy pies już leży. Płać za pozostanie, nie za wejście.',
      },
      en: {
        symptom: 'The dog steps onto the mat and straight back off',
        why: 'The reward comes for stepping on, so the dog finds the loop: on, off, on again.',
        fix: 'Pay on the mat, several times in a row, while they are lying down. Pay for staying, not for arriving.',
      },
    },
  ],

  handling: [
    {
      pl: {
        symptom: 'Pies wyrywa łapę, gdy ją podnoszę',
        why: 'Dotyk trwa dłużej, niż pies jest gotów znieść. Przytrzymywanie uczy, że z rąk trzeba się wyrywać.',
        fix: 'Skróć dotyk do pół sekundy i puszczaj, zanim pies sam zabierze łapę. Puszczanie jest tu nagrodą.',
      },
      en: {
        symptom: 'The dog pulls their paw away when I lift it',
        why: 'The touch lasts longer than they can tolerate. Holding on teaches that hands are something to escape.',
        fix: 'Shorten the touch to half a second and let go before they pull away. Letting go is the reward here.',
      },
    },
    {
      pl: {
        symptom: 'Pies ucieka na widok obcinaczki',
        why: 'Narzędzie zapowiada coś nieprzyjemnego, bo pierwszy kontakt wiązał się z obcinaniem.',
        fix: 'Przez tydzień pokazuj obcinaczkę i od razu nagradzaj, nie obcinając nic. Narzędzie musi najpierw zacząć zapowiadać smakołyk.',
      },
      en: {
        symptom: 'The dog leaves the room when the clippers appear',
        why: 'The tool predicts something unpleasant, because the first contact involved cutting.',
        fix: 'For a week, show the clippers and pay immediately without cutting anything. The tool has to start predicting treats first.',
      },
    },
  ],
};

/** Mistakes for one exercise, or an empty list. */
export function mistakesFor(exerciseId: string): readonly Mistake[] {
  return MISTAKES[exerciseId] ?? [];
}
