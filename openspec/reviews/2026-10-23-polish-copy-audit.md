# Audyt polskich tekstów aplikacji — lista do zatwierdzenia

Data: 2026-10-23. Status: propozycje, żadna poprawka nie została wdrożona.

## Zakres i sposób czytania

Przeczytano wszystkie 1021 niepustych polskich pól tekstowych w 50 plikach
`src/content/data/`: 12 ćwiczeń, 12 zestawów podpowiedzi, 12 problemów z zachowaniem,
7 procedur pielęgnacji, 6 zabaw węchowych i listę środowisk. Sprawdzono polski
katalog UI Expo, 110 wpisów katalogu Swift `Localizable.xcstrings` oraz dodatkowe
polskie teksty zapisane bezpośrednio w ekranie katalogu Expo. Porównanie wszystkich
50 plików danych Expo z odpowiednikami Swift nie wykazało różnic w zawartości JSON
w chwili sprawdzania. W repozytorium równolegle powstaje sekcja pielęgnacji, więc
przed wdrożeniem trzeba ponownie porównać aktualny tekst z cytowanym tutaj.

To audyt polskiej wersji. Angielskie teksty porównywano pomocniczo przy
niejednoznacznościach; nie jest to pełna korekta językowa wersji angielskiej.
Nie wykonywano przeglądu na urządzeniu ani oceny ułożenia tekstu na ekranie.
Nie jest to weterynaryjna weryfikacja źródeł porad.

- **J** — język: pisownia, składnia, naturalność lub precyzja sformułowania.
- **S** — styl: obecny tekst może być zrozumiały, ale propozycja jest mniej
  żargonowa, mniej oceniająca albo bardziej konkretna. To nie musi być błąd.
- **M** — sens / bezpieczeństwo: wymaga osobnego zatwierdzenia, nie wolno
  wdrożyć jako automatycznej korekty pisowni. Jeśli dotyczy wspólnej porady,
  po zatwierdzeniu należy także uzgodnić jej angielską wersję.

Cytaty obejmują pełne zmieniane zdania lub całe etykiety. Jeśli pole zawiera
więcej zdań, niecytowane zdania pozostają bez zmian. W tekście obecnym zachowano
oryginalne brzmienie i zapis, również błędy cudzysłowów. Nowe zdania dostają
docelową interpunkcję; sposób zapisu punktów list należy ujednolicić przy wdrożeniu.
Poprawnych zdań nie przepisywano tylko po to, żeby brzmiały inaczej.

## A. Interfejs i komunikaty

### 001 [J] Pisownia wyniku powtórzenia
Miejsce: `src/i18n/locales/pl.ts`, `session.miss`; Swift: ten sam klucz.

**Obecnie:** „Nie zaliczone”

**Propozycja:** „Niezaliczone”

### 002 [S] Kryterium bez metafory strzelania
Miejsce: katalogi UI, `session.criterionLabel`.

**Obecnie:** „Co liczy się jako trafienie”

**Propozycja:** „Kiedy zaliczyć powtórzenie”

### 003 [J] Nienaturalna informacja o stanie psa
Miejsce: katalogi UI, `problems.sudden`.

**Obecnie:** „Nagła zmiana zachowania u psa, któremu wcześniej wszystko było dobrze — zacznij od weterynarza. Ból potrafi wyglądać jak nieposłuszeństwo.”

**Propozycja:** „Jeśli zachowanie psa nagle się zmieniło, zacznij od wizyty u lekarza weterynarii. Ból może wyglądać jak nieposłuszeństwo.”

### 004 [J] Kolejność nie jest „zamkiem”
Miejsce: `src/features/catalogue/ExerciseList.tsx`; Swift: `catalogue.sub`.

**Obecnie:** „Wszystko jest otwarte. Kolejność to podpowiedź, nie zamek.”

**Propozycja:** „Możesz wybrać dowolne ćwiczenie. Sugerowana kolejność jest tylko wskazówką — niczego nie blokuje.”

### 005 [J] „Kroki cofnięte”
Miejsce: katalogi UI, `session.newPlaceTitle`.

**Obecnie:** „Nowe miejsce — kroki cofnięte celowo”

**Propozycja:** „Nowe miejsce — zaczynamy od łatwiejszego kroku”

### 006 [J/M] Nie odbudowujemy komendy; nie gwarantujemy tempa nauki
Miejsce: katalogi UI, `session.newPlaceBody`.

**Obecnie:** „Dla psa ta sama komenda w nowym otoczeniu to w praktyce nowe zadanie. Wracamy kawałek, żeby odbudować ją tutaj — pójdzie szybciej niż za pierwszym razem.”

**Propozycja:** „W nowym otoczeniu pies może potrzebować ponownego przećwiczenia znanej komendy. Dlatego proponujemy łatwiejszy krok, żeby pomóc mu wykonać zadanie także tutaj.”

### 007 [J] „Kroki podniesione”
Miejsce: katalogi UI, `session.easierPlaceTitle`.

**Obecnie:** „Łatwiejsze miejsce — kroki podniesione”

**Propozycja:** „Łatwiejsze miejsce — proponujemy trudniejszy krok”

### 008 [J/M] Prostsze wyjaśnienie zamiast gwarancji i „zmiennej”
Miejsce: `src/i18n/locales/pl.ts`, `session.easierPlaceBody`.

**Obecnie:** „W prostszym otoczeniu pies radzi sobie z trudniejszym krokiem. To nie jest cofnięcie się, tylko zdjęcie jednej zmiennej.”

**Propozycja:** „W spokojniejszym otoczeniu możesz spróbować trudniejszego kroku. Dostosuj poziom do tego, jak pies radzi sobie w tym miejscu.”

Swift ma nieco inną końcówkę: „To nie cofnięcie się, tylko jedna zmienna mniej.”
Docelowo proponowany tekst powinien być wspólny.

### 009 [M] „Wszędzie” jest zbyt szerokie
Miejsce: katalogi UI, `session.fullyMastered`.

**Obecnie:** „Opanowane wszędzie”

**Propozycja:** „Opanowane we wszystkich miejscach treningu”

Chodzi o zakres miejsc odnotowanych w aplikacji, nie gwarancję zachowania
w każdej możliwej sytuacji. Sprawdzić szerokość etykiety na telefonie.

### 010 [J/S] Wyjaśnienie zabaw węchowych
Miejsce: katalogi UI, `nosework.notScored`.

**Obecnie:** „Tu nie ma trafień i pudeł. Węszenie nagradza się samo, a ocenianie go kusi, żeby psu pomagać — a cała wartość jest w tym, że rozwiązuje to sam.”

**Propozycja:** „W tych zabawach nie oceniamy powtórzeń. Pozwól psu samodzielnie szukać, ale ułatw zadanie, jeśli zaczyna się frustrować.”

### 011 [J] Regulacja czego?
Miejsce: katalogi UI, `verdict.drop.explanation`.

**Obecnie:** „Za trudne. Wróć o krok — to nie porażka, tylko regulacja.”

**Propozycja:** „Ten krok jest jeszcze za trudny. Wróć do łatwiejszego — to dostosowanie poziomu, nie porażka.”

### 012 [J] Odmiana liczby poziomów
Miejsce: `Pettrainer/Resources/Localizable.xcstrings`, `catalogue.levelsCount`.

**Obecnie:** „%1$lld poziomy”

**Propozycja:** „Poziomów: %1$lld”

To mała poprawka bez nowych reguł liczby mnogiej; zachowuje placeholder.

### 013 [J] Pusty stan pielęgnacji
Miejsce: Swift, `care.untried`.

**Obecnie:** „Nic jeszcze nie próbowane”

**Propozycja:** „Nie wypróbowano jeszcze żadnego etapu”

### 014 [J] Stan postępu pielęgnacji
Miejsce: Swift, `care.furthestTried`.

**Obecnie:** „Najdalszy próbowany etap: %1$lld/%2$lld”

**Propozycja:** „Najwyższy wypróbowany etap: %1$lld/%2$lld”

To nadal zapis próby, nie akceptacji zabiegu przez psa ani opanowania etapu.

### 015 [J/S] „Trzymanie psa” jest nieprecyzyjne
Miejsce: Swift, `care.subtitle`.

**Obecnie:** „Współpraca zamiast trzymania psa”

**Propozycja:** „Współpraca bez przytrzymywania na siłę”

## B. Instrukcje ćwiczeń

Ścieżki w tej części zaczynają się od `src/content/data/exercises/`.
Numery kroków poniżej są numerami widocznymi dla użytkownika, od 1.

### 016 [M] Przywołanie: przesadna obietnica i nieodwracalność
Miejsce: `come.json`, `names.pl.description`.

**Obecnie:** „Jedyna komenda, która ratuje życie — i jedyna, którą najłatwiej zepsuć na zawsze.”

**Propozycja:** „Przywołanie może uratować psu życie, dlatego warto dbać o dobre skojarzenia z powrotem do Ciebie.”

### 017 [J] Przywołanie: „kosztować czegoś przykrego”
Miejsce: `come.json`, krok 1, `note`.

**Obecnie:** „To, że pies wraca, nie może nigdy kosztować go niczego przykrego.”

**Propozycja:** „Nie karz psa za powrót, nawet jeśli wcześniej długo nie reagował na wołanie.”

### 018 [J/M] Przywołanie: brak bezwzględnej prognozy
Miejsce: `come.json`, krok 3, `note`.

**Obecnie:** „Bez tego każde wołanie kończy się ucieczką przed ręką.”

**Propozycja:** „Dzięki temu pies ma mniejszy powód, żeby unikać ręki sięgającej do obroży.”

### 019 [J/M] Przywołanie: niezrozumiałe „dokończenie”
Miejsce: `come.json`, krok 4, `instruction`.

**Obecnie:** „Ogród na lince. Nie wołaj, jeśli nie masz jak dokończyć.”

**Propozycja:** „Ćwicz w ogrodzie z psem na długiej lince. Wołaj z takiej odległości, z jakiej pies już potrafi do Ciebie wrócić.”

### 020 [J/M] Leżenie: nieudokumentowany „najczęstszy powód”
Miejsce: `down.json`, krok 1, `note`.

**Obecnie:** „Zimne lub śliskie podłoże to najczęstszy prawdziwy powód, dla którego pies nie chce się położyć.”

**Propozycja:** „Zimne lub śliskie podłoże może zniechęcać psa do położenia się.”

### 021 [J] Leżenie: „ciągnij go” może odnosić się do psa
Miejsce: `down.json`, krok 2, drugi punkt `reps`.

**Obecnie:** „Przy podłodze ciągnij go powoli do siebie”

**Propozycja:** „Tuż nad podłogą przesuwaj smakołyk powoli w swoją stronę.”

### 022 [J/S] Leżenie: żargon i niejasne „przepychanie”
Miejsce: `down.json`, krok 7, `note`.

**Obecnie:** „Zimno i śliskość są realnym powodem — nie przepychaj, znajdź matę.”

**Propozycja:** „Jeśli podłoga jest zimna lub śliska, nie zmuszaj psa do położenia się — rozłóż matę.”

### 023 [M] Oddawanie: jeden błąd nie przekreśla nauki
Miejsce: `drop.json`, krok 2, `note`.

**Obecnie:** „Jedno nieoddanie w dziesięciu powtórzeniach psuje całą zasadę.”

**Propozycja:** „Podczas ćwiczeń zwracaj psu bezpieczną zabawkę po wymianie, żeby oddawanie nie kojarzyło mu się wyłącznie ze stratą.”

### 024 [M] Oddawanie: instrukcja i kryterium nie opisują tego samego
Miejsce: `drop.json`, krok 4, `criterion`; instrukcja każe podsunąć smakołyk.

**Obecnie:** „Pies wypuszcza ulubioną zabawkę na samo słowo.”

**Propozycja:** „Pies wypuszcza ulubioną zabawkę po komendzie i pokazaniu smakołyka.”

To najmniejsza propozycja zgodna z obecną instrukcją. Jeżeli celem ma pozostać
samo słowo, trzeba zamiast tego osobno zaplanować zmianę instrukcji.

### 025 [J/S] Nazwa ćwiczenia dotyku
Miejsce: `handling.json`, `names.pl.name`.

**Obecnie:** „obsługa”

**Propozycja:** „oswajanie z dotykiem”

ID `handling` pozostaje bez zmian.

### 026 [J] Nie weterynarz jest walką
Miejsce: `handling.json`, `tagline.pl`.

**Obecnie:** „Żeby weterynarz nie był walką”

**Propozycja:** „Spokojniejsza wizyta u weterynarza”

### 027 [J] Błędna odmiana
Miejsce: `handling.json`, krok 3, `instruction`.

**Obecnie:** „Podnieś łapę na sekundę i odłóż — powoli, każda z czterech z osobna.”

**Propozycja:** „Podnieś łapę na sekundę i powoli ją odłóż. Każdą z czterech łap ćwicz osobno.”

### 028 [J] „Porywanie łapy w locie”
Miejsce: `handling.json`, krok 3, `note`.

**Obecnie:** „Odkładaj łapę powoli, nie zrzucaj jej — pies, który porywa własną łapę w locie, uczy się napięcia przy każdym podnoszeniu.”

**Propozycja:** „Powoli opuść łapę na podłoże, zamiast nagle ją puszczać. Dzięki temu ruch będzie dla psa spokojniejszy i bardziej przewidywalny.”

### 029 [J] Narzędzie niczego nie przewiduje
Miejsce: `handling.json`, krok 5, `instruction`.

**Obecnie:** „Narzędzie ma przewidywać coś dobrego.”

**Propozycja:** „Widok narzędzia ma zapowiadać coś przyjemnego.”

### 030 [M] Smycz: jeden sukces nie utrwala zachowania na całe życie
Miejsce: `leash.json`, `names.pl.description`.

**Obecnie:** „Jedyna reguła: ciągnięcie nigdy nie może zadziałać, bo jeśli raz zadziała, uczy się na całe życie.”

**Propozycja:** „Staraj się nie iść dalej, gdy pies ciągnie, ponieważ dotarcie w ten sposób do celu może utrwalać ciągnięcie.”

### 031 [J] Smycz nie jest „ładna”; węch nie jest nagrodą
Miejsce: `leash.json`, krok 4, `note`.

**Obecnie:** „Jeśli używasz węchu jako nagrody, pies uczy się, że ładna smycz prowadzi do kolejnych miejsc do obwąchania.”

**Propozycja:** „Jeśli nagrodą jest możliwość powęszenia, pies uczy się, że chodzenie na luźnej smyczy prowadzi do ciekawych miejsc.”

### 032 [J/S] Zostaw: oceniający opis
Miejsce: `leave.json`, krok 5, `note`.

**Obecnie:** „Jeśli padnie, gdy łeb już leci w dół, pies nauczy się ignorować marudzenie.”

**Propozycja:** „Na tym etapie wypowiadaj komendę, zanim pies zacznie sięgać po smakołyk, zamiast powtarzać ją, gdy już próbuje go wziąć.”

### 033 [J] Kontakt wzrokowy: czas oczekiwania, nie czas spojrzenia
Miejsce: `look.json`, krok 3, `note`; wersja angielska potwierdza sens.

**Obecnie:** „Bywa, że pierwsze spojrzenie trwa pół minuty — czekaj.”

**Propozycja:** „Na pierwsze samodzielne spojrzenie możesz czekać nawet pół minuty.”

### 034 [J] „Rozwiązywanie gości”
Miejsce: `mat.json`, `tagline.pl`.

**Obecnie:** „Rozwiązuje gości i obiad”

**Propozycja:** „Spokojniej przy gościach i podczas posiłków”

### 035 [J] Czas pozostania na macie
Miejsce: `mat.json`, krok 3, `criterion`.

**Obecnie:** „Pies zostaje na macie przez jeden Twój krok.”

**Propozycja:** „Pies pozostaje na macie, gdy robisz krok w tył i wracasz.”

### 036 [M] Mata: kryterium wyprzedza to, co ćwiczy instrukcja
Miejsce: `mat.json`, krok 4, `criterion`; słowo pada, gdy pies już idzie.

**Obecnie:** „Pies idzie na matę po usłyszeniu komendy.”

**Propozycja:** „Pies sam rusza w stronę maty i dociera na nią, a Ty wypowiadasz komendę w trakcie jego podejścia.”

To korekta opisu obecnego zadania, nie dodanie nowego etapu wykonywania na komendę.

### 037 [J] Zostań: pies nie widzi „całą sylwetką”
Miejsce: `stay.json`, krok 4, drugi punkt `setup`.

**Obecnie:** „Pies widzi Cię całą sylwetką”

**Propozycja:** „Pies widzi całą Twoją sylwetkę.”

### 038 [J] Zostań: żargon osi
Miejsce: `stay.json`, krok 5, `instruction`.

**Obecnie:** „Dziesięć sekund przy trzech krokach. Jak się sypie — zdejmij jedną oś, nie obie.”

**Propozycja:** „Dziesięć sekund w odległości trzech kroków. Jeśli to za trudne, skróć czas albo zmniejsz odległość — zmieniaj jedną rzecz naraz.”

### 039 [J] Czekaj: centymetr dotyczy drzwi
Miejsce: `wait.json`, krok 1, `instruction`.

**Obecnie:** „Klamka w dół tylko na centymetr — i tylko wtedy, gdy pies zostaje.”

**Propozycja:** „Naciśnij klamkę, a potem uchyl drzwi na centymetr — tylko jeśli pies pozostaje w siadzie.”

### 040 [J] Czekaj: pies też jest przy podłodze
Miejsce: `wait.json`, krok 4, drugi punkt `setup`.

**Obecnie:** „Pies przy Tobie, nie przy podłodze”

**Propozycja:** „Pies stoi lub siedzi obok Ciebie.”

### 041 [J/S] Czekaj: zbędny obraz przemocy
Miejsce: `wait.json`, krok 4, `note`.

**Obecnie:** „Miska nigdy nie frunie w psi pysk w geście frustracji.”

**Propozycja:** „Jeśli czujesz frustrację, spokojnie przerwij ćwiczenie. Nie uderzaj psa ani nie strasz go miską.”

## C. Podpowiedzi „Gdy coś nie idzie”

Ścieżki: `src/content/data/mistakes/`.

### 042 [M] Przywołanie: nie stawiać diagnozy z jednego objawu
Miejsce: `come.json`, druga podpowiedź, `why`.

**Obecnie:** „Powrót kiedyś skończył się czymś nieprzyjemnym — smyczą, kąpielą, końcem spaceru, upomnieniem. To nazywa się zatrute przywołanie.”

**Propozycja:** „Pies może unikać powrotu, jeśli kojarzy mu się on z czymś nieprzyjemnym, na przykład końcem zabawy lub upomnieniem. Warto sprawdzić, jakie skojarzenia ma z obecną komendą.”

### 043 [M] Przywołanie można odbudowywać
Miejsce: `come.json`, druga podpowiedź, `fix`.

**Obecnie:** „Zmień słowo na nowe i naucz od zera. Starego nie da się naprawić, a każde kolejne użycie pogłębia problem.”

**Propozycja:** „Jeśli obecna komenda wyraźnie źle się psu kojarzy, możesz wybrać nowe słowo i nauczyć go od początku, w łatwych warunkach i z atrakcyjnymi nagrodami.”

### 044 [M] Linka do bezpieczeństwa, nie do przyciągania
Miejsce: `come.json`, trzecia podpowiedź, `fix`.

**Obecnie:** „Nie wołaj, jeśli nie masz jak dokończyć. Masz linkę — użyj jej. Nie masz — podejdź po psa bez wołania.”

**Propozycja:** „Ćwicz z psem zabezpieczonym długą linką, ale nie przyciągaj go nią do siebie. Jeśli nie reaguje, podejdź bliżej i przy kolejnej próbie ułatw zadanie.”

### 045 [M] Warczenie przy przedmiocie: bez samodzielnego testowania
Miejsce: `drop.json`, jedyna podpowiedź, `fix`.

**Obecnie:** „Przestań sięgać. Wymieniaj na coś lepszego i zawsze oddawaj przedmiot. Jeśli pies warczy przy jedzeniu lub legowisku, skonsultuj się z behawiorystą — nie karz warczenia, bo to ostrzeżenie, które chcesz zachować.”

**Propozycja:** „Nie sięgaj po przedmiot, nie goń psa i nie karz warczenia. Jeśli pies warczy, sztywnieje lub coraz intensywniej broni przedmiotów, przerwij samodzielne próby i skonsultuj się z wykwalifikowanym behawiorystą.”

Nie należy sugerować zwracania przedmiotu niebezpiecznego ani samodzielnego
ćwiczenia wymian przy narastającej obronie zasobów.

### 046 [J] Jedzenie z ziemi: niejasny jackpot
Miejsce: `leave.json`, druga podpowiedź, `why`.

**Obecnie:** „Jedzenie z ziemi nagradza się samo przy jednej porażce. Jeśli raz uda się połknąć, zignorowanie komendy właśnie dostało jackpota.”

**Propozycja:** „Zjedzenie znalezionego jedzenia jest dla psa nagrodą i może utrwalać to zachowanie, nawet jeśli wcześniej udawało mu się je zostawiać.”

### 047 [J/S] Zostaw: zarządzaj czym?
Miejsce: `leave.json`, druga podpowiedź, `fix`.

**Obecnie:** „Na ulicy trzymaj smycz krótko i pracuj od dużego dystansu. Zanim to będzie pewne, zarządzaj — nie testuj.”

**Propozycja:** „Na spacerze zachowuj odległość od znalezionego jedzenia i używaj smyczy, żeby pies nie mógł go dosięgnąć. Ćwicz z daleka, zamiast sprawdzać komendę tuż przy pokusie.”

### 048 [J] Zostań: osie nie rosną wraz z człowiekiem
Miejsce: `stay.json`, pierwsza podpowiedź, `fix`.

**Obecnie:** „Wróć do trzech sekund i jednego kroku. Rośnij tylko po jednej osi, nigdy po dwóch jednocześnie.”

**Propozycja:** „Wróć do trzech sekund i jednego kroku. Wydłużaj czas albo zwiększaj odległość — nie utrudniaj obu rzeczy jednocześnie.”

## D. Zachowanie i codzienne problemy

Ścieżki: `src/content/data/behaviour/`.

### 049 [J/M] Samotność: objawy nie są samodzielną diagnozą
Miejsce: `alone.json`, pierwsze trzy zdania `urgent.pl`.

**Obecnie:** „Sprawdź najpierw, co naprawdę widzisz. Wycie od pierwszej minuty, ślina na drzwiach, załatwianie się mimo zupełnej czystości, rany przy wyjściu — to panika separacyjna. Nie naprawisz jej ćwiczeniami z tej aplikacji: potrzebujesz weterynarza (leczenie bywa podporą pracy) i behawiorysty.”

**Propozycja:** „Wycie od początku nieobecności, silne ślinienie, załatwianie się w domu u psa nauczonego czystości lub ranienie się przy próbie wydostania mogą wskazywać na poważny problem z pozostawaniem samemu. Nie próbuj rozwiązywać go ćwiczeniami z aplikacji — skontaktuj się z lekarzem weterynarii i wykwalifikowanym behawiorystą.”

### 050 [J/M] Samotność: niezrozumiałe „zamieranie paniki”
Miejsce: `alone.json`, pierwszy punkt `avoid.pl`.

**Obecnie:** „Nie zostawiaj „żeby się wypłakał" — panika nie mija, ona zamiera i wraca silniejsza.”

**Propozycja:** „Nie zostawiaj psa w panice z założeniem, że sam się przyzwyczai. Takie doświadczenie może pogłębić lęk.”

### 051 [J] Samotność: co zaczyna narastać?
Miejsce: `alone.json`, czwarty punkt `avoid.pl`.

**Obecnie:** „Nie nagrywaj i nie podglądaj przez aplikację, żeby się denerwować — nagranie jest po to, by znać dokładną sekundę, w której zaczyna się narastanie.”

**Propozycja:** „Wykorzystaj nagranie, żeby sprawdzić, kiedy pojawiają się pierwsze oznaki niepokoju i jak pies zachowuje się podczas Twojej nieobecności.”

### 052 [J] Samotność: nienaturalna instrukcja
Miejsce: `alone.json`, drugi punkt `work.pl`.

**Obecnie:** „Sekundy, nie godziny: drzwi zamknięte, poczekaj, wejdź z powrotem nim cokolwiek zacznie się budować. Progi rosną dniami.”

**Propozycja:** „Zaczynaj od nieobecności liczonych w sekundach, nie godzinach. Wracaj, zanim pojawią się oznaki niepokoju, i wydłużaj nieobecność stopniowo, w kolejnych dniach.”

Dotyczy wyłącznie łagodnego przypadku dopuszczonego przez ostrzeżenie nad poradą.

### 053 [J] Dzwonek: emocje nie „opadają z psa”
Miejsce: `bark-door.json`, `recognizes.pl`.

**Obecnie:** „Na dzwonek albo pukanie pies eksploduje szczekaniem, leci do drzwi i nie potrafi opaść z emocji przez kilka minut po wejściu gościa.”

**Propozycja:** „Na dźwięk dzwonka lub pukania pies zaczyna intensywnie szczekać, biegnie do drzwi i nie potrafi się uspokoić przez kilka minut po wejściu gościa.”

### 054 [J/S] Dzwonek: niezrozumiały „wybuch do końca”
Miejsce: `bark-door.json`, drugi punkt `avoid.pl`.

**Obecnie:** „Nie otwieraj drzwi w szczycie burzy — każda taka wizyta to przećwiczone wykonanie wybuchu do końca.”

**Propozycja:** „Przed otwarciem drzwi oddziel bardzo pobudzonego psa bramką lub umieść go w spokojnym pokoju. Nie ćwicz powitania w szczycie pobudzenia.”

### 055 [S] Dzwonek: „cyrk” ocenia zamiast wyjaśniać
Miejsce: `bark-door.json`, trzeci punkt `avoid.pl`.

**Obecnie:** „Nie każ gościom witać się ze skaczącym, szczekającym psem — wejście do domu ma nagradzać ciszę, nie cyrk.”

**Propozycja:** „Nie proś gości, żeby witali się z psem, który skacze i szczeka. Poczekaj na spokojniejszy moment.”

### 056 [J] Okno: „playlista nagród”
Miejsce: `bark-window.json`, `professional.pl`.

**Obecnie:** „Jeśli pod szczekaniem siedzi strach — niskie ciało, podkulony ogon, cofanie się od okna — albo pies przez szybę warczy i sztywnieje z widoczną gotowością do wyjścia, to rozmowa z behawiorystą, nie playlista nagród.”

**Propozycja:** „Jeśli szczekaniu towarzyszą oznaki strachu, takie jak obniżona pozycja ciała, podkulony ogon lub cofanie się od okna, skonsultuj się z behawiorystą. Takiej konsultacji wymaga też warczenie i sztywnienie przy szybie z próbami ruszenia w stronę bodźca.”

### 057 [J] Łóżko: błędna odmiana i metafora
Miejsce: `bed.json`, trzeci punkt `avoid.pl`.

**Obecnie:** „Nie zostawiaj reguły na pół otwarta: rozmyte „może jednak tak” uczy psa prób, a nie granicy”

**Propozycja:** „Ustal jasną zasadę dotyczącą wchodzenia na łóżko i stosuj ją konsekwentnie.”

### 058 [J/M] Łóżko: kłapnięcie nie musi być ugryzieniem
Miejsce: `bed.json`, pierwszy punkt `avoid.pl`.

**Obecnie:** „Nie wypychaj, nie zrywaj kołdry, nie krzycz o szóstej rano — budzenie śpiącego psa to proszenie się o kłapnięcie”

**Propozycja:** „Nie spychaj śpiącego psa z łóżka, nie ściągaj z niego kołdry i nie budź go krzykiem. Nagłe przestraszenie może wywołać reakcję obronną, w tym próbę ugryzienia lub ugryzienie.”

Nie zamieniać wszystkich wystąpień słowa „kłapnięcie” na „ugryzienie”.

### 059 [J/M] Łóżko: inna komenda niż w katalogu i sprzeczny opis samodzielności
Miejsce: `bed.json`, pierwszy punkt `work.pl`.

**Obecnie:** „Naucz „na matę” jako osobne ćwiczenie: pies sam wybiera legowisko za nagrodę, idąc za smakołykiem, a nie za palcem”

**Propozycja:** „Skorzystaj z ćwiczenia „na miejsce”. Nagradzaj psa za samodzielne wejście na legowisko i spokojne pozostawanie na nim.”

### 060 [J] Łóżko: „tylko dopóki” zamiast warunku przejścia
Miejsce: `bed.json`, drugi punkt `work.pl`.

**Obecnie:** „Przesuwaj legowisko etapami: przy łóżku → pod drzwiami → w docelowe miejsce; etap zmieniaj tylko dopóki pies jest przy tym spokojny — przy dyskomforcie wróć o etap”

**Propozycja:** „Przesuwaj legowisko stopniowo: od miejsca przy łóżku w stronę drzwi, a potem w docelowe miejsce. Przechodź dalej tylko wtedy, gdy pies pozostaje spokojny; jeśli okazuje dyskomfort, wróć do poprzedniego ustawienia.”

### 061 [J/M] Drzwi: GPS nie jest barierą fizyczną
Miejsce: `bolting.json`, `urgent.pl`.

**Obecnie:** „Ucieczka na drogę już się zdarzyła? Najpierw zabezpiecz fizycznie — bramka, drugie drzwi, GPS — i idź do behawiorysty. Trening poniżej jest dodatkiem do zabezpieczenia, nie zamiast niego.”

**Propozycja:** „Jeśli pies już wybiegł na drogę, najpierw zabezpiecz wyjście bramką lub drugimi drzwiami i skonsultuj się z behawiorystą. Lokalizator GPS może pomóc odnaleźć psa, ale nie zapobiega ucieczce. Trening jest dodatkiem do zabezpieczeń, a nie ich zamiennikiem.”

### 062 [J] Skakanie: błąd „i o to wygrywa”
Miejsce: `jumping.json`, drugi punkt `avoid.pl`.

**Obecnie:** „Nie odwracaj się „na zasadzie ignorowania" i nie wychodź z pokoju na kwadrans — zdecydowana większość skoczków dostaje uwagę kilka sekund po wylądowaniu i o to wygrywa.”

**Propozycja:** „Samo odwrócenie się może nie wystarczyć, jeśli zaraz potem witasz psa. Poczekaj na chwilę spokoju, żeby nagradzać spokojne powitanie, a nie tylko zakończenie skoku.”

### 063 [J] Skakanie: nie każda osoba ma siadać
Miejsce: `jumping.json`, drugi punkt `work.pl`.

**Obecnie:** „Naucz „siad” na powitanie i wymagaj go od każdej osoby, która wita się z psem.”

**Propozycja:** „Naucz psa siadania przy powitaniu i poproś każdą witającą go osobę, żeby poczekała, aż usiądzie.”

### 064 [J] „Montowanie” to kalka z angielskiego
Miejsce: `mounting.json`, pierwszy punkt `now.pl`.

**Obecnie:** „Gdy pies montuje: wstań, obróć się tyłem albo cicho wyjdź — zero słowa, zero ręki na psie; przed chwilą zniknęła główna nagroda: uwaga”

**Propozycja:** „Gdy pies obejmuje Twoją nogę i zaczyna wykonywać ruchy kopulacyjne, spokojnie przerwij kontakt: odwróć się lub odejdź, bez odpychania i krzyku.”

### 065 [J] „Węchowanie” i wchodzenie ekscytacji w interakcję
Miejsce: `mounting.json`, drugi punkt `now.pl`.

**Obecnie:** „Przed powitaniem: najpierw 30 sekund spokojnego chodzenia lub węchowania, potem kontakt — ekscytacja wchodzi w interakcję niżej”

**Propozycja:** „Przed powitaniem daj psu około 30 sekund na spokojne chodzenie lub węszenie. Nawiąż kontakt, gdy będzie mniej pobudzony.”

### 066 [J/M] Zmęczenie nie daje gwarancji zachowania
Miejsce: `mounting.json`, czwarty punkt `now.pl`.

**Obecnie:** „Daj psu dzienny ruch i główkowanie (mata węchowa, nosework) — pies zmęczony głową montuje mniej niż pies zmęczony tylko nogami”

**Propozycja:** „Zadbaj o codzienny ruch, odpoczynek i spokojne zajęcia węchowe. Samo intensywne bieganie nie musi obniżać pobudzenia.”

### 067 [J] Próg i „brak hamulca” nie wyjaśniają zadania
Miejsce: `mounting.json`, czwarty punkt `work.pl`.

**Obecnie:** „Podnieś codzienny próg pobudzenia: krótsze sesje zabawy z przerwami — wspinanie bierze się zwykle z braku hamulca, nie z zuchwałości”

**Propozycja:** „Dziel zabawę na krótsze sesje i rób przerwy, zanim pies nadmiernie się pobudzi. Takie zachowanie nie jest oznaką zuchwałości.”

### 068 [J/M] Gryzienie: nie „przerywa skóry” i nie musi być poprzedzone warczeniem
Miejsce: `nipping.json`, `urgent.pl` i `professional.pl` — dwa obecne warianty.

**Obecnie, ostrzeżenie:** „Gryzienie, które przerywa skórę, albo skok bez wcześniejszego warczenia — behawiorysta. Nagłe gryzienie przy dotknięciu — najpierw weterynarz, to może być ból.”

**Obecnie, specjalista:** „Gryzienie u dorosłego psa, które przerywa skórę, albo gryzienie bez wcześniejszego ostrzegania warczeniem — behawiorysta. Nagłe gryzienie przy dotknięciu — najpierw weterynarz, to może być ból.”

**Propozycja wspólna:** „Jeśli pies ugryzł do krwi, próbuje ugryźć człowieka albo gryzienie się nasila, zadbaj o bezpieczeństwo i skontaktuj się z wykwalifikowanym behawiorystą. Nagłe gryzienie przy dotyku wymaga najpierw konsultacji z lekarzem weterynarii, ponieważ przyczyną może być ból.”

### 069 [J] Błąd pisowni i prostszy zakaz przemocy
Miejsce: `nipping.json`, drugi punkt `avoid.pl`.

**Obecnie:** „Nie piszcz i nie klapsnij — pisk udaje zdobycz, klaps podnosi pobudzenie, a gryzienie wraca mocniej.”

**Propozycja:** „Nie piszcz i nie uderzaj psa. Pisk może dodatkowo go pobudzić, a uderzenie może nasilić problem.”

### 070 [J] Gryzienie zabawki
Miejsce: `nipping.json`, pierwszy punkt `work.pl`.

**Obecnie:** „Nagradzaj gryzienie w zabawkę: przeciąganka i aport jako główne zabawy, ręce zawsze poza zasięgiem zębów.”

**Propozycja:** „Zachęcaj psa do gryzienia zabawki zamiast rąk. Podczas przeciągania lub aportowania trzymaj dłonie z dala od jego zębów.”

### 071 [M] Hałas: „późno w nocy” nie gwarantuje ciszy
Miejsce: `noise.json`, pierwszy punkt `avoid.pl`.

**Obecnie:** „Nie wychodź w noc fajerwerków na „spacer oswajający" — to praca na panicznym psie, która nic nie oswaja. Spaceruj wcześnie rano albo późno w nocy.”

**Propozycja:** „Nie zabieraj przestraszonego psa na spacer wśród fajerwerków, żeby go do nich przyzwyczaić. Zaplanuj spacery na spokojniejsze pory, zanim zaczną się wystrzały.”

### 072 [M] Hałas: nieuzasadniona liczba
Miejsce: `noise.json`, drugi punkt `now.pl`.

**Obecnie:** „Telewizor, radio albo biały szum zamykają połowę tego, co dochodzi z ulicy.”

**Propozycja:** „Spokojny dźwięk telewizora, radia lub białego szumu może częściowo maskować hałasy z zewnątrz.”

### 073 [J] Hałas: „stres załatwia pęcherz”
Miejsce: `noise.json`, trzeci punkt `now.pl`.

**Obecnie:** „Maty chłonne przy drzwiach — stres załatwia pęcherz nawet u całkowicie czystego psa.”

**Propozycja:** „Przygotuj maty chłonne, jeśli pies boi się wyjść. Pod wpływem silnego stresu może załatwić się w domu, nawet jeśli jest nauczony czystości.”

### 074 [J] Hałas: buda, koszyk i kokon mieszają się w jednym zdaniu
Miejsce: `noise.json`, pierwszy punkt `work.pl`.

**Obecnie:** „Zbuduj bezpieczną budę: koszyk z kokonem dostępny codziennie przez cały rok, żeby pies znał ją na pamięć.”

**Propozycja:** „Przygotuj spokojną kryjówkę z legowiskiem, dostępną przez cały rok, żeby pies dobrze ją znał przed burzą lub sylwestrem.”

### 075 [J] Reaktywność: niezrozumiała „utrata pracy”
Miejsce: `reactivity.json`, trzeci punkt `avoid.pl`.

**Obecnie:** „Nie pozwalaj obcym zagadywać i głaskać psa w szczycie pobudzenia — odbierasz sobie całą pracę za darmo.”

**Propozycja:** „Nie pozwalaj obcym podchodzić i głaskać psa, gdy jest silnie pobudzony. Zwiększ dystans i pomóż mu spokojnie odejść.”

### 076 [J/M] Kaganiec i skierowanie do specjalisty
Miejsce: `reactivity.json`, czwarty punkt `now.pl`.

**Obecnie:** „Kaganiec koszykowy przy pierwszym kłapnięciu zębami — bezpieczeństwo na spacerze to nie wstyd, tylko sprzęt.”

**Propozycja:** „Jeśli pies próbuje ugryźć, zadbaj o dystans i skontaktuj się z behawiorystą. Zapytaj także o dobrze dopasowany kaganiec koszykowy i spokojne przyzwyczajenie psa do jego noszenia.”

### 077 [M] Jedzenie z blatu: sytość nie gwarantuje braku zainteresowania
Miejsce: `stealing.json`, trzeci punkt `now.pl`.

**Obecnie:** „Regularne posiłki i pełna miska przed gotowaniem — syty pies traci zainteresowanie blatem.”

**Propozycja:** „Dbaj o regularne posiłki, ale nie zakładaj, że najedzony pies zrezygnuje z jedzenia na blacie. Nadal zabezpieczaj kuchnię i chowaj jedzenie.”

### 078 [J/M] Metro: za duży skok i brak możliwości swobodnego wyjścia
Miejsce: `traffic.json`, drugi punkt `now.pl`.

**Obecnie:** „Metro: dopiero gdy pies jest spokojny przy wejściu i na schodach — jedna stacja tam i z powrotem, najcichszy wagon, swobodny odwrót. Jeśli to jeszcze za dużo: dziś taksówka. Bitwy tocz na powierzchni.”

**Propozycja:** „Oswajaj psa z metrem stopniowo, zaczynając w takiej odległości od wejścia, w jakiej pozostaje spokojny. Nie przechodź od spokojnego stania na schodach od razu do przejazdu. Jeśli pies okazuje lęk, wycofaj się w spokojniejsze miejsce i wybierz inny sposób transportu.”

### 079 [J/M] Słupek nie stanowi osłony
Miejsce: `traffic.json`, trzeci punkt `now.pl`.

**Obecnie:** „Szukaj barier: zaparkowany samochód, słupek, donica między psem a ulicą — dają psychiczny dystans bez fizycznego.”

**Propozycja:** „Jeśli to bezpieczne, wybierz miejsce osłonięte od ruchu ulicznego, na przykład za zaparkowanym samochodem. Osłona nie zastępuje odległości potrzebnej psu do zachowania spokoju.”

### 080 [J] Tramwaj: czas przeszły w opisie bieżącej czynności
Miejsce: `traffic.json`, drugi punkt `work.pl`.

**Obecnie:** „Tramwaj z daleka i smakołyki spadają, zanim pies napiął ciało — wcześniej, niż Ci się wydaje konieczne.”

**Propozycja:** „Gdy w oddali pojawia się tramwaj, podawaj smakołyki, zanim pies napnie ciało.”

## E. Pielęgnacja

Ścieżki: `src/content/data/care/`.

### 081 [J] Kąpiel: „niemokra”
Miejsce: `care-bath.json`, etap 1, `setup`.

**Obecnie:** „Niemokra mata albo ręcznik w łazience albo w kabinie prysznica; smakołyki w zasięgu.”

**Propozycja:** „Sucha, nieśliska mata lub ręcznik w łazience albo kabinie prysznicowej; smakołyki w zasięgu ręki.”

### 082 [J/M] Kąpiel: otrząśnięcie nie daje pewnej diagnozy stresu
Miejsce: `care-bath.json`, etap 2, `watchFor`.

**Obecnie:** „Otrząśnięcie się suchego psa to znak stresu, nie śmiechu. Cofamy się o krok.”

**Propozycja:** „Otrząśnięcie się suchego psa może być oznaką napięcia. Obserwuj także jego postawę i w razie niepokoju wróć do łatwiejszego etapu.”

### 083 [J/M] Kąpiel: przerwanie a konieczność spłukania szamponu
Miejsce: `care-bath.json`, etap 3, `watchFor`.

**Obecnie:** „Pies zostaje do spłukania i daje się wytrzeć. Koniec wcześniej, niż plan — to sukces, nie porażka.”

**Propozycja:** „Pies spokojnie pozwala spłukać szampon i osuszyć sierść. Nie przedłużaj kąpieli ponad potrzebę; jeśli pies nie toleruje koniecznego mycia, skonsultuj bezpieczny sposób postępowania z lekarzem weterynarii.”

### 084 [J] Kontrola: „codzienne zobaczenie”
Miejsce: `care-checks.json`, `names.pl.description`.

**Obecnie:** „Codzienne zobaczenie, nie badanie: patrzysz, wąchasz, dotykasz przelotem i dzięki temu wyłapujesz zmianę wcześniej.”

**Propozycja:** „Krótka codzienna kontrola pomaga zauważyć zmiany: oglądasz psa, zwracasz uwagę na zapach i delikatnie go dotykasz. Nie zastępuje to badania u lekarza weterynarii.”

### 085 [M] Kontrola: tytuł zachęca do zaskakiwania psa
Miejsce: `care-checks.json`, etap 1, `title`.

**Obecnie:** „Podejście, którego pies się nie spodziewa”

**Propozycja:** „Spokojne podejście i krótki dotyk”

### 086 [J] Kontrola: „jasne oko” jest niejednoznaczne
Miejsce: `care-checks.json`, etap 2, `how` i `watchFor`.

**Obecnie, instrukcja:** „Unieś małżowinę i tylko spójrz — bez wsuwania czegokolwiek do środka. Osobno: czy oko otwiera się swobodnie i czy jest jasne. Potem krótkie dotknięcie opuszki.”

**Propozycja:** „Delikatnie unieś małżowinę uszną i zajrzyj do środka, niczego nie wkładając do ucha. Osobno sprawdź, czy pies swobodnie otwiera oko i czy nie widać zaczerwienienia ani wydzieliny. Na końcu krótko dotknij opuszki.”

**Obecnie, obserwacja:** „Ucho czyste i bez zapachu, oko jasne, bez wypływu, opuszki gładkie, bez pęknięć.”

**Propozycja:** „Zwróć uwagę, czy nie pojawiły się nietypowy zapach lub wydzielina z ucha, zaczerwienienie lub wydzielina z oka albo pęknięcia opuszek.”

### 087 [J] Kontrola: niespójna składnia miejsc dotyku
Miejsce: `care-checks.json`, etap 3, `how`.

**Obecnie:** „Przejedź ręką od głowy do ogona: za uszami, pachy, pachwiny, opuszki i między palce. Ręka idzie luźno — to przegląd, nie siłowanie się.”

**Propozycja:** „Delikatnie przesuwaj dłonią od głowy w stronę ogona. Osobno obejrzyj okolice za uszami, pachy, pachwiny, opuszki i przestrzenie między palcami. Nie przytrzymuj psa na siłę.”

### 088 [J] Skóra nie jest „sącząca”
Miejsce: `care-coat.json`, pierwsze zdanie `urgent.pl`.

**Obecnie:** „Ból przy dotyku, zaczerwieniona albo sącząca skóra, gorąca w dotyku skóra — weterynarz, zanim weźmiesz szczotkę.”

**Propozycja:** „Jeśli dotyk sprawia psu ból albo skóra jest zaczerwieniona, sączy się z niej wydzielina lub jest gorąca w dotyku, skontaktuj się z lekarzem weterynarii, zanim zaczniesz czesanie.”

### 089 [M] Zmiany skórne: groomer nie zastępuje weterynarza
Miejsce: `care-coat.json`, pierwsze zdanie `professional.pl`.

**Obecnie:** „Mocno zbite kołtuny, filc przy samej skórze, zmiana zapachu lub wyglądu skóry — groomer albo weterynarz.”

**Propozycja:** „Z mocno zbitymi kołtunami zwróć się do groomera. Jeśli skóra boli, zmienił się jej wygląd lub zapach albo nie wiadomo, w jakim jest stanie pod kołtunami, najpierw skonsultuj się z lekarzem weterynarii.”

### 090 [J/M] Czesanie: nie każdy ruch ma jedno znaczenie
Miejsce: `care-coat.json`, etap 2, `watchFor`.

**Obecnie:** „Skóra pod szczotką jest luźna, pies nie napina mięśni. Podnoszenie grzbietu, pies ociera się pyskiem o szczotkę — etap za trudny.”

**Propozycja:** „Pies pozostaje rozluźniony i nie unika szczotki. Jeśli napina ciało, odsuwa się lub próbuje przerwać dotyk, zakończ próbę i następnym razem ułatw zadanie.”

### 091 [J/S] Pazury: „wiór”
Miejsce: `care-nails.json`, `names.pl.description` i tytuł etapu 3.

**Obecnie, opis:** „Droga od widoku obcinacza do jednego, najcieńszego wióra. Pies uczy się, że narzędzie nic złego nie robi i że nikt nie ciągnie go za łapę.”

**Propozycja:** „Stopniowe przyzwyczajanie psa do widoku obcinacza, dotyku łapy i skrócenia samej końcówki pazura. Ćwicz bez ciągnięcia za łapę i przytrzymywania na siłę.”

**Obecnie, tytuł:** „Jeden najcieńszy wiór”

**Propozycja:** „Skrócenie samej końcówki jednego pazura”

### 092 [J/M] Pazury: planu nie robi „siła”; nie obiecujemy łagodnego leku
Miejsce: `care-nails.json`, drugie zdanie `urgent.pl`.

**Obecnie:** „Do czasu, gdy pies podaje łapę spokojnie, nie prosimy nikogo o skrócenie pazurów; jeśli są bardzo długie, plan robi weterynarz (czasem przy łagodnym leku), a nie siła.”

**Propozycja:** „Jeśli pies nie toleruje dotyku łap, nie skracaj pazurów na siłę. Gdy pazury wymagają pilnej pielęgnacji, poproś lekarza weterynarii o bezpieczny plan; o ewentualnych lekach decyduje lekarz.”

### 093 [J] Pazury: ściąganie łapy
Miejsce: `care-nails.json`, etap 2, `stop`.

**Obecnie:** „Stop, gdy pies ściąga łapę. Nie przyspieszamy „bo już prawie”.”

**Propozycja:** „Przerwij, gdy pies cofa lub wyrywa łapę. Nie kontynuuj tylko dlatego, że zostało niewiele do zrobienia.”

### 094 [M] Pazury: zbyt skrótowa instrukcja dla ciemnych pazurów
Miejsce: `care-nails.json`, etap 3, `setup`.

**Obecnie:** „Tylko jeden pazur, przy jasnych widać różową część; przy ciemnych tnie się po kawałku, aż pokaże się ciemny punkt w środku.”

**Propozycja:** „Przygotuj się do skrócenia tylko jednego pazura. Jeśli nie masz pewności, gdzie przebiega bezpieczna granica cięcia, zwłaszcza przy ciemnych pazurach, najpierw poproś lekarza weterynarii o pokazanie techniki.”

To propozycja ograniczenia ryzyka, nie nowa instrukcja medyczna.

### 095 [J] Pazury: pies „znosi łapę”
Miejsce: `care-nails.json`, etap 3, `watchFor`.

**Obecnie:** „Pies podaje łapę sam albo znosi ją spokojnie do końca. Twoje niezdecydowanie co do granicy to znak, żeby przerwać, zanim cokolwiek odetniesz.”

**Propozycja:** „Pies dobrowolnie podaje łapę lub spokojnie pozwala ją podtrzymać. Jeśli nie masz pewności, ile można bezpiecznie obciąć, przerwij przed cięciem.”

### 096 [J] Pazury: „na raz” zamiast „naraz”
Miejsce: `care-nails.json`, etap 3, ostatnie zdanie `stop`.

**Obecnie:** „Nie robimy wszystkich pazurów „na raz”.”

**Propozycja:** „Nie skracaj wszystkich pazurów naraz.”

### 097 [J] Mycie łap: pies ma móc przerwać, nie przystanąć
Miejsce: `care-paw-rinse.json`, `names.pl.description`.

**Obecnie:** „Łapy po spacerze bez szarpaniny: pies sam wchodzi na swoje miejsce, sam podaje łapę i wie, że może przystanąć.”

**Propozycja:** „Mycie łap po spacerze bez szarpaniny: pies sam wchodzi na swoje miejsce, dobrowolnie podaje łapę i może w każdej chwili przerwać zabieg.”

### 098 [J] Mycie łap: nie można „wykonać potrzeby”
Miejsce: `care-paw-rinse.json`, drugie zdanie `professional.pl`.

**Obecnie:** „Pilną potrzebę higieny wykonuje specjalista, nie dalszy trening zgody.”

**Propozycja:** „Jeśli konieczny jest pilny zabieg higieniczny, którego pies nie toleruje, skontaktuj się z lekarzem weterynarii, zamiast przedłużać trening.”

### 099 [J] Mycie łap: wilgotny ręcznik też zawiera wodę
Miejsce: `care-paw-rinse.json`, etap 2, `title`.

**Obecnie:** „Wilgotny dotyk, jeszcze bez wody”

**Propozycja:** „Dotyk wilgotnego ręcznika, jeszcze bez płukania”

### 100 [J] Mycie łap: najpoważniejsza dosłowna kalka
Miejsce: `care-paw-rinse.json`, etap 3, `how`.

**Obecnie:** „Obij łapy z brudu, wypłucz krótko letnią wodą, potem wytrzyj do sucha, także między palcami. Płać hojnie za stanie i za samo osuszanie.”

**Propozycja:** „Delikatnie usuń luźny brud z łap, krótko opłucz je letnią wodą i dokładnie osusz, także między palcami. Nagradzaj psa za spokojne stanie i osuszanie.”

### 101 [J/M] Zęby: nie każda pasta dla ludzi zawiera ksylitol
Miejsce: `care-teeth.json`, pierwsze zdanie `urgent.pl`; angielski tekst ma „some”.

**Obecnie:** „Nigdy pasta dla ludzi — zawarty w niej ksylitol jest dla psów toksyczny, a fluor i nadmiar soli szkodzą przy połykaniu.”

**Propozycja:** „Używaj wyłącznie pasty przeznaczonej dla psów. Niektóre pasty dla ludzi zawierają toksyczny dla psów ksylitol, a pozostałe również nie są przeznaczone do połykania przez psa.”

### 102 [J] Zęby: pies nie „sięga po zapach”
Miejsce: `care-teeth.json`, etap 1, `watchFor`.

**Obecnie:** „Pies sam sięga po zapach albo przynajmniej nie odsuwa się. Odwrócenie głowy — następnym razem mniejsza ilość.”

**Propozycja:** „Pies dobrowolnie obwąchuje pastę lub ją zlizuje. Jeśli odwraca głowę albo się odsuwa, nie podawaj jej na siłę.”

### 103 [J] Zęby: „mniej niż nic”
Miejsce: `care-teeth.json`, etap 1, `stop`.

**Obecnie:** „Stop, jeśli pasta smakuje psu mniej niż nic: nie używamy jej na siłę i nie sięgamy po pastę dla ludzi.”

**Propozycja:** „Przerwij, jeśli pies nie chce pasty. Nie podawaj jej na siłę ani nie zastępuj pastą dla ludzi.”

### 104 [J] Zęby: warga nie jest „otwarta”
Miejsce: `care-teeth.json`, etap 2, `watchFor`.

**Obecnie:** „Cel tego etapu: pies znosi otwartą wargę przy zamkniętych zębach i spokojnie pracuje wargami.”

**Propozycja:** „Pies spokojnie pozwala na krótkie uniesienie wargi przy zamkniętym pysku.”

### 105 [J] Zęby: dziąsła nie idą do weterynarza
Miejsce: `care-teeth.json`, etap 2, drugie zdanie `stop`.

**Obecnie:** „Dziąsła krwawiące przy dotyku idą do weterynarza.”

**Propozycja:** „Jeśli dziąsła krwawią przy dotyku, przerwij i skontaktuj się z lekarzem weterynarii.”

### 106 [M] Zęby: odwołanie do etapu, który nie wprowadza szczoteczki
Miejsce: `care-teeth.json`, etap 3, `setup`.

**Obecnie:** „Mokry palec albo szczoteczka dla psów, jeśli pies zna ją już z etapu 1.”

**Propozycja:** „Przygotuj szczoteczkę przeznaczoną dla psów. Przed szczotkowaniem osobno przyzwyczaj psa do jej widoku i delikatnego dotyku.”

W żadnym poprzednim etapie nie ma oswajania ze szczoteczką. Wdrożenie wymaga
uzgodnienia kompletności instrukcji, nie tylko usunięcia numeru etapu.

### 107 [J] Ręcznik: „odklepywanie”
Miejsce: `care-towel.json`, `names.pl.description`.

**Obecnie:** „Pies po mokrym spacerze zostaje, daje się odklepać i nie ucieka w drugi pokój.”

**Propozycja:** „Po spacerze w deszczu pies spokojnie pozwala osuszyć sierść przez delikatne przykładanie ręcznika, bez uciekania do drugiego pokoju.”

### 108 [J] Ręcznik: kąpiel, nie łazienka
Miejsce: `care-towel.json`, etap 2, `setup`.

**Obecnie:** „Ten sam ręcznik; pies mokry po deszczu albo świeżo po łazience.”

**Propozycja:** „Ten sam ręcznik; pies jest mokry po deszczu lub kąpieli.”

### 109 [J] Ręcznik: przykładanie, nie oklepywanie
Miejsce: `care-towel.json`, etap 3, `how`.

**Obecnie:** „Oklep łapy, przejdź ręcznikiem po grzbiecie i bokach, na końcu między palcami — krótko i spokojnie, z nagrodą na koniec.”

**Propozycja:** „Delikatnie przykładaj ręcznik do łap, grzbietu i boków, a na końcu osusz przestrzenie między palcami. Rób to krótko i spokojnie, bez tarcia, a na koniec nagródź psa.”

### 110 [J] Ręcznik: niezdefiniowana komenda „mokre buty”
Miejsce: `care-towel.json`, etap 3, `watchFor`; angielski tekst opisuje sytuację.

**Obecnie:** „Pies sam przychodzi na „mokre buty” albo czeka przy drzwiach. Nerwowe oblizywanie się albo wyrywanie — skracamy.”

**Propozycja:** „Po powrocie z mokrego spaceru pies sam podchodzi do ręcznika lub spokojnie czeka przy drzwiach. Jeśli nerwowo się oblizuje albo wyrywa, przerwij i następnym razem skróć osuszanie.”

## F. Zabawy węchowe i opisy otoczenia

Ścieżki: `src/content/data/nosework/` oraz `src/content/data/environments.json`.

### 111 [J/M] Kubki: nie wynika z tego pewność co do sposobu szukania
Miejsce: `cups.json`, `names.pl.description`.

**Obecnie:** „Smakołyk pod jednym z kilku kubków. Pierwsza gra, w której pies musi świadomie **wybrać**, a nie tylko znaleźć — i pierwsza, w której zobaczysz, że naprawdę używa nosa, a nie pamięci.”

**Propozycja:** „Schowaj smakołyk pod jednym z kilku kubków i pozwól psu go odnaleźć. Gdy pies nie widzi ukrywania, może szukać, kierując się zapachem.”

### 112 [J] Chowany: brak przecinka
Miejsce: `find-person.json`, poziom 1, pierwsze zdanie `how`.

**Obecnie:** „Schowaj się za framugą, tak żeby pies widział dokąd idziesz.”

**Propozycja:** „Schowaj się za framugą tak, żeby pies widział, dokąd idziesz.”

### 113 [J] Zabawka: niejasne „ta jest nią nasiąknięta”
Miejsce: `find-toy.json`, poziom 1, `setup`.

**Obecnie:** „Weź zabawkę, którą pies lubi i którą często trzyma w pysku — ta jest już nią nasiąknięta.”

**Propozycja:** „Wybierz lubianą zabawkę, którą pies często nosi w pysku i której zapach dobrze zna.”

### 114 [M] Zabawka: nos w górze nie oznacza automatycznie trudności
Miejsce: `find-toy.json`, poziom 2, `watchFor`.

**Obecnie:** „Pies systematycznie obwąchuje pokój. Chodzenie w kółko bez opuszczania nosa znaczy, że jest za trudno.”

**Propozycja:** „Pies obwąchuje pokój i szuka zabawki. Nie musi cały czas trzymać nosa przy podłodze; jeśli przestaje szukać lub narasta frustracja, wybierz łatwiejszą kryjówkę.”

### 115 [J/M] Rozsypka: można źle dobrać trudność i warunki
Miejsce: `scatter.json`, ostatnie zdanie `names.pl.description`.

**Obecnie:** „Działa od pierwszego dnia w domu, nie wymaga niczego oprócz jedzenia i nie da się jej zrobić źle.”

**Propozycja:** „Możesz zacząć od prostej wersji z niewielką ilością karmy, dobranej do możliwości psa i bezpiecznego miejsca.”

### 116 [J] Rozsypka: nie odliczamy garści
Miejsce: `scatter.json`, poziom 1, pierwsze zdanie `setup`.

**Obecnie:** „Odlicz garść karmy z dziennej porcji.”

**Propozycja:** „Odłóż niewielką część dziennej porcji karmy.”

### 117 [J] Rozsypka: trawa nie chowa zapachu
Miejsce: `scatter.json`, poziom 2, `how`.

**Obecnie:** „Ta sama garść, obszar dwa na dwa metry. Trawa chowa zapach i jedzenie, więc trudność rośnie sama.”

**Propozycja:** „Rozsyp podobną ilość karmy na obszarze około dwóch na dwa metry. Trawa zasłania kawałki jedzenia, więc pies musi bardziej polegać na węchu.”

### 118 [M] Rozsypka: chodzenie po domu nie oznacza zbyt długiego spaceru
Miejsce: `scatter.json`, poziom 3, `watchFor`.

**Obecnie:** „Pies po skończeniu kładzie się sam. Jeśli nadal chodzi po domu — skróć spacer, nie wydłużaj rozsypki.”

**Propozycja:** „Po zabawie obserwuj, czy pies się uspokaja. Jeśli nadal chodzi po domu, sprawdź jego potrzeby i poziom pobudzenia, zamiast automatycznie wydłużać zabawę.”

### 119 [M] Mata węchowa: brak gwarancji snu
Miejsce: `snuffle.json`, `tagline.pl`.

**Obecnie:** „Dziesięć minut i pies śpi”

**Propozycja:** „Spokojne zajęcie na pracę nosem”

### 120 [J/M] Mata: nie pozostawiać bez nadzoru materiałów do zjedzenia
Miejsce: `snuffle.json`, poziom 3, `how` i `watchFor`.

**Obecnie, instrukcja:** „Postaw i odejdź. Bałagan jest częścią ćwiczenia — posprzątasz potem.”

**Propozycja:** „Postaw karton i pozwól psu szukać samodzielnie, pozostając w pobliżu. Pilnuj, żeby nie połykał papieru ani kawałków kartonu.”

**Obecnie, obserwacja:** „Pies wyciąga gazety i szuka pod spodem. Jeśli od razu je gazety, wróć do ręcznika.”

**Propozycja:** „Pies wyciąga papier i szuka karmy pod spodem. Jeśli próbuje zjadać papier lub karton, przerwij i wybierz zabawę bez materiałów, które mógłby połknąć.”

Nie proponować automatycznie ręcznika psu połykającemu materiały.

### 121 [J] Ślad: niezrozumiałe „odczekane”
Miejsce: `track.json`, poziom 2, `title`.

**Obecnie:** „Dwadzieścia kroków, odczekane”

**Propozycja:** „Dwadzieścia kroków, dziesięć minut przerwy”

### 122 [J] Otoczenie: „podłożone rozproszenia”
Miejsce: `environments.json`, ósme środowisko, `names.pl`.

**Obecnie:** „Ogród z podłożonymi rozproszeniami”

**Propozycja:** „Ogród z przygotowanymi bodźcami rozpraszającymi”

### 123 [J] Otoczenie: urwany opis
Miejsce: `environments.json`, ostatnie środowisko, `names.pl`.

**Obecnie:** „Zwierzę w ucieczce — wiewiórka przez ścieżkę”

**Propozycja:** „Uciekające zwierzę — na przykład wiewiórka przebiegająca przez ścieżkę”

## G. Poprawki wspólne

### 124 [J] Polskie cudzysłowy
W wielu plikach otwierający znak jest polski, a zamykający prosty ASCII.
Przykład: `exercises/come.json`, krok 1, pierwszy punkt `reps`.

**Obecnie:** „Powiedz imię psa i „do mnie" radosnym tonem”

**Propozycja:** „Powiedz imię psa i „do mnie” radosnym tonem.”

Zakres zatwierdzenia: poprawić pary cudzysłowów w polskich polach, również
w zdaniach niewymagających zmiany słów. Nie zmieniać przy tym nazw komend,
ID, placeholderów ani angielskich tekstów. Zewnętrzny cudzysłów w tym raporcie
służy tylko oznaczeniu cytatu; częścią tekstu aplikacji jest cudzysłów wokół komendy.

### 125 [S] „Płać” i „wypłata” → jasne nazwanie nagrody
Powracająca metafora jest zrozumiała dla części osób, ale niepotrzebnie żargonowa.
Przykład: `exercises/come.json`, krok 1, `instruction`.

**Obecnie:** „Powrót ma się zawsze opłacać — wołaj wesoło, płać hojnie i pozwól psu wrócić do zabawy.”

**Propozycja:** „Powrót ma być dla psa przyjemny: zawołaj go radosnym głosem, nagródź i pozwól wrócić do zabawy.”

To zatwierdzenie kierunku stylu, nie zgoda na automatyczną zamianę wszystkich
wystąpień. Dalsze zdania z tą metaforą wymagają pokazania docelowego brzmienia
przed wdrożeniem; obecna lista nie udaje, że każdą taką zamianę już rozpisano.

### 126 [J/M] Kłapnięcie, próba ugryzienia i ugryzienie — trzy różne opisy
Nie znaleziono dosłownego zdania „pies cię kłapnie”. Są natomiast liczne
„kłapnięcia”, „kłapanie” i „kłapie”, czasem bez dopowiedzenia „zębami”.
Przykład: `behaviour/bed.json`, pierwsze zdanie `urgent.pl`.

**Obecnie:** „Jeśli pies pilnuje łóżka — warczy, kłapie lub pokazuje zęby, gdy zbliżasz się, kiedy on leży — to narastająca obrona zasobu, nie upór: nie wyciągaj go siłą i zadzwoń do behawiorysty.”

**Propozycja:** „Jeśli pies warczy, kłapie zębami w Twoją stronę lub pokazuje zęby, gdy zbliżasz się do łóżka, nie próbuj zdejmować go siłą. Skontaktuj się z wykwalifikowanym behawiorystą.”

W innych ostrzeżeniach pełne „kłapnięcie zębami” może pozostać. „Ugryzienie”
stosować tam, gdzie tekst rzeczywiście mówi o kontakcie zębów z ciałem,
a „próba ugryzienia” tam, gdzie opis dotyczy takiego zdarzenia bez ugryzienia.
Nie zakładać intencji ani kontaktu wyłącznie na podstawie słowa „kłapnięcie”.

## Co pozostaje do osobnej decyzji, a nie do cichej korekty

- Merytoryczna weryfikacja źródeł porad, m.in. o przechodzeniu przez drzwi zawsze
  przed psem, sztywnych czasach ignorowania przy powitaniach, fizjologicznych
  uzasadnieniach wrażliwości opuszek i interpretacji pojedynczych sygnałów stresu.
- Pełny audyt angielskiej wersji. W niej też występują dosłowne metafory
  i problemy sensu wspólne z polską wersją.
- Dalsze uproszczenie żargonu w całej aplikacji: „osie”, „próg”, „zarządzanie”,
  „wypłata”, „drabina środowisk”. Lista powyżej obejmuje najbardziej konkretne
  problemy, nie hurtowe przepisanie wszystkich poprawnych tekstów.
- Weryfikacja długości etykiet, łamania wierszy i dostępności na telefonie.

## Delegation Plan i bramki przed ewentualnym wdrożeniem

1. **Planner — audyt:** odczyt tekstów, porównanie kopii Expo/Swift,
   numerowana lista pełnych propozycji. Bez edycji aplikacji. Wykonane.
2. **Reviewer — niezależny przegląd:** próba uruchomienia recenzenta zakończyła
   się błędem narzędzia; niezależny przegląd NIE został wykonany. Przed wdrożeniem
   wybranych punktów trzeba uzyskać niezależną ocenę sensu, dobrostanu i zgodności
   PL/EN. Tego raportu nie wolno przedstawiać jako zaakceptowanego przez recenzenta.
3. **Użytkownik — wybór:** zatwierdza konkretne numery; można osobno zaakceptować
   J, S i M. Brak odpowiedzi nie oznacza zgody. Nie wdrażać niezatwierdzonych uwag.
4. **Planner — mały plan zmiany:** po wyborze przygotować wymagane artefakty
   OpenSpec i testowalne kryteria, bez rozszerzania zakresu na pozostałe propozycje.
5. **Build — wdrożenie:** dopiero po zatwierdzeniu planu przez `/opsx-apply`,
   które wybiera Flash Next. Zmiany w źródle i zasobach natywnych sekwencyjnie,
   bez równoległych zapisów w tych samych katalogach i plikach lokalizacji.
6. **Weryfikacja i finalny reviewer:** porównać wybrane zdania z zatwierdzonymi,
   sprawdzić parytet JSON i PL/EN, placeholdery, pobliskie testy treści/lokalizacji
   oraz prezentację na telefonie. Zachować progi 5/5, 3–4/5, 0–2/5, postęp per
   pies/ćwiczenie/otoczenie, historię offline, brak blokad i zasady dobrostanu.
   Korekta tekstów nie jest zgodą na zmianę logiki, ID, bazy ani historii.

Nie uruchamiano testów aplikacji: nie zmieniono jej kodu ani treści.
Nie uruchamiano `openspec validate <change>`: to raport audytu, nie propozycja
nowej zmiany z delta-specyfikacjami. Nie dodano ani nie zaktualizowano pamięci projektu.
