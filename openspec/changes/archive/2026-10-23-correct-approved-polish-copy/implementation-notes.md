# Implementation ledger — audit IDs 001–126 against the live tree

Built mechanically on 2026-10-23 across **162 live-copy files**: JS content canon
`src/content/data/`, native bundle `Pettrainer/Resources/Content/`, both UI catalogues
(`src/i18n/locales/*.ts`, `Pettrainer/Resources/Localizable.xcstrings` with escapes decoded), the
JS components that hold inline copy (`src/features/**/*.tsx`, `src/ui/*.tsx`) and Swift sources.
Method per row: the quoted `Obecnie` and `Propozycja` sentences are normalised (quote marks,
backslashes, whitespace); sentences of 20+ characters are probed by their first 60 characters,
shorter ones by their whole normalised text, case-sensitively.

## A method bug in the first pass, corrected here

The first run required a probe of at least 14 characters, which silently dropped short audited
sentences. Row 001 (`Nie zaliczone`, 13 characters) was reported as „wording gone” while
`session.miss` still ships `Nie zaliczone` in **both** catalogues. Removing the floor — and
widening the corpus after row 004 turned out to be inline in
`src/features/catalogue/ExerciseList.tsx` — moved 5 rows from CONFLICT/PAUSED into NOT APPLIED:
**103/23 → 108/18**. The superseded figure is named because `add-hygiene-care-section/notes.md`
quoted it.

## Matcher soundness, verified rather than assumed

- **Positive control**: an earlier fix is detectable (`Kalec` absent, `Kaganiec` present in
  `reactivity.json`) → applied work is found by the probe.
- **Literal controls**: 096’s audited sentence is still at `care-nails.json` line 99 in both
  runtimes, and `ściąga łapę` (093), `wiór` (091), `napina mięśni` (090), `sącząca` (088),
  `może przystanąć` (097), `Wilgotny dotyk` (099) survive verbatim in shipped JSON.
- **Negative control**: no `Propozycja` probe matches anywhere → 0 IDs adopted verbatim.
- **Apparent one-tree divergence, dismissed**: 012, 014 and 015 name native-only keys
  (`catalogue.levelsCount`, `care.furthestTried`, `care.subtitle`), so the JS catalogue never
  carried that string; no row is a fix stranded in the runtime being retired.

## State summary

| State | Rows | Meaning |
| --- | --- | --- |
| APPLIED VERBATIM | 0 | the approved sentence is in the product |
| REWORDED (conflict/paused) | 18 | the audited sentence is gone, but replaced by other wording |
| **NOT APPLIED** | **108** | the audited sentence is still shipped |

Care block 081–110: 13 still not applied (082, 084, 086, 088, 089, 090, 091, 093, 096, 097, 098, 099, 109); 17 reworded by the hygiene welfare review.

## Why „we already fixed the Polish” and „0 of 126 applied” are both true

The earlier Polish round (commit `324b81b`, TestFlight build 5) corrected real defects: `Kalec` →
`Kaganiec`, `adresatka` → `adresówka`, `absencja` → `brak gryzienia`, `rozjedzie` → `rozjeżdża`,
leftover `monting`/`wspinalnie`, the gender-safe prerequisite hint, the `Kroków: %1$lld` plural
and several calques. **None of those strings appears in this audit** (`grep -c` in the audit for
`Kalec`, `adresatka`, `absencja`, `rozjedzie`, `monting`, `wspinalnie`, `prereqHint`: 0 each).
That work came from a different review trail and discharges none of these 126 rows. All 18
REWORDED rows are from today’s hygiene review (V-1…V-6).

## Consequences for the approval gate

The recorded approval was of *these* proposals. So:

1. 108 rows must still be implemented as approved, and
2. for each of the 18 REWORDED rows someone must decide: keep the hygiene wording and amend the
   audit record, or restore the approved wording where it is welfare-equivalent.

This change cannot be completed, archived, or described as „approved copy shipped” before both.
Build 5 already ships copy from a tree where these corrections had not landed: that is an
approval-trail fact, not a regression introduced by the care work.

## Ledger

| ID | State | Location in the audit | Audited subject |
| --- | --- | --- | --- |
| 001 | NOT APPLIED | ``src/i18n/locales/pl.ts`, `session.miss`; Swift: ten sam klucz.` | [J] Pisownia wyniku powtórzenia |
| 002 | NOT APPLIED | `katalogi UI, `session.criterionLabel`.` | [S] Kryterium bez metafory strzelania |
| 003 | NOT APPLIED | `katalogi UI, `problems.sudden`.` | [J] Nienaturalna informacja o stanie psa |
| 004 | NOT APPLIED | ``src/features/catalogue/ExerciseList.tsx`; Swift: `catalogue.sub`.` | [J] Kolejność nie jest „zamkiem” |
| 005 | NOT APPLIED | `katalogi UI, `session.newPlaceTitle`.` | [J] „Kroki cofnięte” |
| 006 | NOT APPLIED | `katalogi UI, `session.newPlaceBody`.` | [J/M] Nie odbudowujemy komendy; nie gwarantujemy tempa nauki |
| 007 | NOT APPLIED | `katalogi UI, `session.easierPlaceTitle`.` | [J] „Kroki podniesione” |
| 008 | NOT APPLIED | ``src/i18n/locales/pl.ts`, `session.easierPlaceBody`.` | [J/M] Prostsze wyjaśnienie zamiast gwarancji i „zmiennej” |
| 009 | NOT APPLIED | `katalogi UI, `session.fullyMastered`.` | [M] „Wszędzie” jest zbyt szerokie |
| 010 | NOT APPLIED | `katalogi UI, `nosework.notScored`.` | [J/S] Wyjaśnienie zabaw węchowych |
| 011 | NOT APPLIED | `katalogi UI, `verdict.drop.explanation`.` | [J] Regulacja czego? |
| 012 | NOT APPLIED | ``Pettrainer/Resources/Localizable.xcstrings`, `catalogue.levelsCount`.` | [J] Odmiana liczby poziomów |
| 013 | CONFLICT/PAUSED | `Swift, `care.untried`.` | [J] Pusty stan pielęgnacji |
| 014 | NOT APPLIED | `Swift, `care.furthestTried`.` | [J] Stan postępu pielęgnacji |
| 015 | NOT APPLIED | `Swift, `care.subtitle`.` | [J/S] „Trzymanie psa” jest nieprecyzyjne |
| 016 | NOT APPLIED | ``come.json`, `names.pl.description`.` | [M] Przywołanie: przesadna obietnica i nieodwracalność |
| 017 | NOT APPLIED | ``come.json`, krok 1, `note`.` | [J] Przywołanie: „kosztować czegoś przykrego” |
| 018 | NOT APPLIED | ``come.json`, krok 3, `note`.` | [J/M] Przywołanie: brak bezwzględnej prognozy |
| 019 | NOT APPLIED | ``come.json`, krok 4, `instruction`.` | [J/M] Przywołanie: niezrozumiałe „dokończenie” |
| 020 | NOT APPLIED | ``down.json`, krok 1, `note`.` | [J/M] Leżenie: nieudokumentowany „najczęstszy powód” |
| 021 | NOT APPLIED | ``down.json`, krok 2, drugi punkt `reps`.` | [J] Leżenie: „ciągnij go” może odnosić się do psa |
| 022 | NOT APPLIED | ``down.json`, krok 7, `note`.` | [J/S] Leżenie: żargon i niejasne „przepychanie” |
| 023 | NOT APPLIED | ``drop.json`, krok 2, `note`.` | [M] Oddawanie: jeden błąd nie przekreśla nauki |
| 024 | NOT APPLIED | ``drop.json`, krok 4, `criterion`; instrukcja każe podsunąć smakołyk.` | [M] Oddawanie: instrukcja i kryterium nie opisują tego samego |
| 025 | NOT APPLIED | ``handling.json`, `names.pl.name`.` | [J/S] Nazwa ćwiczenia dotyku |
| 026 | NOT APPLIED | ``handling.json`, `tagline.pl`.` | [J] Nie weterynarz jest walką |
| 027 | NOT APPLIED | ``handling.json`, krok 3, `instruction`.` | [J] Błędna odmiana |
| 028 | NOT APPLIED | ``handling.json`, krok 3, `note`.` | [J] „Porywanie łapy w locie” |
| 029 | NOT APPLIED | ``handling.json`, krok 5, `instruction`.` | [J] Narzędzie niczego nie przewiduje |
| 030 | NOT APPLIED | ``leash.json`, `names.pl.description`.` | [M] Smycz: jeden sukces nie utrwala zachowania na całe życie |
| 031 | NOT APPLIED | ``leash.json`, krok 4, `note`.` | [J] Smycz nie jest „ładna”; węch nie jest nagrodą |
| 032 | NOT APPLIED | ``leave.json`, krok 5, `note`.` | [J/S] Zostaw: oceniający opis |
| 033 | NOT APPLIED | ``look.json`, krok 3, `note`; wersja angielska potwierdza sens.` | [J] Kontakt wzrokowy: czas oczekiwania, nie czas spojrzenia |
| 034 | NOT APPLIED | ``mat.json`, `tagline.pl`.` | [J] „Rozwiązywanie gości” |
| 035 | NOT APPLIED | ``mat.json`, krok 3, `criterion`.` | [J] Czas pozostania na macie |
| 036 | NOT APPLIED | ``mat.json`, krok 4, `criterion`; słowo pada, gdy pies już idzie.` | [M] Mata: kryterium wyprzedza to, co ćwiczy instrukcja |
| 037 | NOT APPLIED | ``stay.json`, krok 4, drugi punkt `setup`.` | [J] Zostań: pies nie widzi „całą sylwetką” |
| 038 | NOT APPLIED | ``stay.json`, krok 5, `instruction`.` | [J] Zostań: żargon osi |
| 039 | NOT APPLIED | ``wait.json`, krok 1, `instruction`.` | [J] Czekaj: centymetr dotyczy drzwi |
| 040 | NOT APPLIED | ``wait.json`, krok 4, drugi punkt `setup`.` | [J] Czekaj: pies też jest przy podłodze |
| 041 | NOT APPLIED | ``wait.json`, krok 4, `note`.` | [J/S] Czekaj: zbędny obraz przemocy |
| 042 | NOT APPLIED | ``come.json`, druga podpowiedź, `why`.` | [M] Przywołanie: nie stawiać diagnozy z jednego objawu |
| 043 | NOT APPLIED | ``come.json`, druga podpowiedź, `fix`.` | [M] Przywołanie można odbudowywać |
| 044 | NOT APPLIED | ``come.json`, trzecia podpowiedź, `fix`.` | [M] Linka do bezpieczeństwa, nie do przyciągania |
| 045 | NOT APPLIED | ``drop.json`, jedyna podpowiedź, `fix`.` | [M] Warczenie przy przedmiocie: bez samodzielnego testowania |
| 046 | NOT APPLIED | ``leave.json`, druga podpowiedź, `why`.` | [J] Jedzenie z ziemi: niejasny jackpot |
| 047 | NOT APPLIED | ``leave.json`, druga podpowiedź, `fix`.` | [J/S] Zostaw: zarządzaj czym? |
| 048 | NOT APPLIED | ``stay.json`, pierwsza podpowiedź, `fix`.` | [J] Zostań: osie nie rosną wraz z człowiekiem |
| 049 | NOT APPLIED | ``alone.json`, pierwsze trzy zdania `urgent.pl`.` | [J/M] Samotność: objawy nie są samodzielną diagnozą |
| 050 | NOT APPLIED | ``alone.json`, pierwszy punkt `avoid.pl`.` | [J/M] Samotność: niezrozumiałe „zamieranie paniki” |
| 051 | NOT APPLIED | ``alone.json`, czwarty punkt `avoid.pl`.` | [J] Samotność: co zaczyna narastać? |
| 052 | NOT APPLIED | ``alone.json`, drugi punkt `work.pl`.` | [J] Samotność: nienaturalna instrukcja |
| 053 | NOT APPLIED | ``bark-door.json`, `recognizes.pl`.` | [J] Dzwonek: emocje nie „opadają z psa” |
| 054 | NOT APPLIED | ``bark-door.json`, drugi punkt `avoid.pl`.` | [J/S] Dzwonek: niezrozumiały „wybuch do końca” |
| 055 | NOT APPLIED | ``bark-door.json`, trzeci punkt `avoid.pl`.` | [S] Dzwonek: „cyrk” ocenia zamiast wyjaśniać |
| 056 | NOT APPLIED | ``bark-window.json`, `professional.pl`.` | [J] Okno: „playlista nagród” |
| 057 | NOT APPLIED | ``bed.json`, trzeci punkt `avoid.pl`.` | [J] Łóżko: błędna odmiana i metafora |
| 058 | NOT APPLIED | ``bed.json`, pierwszy punkt `avoid.pl`.` | [J/M] Łóżko: kłapnięcie nie musi być ugryzieniem |
| 059 | NOT APPLIED | ``bed.json`, pierwszy punkt `work.pl`.` | [J/M] Łóżko: inna komenda niż w katalogu i sprzeczny opis samodzielności |
| 060 | NOT APPLIED | ``bed.json`, drugi punkt `work.pl`.` | [J] Łóżko: „tylko dopóki” zamiast warunku przejścia |
| 061 | NOT APPLIED | ``bolting.json`, `urgent.pl`.` | [J/M] Drzwi: GPS nie jest barierą fizyczną |
| 062 | NOT APPLIED | ``jumping.json`, drugi punkt `avoid.pl`.` | [J] Skakanie: błąd „i o to wygrywa” |
| 063 | NOT APPLIED | ``jumping.json`, drugi punkt `work.pl`.` | [J] Skakanie: nie każda osoba ma siadać |
| 064 | NOT APPLIED | ``mounting.json`, pierwszy punkt `now.pl`.` | [J] „Montowanie” to kalka z angielskiego |
| 065 | NOT APPLIED | ``mounting.json`, drugi punkt `now.pl`.` | [J] „Węchowanie” i wchodzenie ekscytacji w interakcję |
| 066 | NOT APPLIED | ``mounting.json`, czwarty punkt `now.pl`.` | [J/M] Zmęczenie nie daje gwarancji zachowania |
| 067 | NOT APPLIED | ``mounting.json`, czwarty punkt `work.pl`.` | [J] Próg i „brak hamulca” nie wyjaśniają zadania |
| 068 | NOT APPLIED | ``nipping.json`, `urgent.pl` i `professional.pl` — dwa obecne warianty.` | [J/M] Gryzienie: nie „przerywa skóry” i nie musi być poprzedzone warczeniem |
| 069 | NOT APPLIED | ``nipping.json`, drugi punkt `avoid.pl`.` | [J] Błąd pisowni i prostszy zakaz przemocy |
| 070 | NOT APPLIED | ``nipping.json`, pierwszy punkt `work.pl`.` | [J] Gryzienie zabawki |
| 071 | NOT APPLIED | ``noise.json`, pierwszy punkt `avoid.pl`.` | [M] Hałas: „późno w nocy” nie gwarantuje ciszy |
| 072 | NOT APPLIED | ``noise.json`, drugi punkt `now.pl`.` | [M] Hałas: nieuzasadniona liczba |
| 073 | NOT APPLIED | ``noise.json`, trzeci punkt `now.pl`.` | [J] Hałas: „stres załatwia pęcherz” |
| 074 | NOT APPLIED | ``noise.json`, pierwszy punkt `work.pl`.` | [J] Hałas: buda, koszyk i kokon mieszają się w jednym zdaniu |
| 075 | NOT APPLIED | ``reactivity.json`, trzeci punkt `avoid.pl`.` | [J] Reaktywność: niezrozumiała „utrata pracy” |
| 076 | NOT APPLIED | ``reactivity.json`, czwarty punkt `now.pl`.` | [J/M] Kaganiec i skierowanie do specjalisty |
| 077 | NOT APPLIED | ``stealing.json`, trzeci punkt `now.pl`.` | [M] Jedzenie z blatu: sytość nie gwarantuje braku zainteresowania |
| 078 | NOT APPLIED | ``traffic.json`, drugi punkt `now.pl`.` | [J/M] Metro: za duży skok i brak możliwości swobodnego wyjścia |
| 079 | NOT APPLIED | ``traffic.json`, trzeci punkt `now.pl`.` | [J/M] Słupek nie stanowi osłony |
| 080 | NOT APPLIED | ``traffic.json`, drugi punkt `work.pl`.` | [J] Tramwaj: czas przeszły w opisie bieżącej czynności |
| 081 | CONFLICT/PAUSED | ``care-bath.json`, etap 1, `setup`.` | [J] Kąpiel: „niemokra” |
| 082 | NOT APPLIED | ``care-bath.json`, etap 2, `watchFor`.` | [J/M] Kąpiel: otrząśnięcie nie daje pewnej diagnozy stresu |
| 083 | CONFLICT/PAUSED | ``care-bath.json`, etap 3, `watchFor`.` | [J/M] Kąpiel: przerwanie a konieczność spłukania szamponu |
| 084 | NOT APPLIED | ``care-checks.json`, `names.pl.description`.` | [J] Kontrola: „codzienne zobaczenie” |
| 085 | CONFLICT/PAUSED | ``care-checks.json`, etap 1, `title`.` | [M] Kontrola: tytuł zachęca do zaskakiwania psa |
| 086 | NOT APPLIED | ``care-checks.json`, etap 2, `how` i `watchFor`.` | [J] Kontrola: „jasne oko” jest niejednoznaczne |
| 087 | CONFLICT/PAUSED | ``care-checks.json`, etap 3, `how`.` | [J] Kontrola: niespójna składnia miejsc dotyku |
| 088 | NOT APPLIED | ``care-coat.json`, pierwsze zdanie `urgent.pl`.` | [J] Skóra nie jest „sącząca” |
| 089 | NOT APPLIED | ``care-coat.json`, pierwsze zdanie `professional.pl`.` | [M] Zmiany skórne: groomer nie zastępuje weterynarza |
| 090 | NOT APPLIED | ``care-coat.json`, etap 2, `watchFor`.` | [J/M] Czesanie: nie każdy ruch ma jedno znaczenie |
| 091 | NOT APPLIED | ``care-nails.json`, `names.pl.description` i tytuł etapu 3.` | [J/S] Pazury: „wiór” |
| 092 | CONFLICT/PAUSED | ``care-nails.json`, drugie zdanie `urgent.pl`.` | [J/M] Pazury: planu nie robi „siła”; nie obiecujemy łagodnego leku |
| 093 | NOT APPLIED | ``care-nails.json`, etap 2, `stop`.` | [J] Pazury: ściąganie łapy |
| 094 | CONFLICT/PAUSED | ``care-nails.json`, etap 3, `setup`.` | [M] Pazury: zbyt skrótowa instrukcja dla ciemnych pazurów |
| 095 | CONFLICT/PAUSED | ``care-nails.json`, etap 3, `watchFor`.` | [J] Pazury: pies „znosi łapę” |
| 096 | NOT APPLIED | ``care-nails.json`, etap 3, ostatnie zdanie `stop`.` | [J] Pazury: „na raz” zamiast „naraz” |
| 097 | NOT APPLIED | ``care-paw-rinse.json`, `names.pl.description`.` | [J] Mycie łap: pies ma móc przerwać, nie przystanąć |
| 098 | NOT APPLIED | ``care-paw-rinse.json`, drugie zdanie `professional.pl`.` | [J] Mycie łap: nie można „wykonać potrzeby” |
| 099 | NOT APPLIED | ``care-paw-rinse.json`, etap 2, `title`.` | [J] Mycie łap: wilgotny ręcznik też zawiera wodę |
| 100 | CONFLICT/PAUSED | ``care-paw-rinse.json`, etap 3, `how`.` | [J] Mycie łap: najpoważniejsza dosłowna kalka |
| 101 | CONFLICT/PAUSED | ``care-teeth.json`, pierwsze zdanie `urgent.pl`; angielski tekst ma „some”.` | [J/M] Zęby: nie każda pasta dla ludzi zawiera ksylitol |
| 102 | CONFLICT/PAUSED | ``care-teeth.json`, etap 1, `watchFor`.` | [J] Zęby: pies nie „sięga po zapach” |
| 103 | CONFLICT/PAUSED | ``care-teeth.json`, etap 1, `stop`.` | [J] Zęby: „mniej niż nic” |
| 104 | CONFLICT/PAUSED | ``care-teeth.json`, etap 2, `watchFor`.` | [J] Zęby: warga nie jest „otwarta” |
| 105 | CONFLICT/PAUSED | ``care-teeth.json`, etap 2, drugie zdanie `stop`.` | [J] Zęby: dziąsła nie idą do weterynarza |
| 106 | CONFLICT/PAUSED | ``care-teeth.json`, etap 3, `setup`.` | [M] Zęby: odwołanie do etapu, który nie wprowadza szczoteczki |
| 107 | CONFLICT/PAUSED | ``care-towel.json`, `names.pl.description`.` | [J] Ręcznik: „odklepywanie” |
| 108 | CONFLICT/PAUSED | ``care-towel.json`, etap 2, `setup`.` | [J] Ręcznik: kąpiel, nie łazienka |
| 109 | NOT APPLIED | ``care-towel.json`, etap 3, `how`.` | [J] Ręcznik: przykładanie, nie oklepywanie |
| 110 | CONFLICT/PAUSED | ``care-towel.json`, etap 3, `watchFor`; angielski tekst opisuje sytuację.` | [J] Ręcznik: niezdefiniowana komenda „mokre buty” |
| 111 | NOT APPLIED | ``cups.json`, `names.pl.description`.` | [J/M] Kubki: nie wynika z tego pewność co do sposobu szukania |
| 112 | NOT APPLIED | ``find-person.json`, poziom 1, pierwsze zdanie `how`.` | [J] Chowany: brak przecinka |
| 113 | NOT APPLIED | ``find-toy.json`, poziom 1, `setup`.` | [J] Zabawka: niejasne „ta jest nią nasiąknięta” |
| 114 | NOT APPLIED | ``find-toy.json`, poziom 2, `watchFor`.` | [M] Zabawka: nos w górze nie oznacza automatycznie trudności |
| 115 | NOT APPLIED | ``scatter.json`, ostatnie zdanie `names.pl.description`.` | [J/M] Rozsypka: można źle dobrać trudność i warunki |
| 116 | NOT APPLIED | ``scatter.json`, poziom 1, pierwsze zdanie `setup`.` | [J] Rozsypka: nie odliczamy garści |
| 117 | NOT APPLIED | ``scatter.json`, poziom 2, `how`.` | [J] Rozsypka: trawa nie chowa zapachu |
| 118 | NOT APPLIED | ``scatter.json`, poziom 3, `watchFor`.` | [M] Rozsypka: chodzenie po domu nie oznacza zbyt długiego spaceru |
| 119 | NOT APPLIED | ``snuffle.json`, `tagline.pl`.` | [M] Mata węchowa: brak gwarancji snu |
| 120 | NOT APPLIED | ``snuffle.json`, poziom 3, `how` i `watchFor`.` | [J/M] Mata: nie pozostawiać bez nadzoru materiałów do zjedzenia |
| 121 | NOT APPLIED | ``track.json`, poziom 2, `title`.` | [J] Ślad: niezrozumiałe „odczekane” |
| 122 | NOT APPLIED | ``environments.json`, ósme środowisko, `names.pl`.` | [J] Otoczenie: „podłożone rozproszenia” |
| 123 | NOT APPLIED | ``environments.json`, ostatnie środowisko, `names.pl`.` | [J] Otoczenie: urwany opis |
| 124 | NOT APPLIED | `—` | [J] Polskie cudzysłowy |
| 125 | NOT APPLIED | `—` | [S] „Płać” i „wypłata” → jasne nazwanie nagrody |
| 126 | NOT APPLIED | `—` | [J/M] Kłapnięcie, próba ugryzienia i ugryzienie — trzy różne opisy |

## Care block detail (081–110) — the overlap with `add-hygiene-care-section`

| ID | State | What the hygiene change did instead |
| --- | --- | --- |
| 081 | CONFLICT/PAUSED | V-3: the mat is „mata antypoślizgowa” — same safety rule, different noun. |
| 082 | NOT APPLIED | audited wording untouched |
| 083 | CONFLICT/PAUSED | V-3: `watchFor` rewritten — withdrawal turns the water off; no endurance framing. |
| 084 | NOT APPLIED | audited wording untouched |
| 085 | CONFLICT/PAUSED | V-4: stage retitled „Przewidywalne podejście, które pies może odrzucić”. |
| 086 | NOT APPLIED | audited wording untouched |
| 087 | CONFLICT/PAUSED | V-4: final stage narrowed to a look-over; the roaming hand sweep was removed. |
| 088 | NOT APPLIED | audited wording untouched |
| 089 | NOT APPLIED | audited wording untouched |
| 090 | NOT APPLIED | audited wording untouched |
| 091 | NOT APPLIED | audited wording untouched |
| 092 | CONFLICT/PAUSED | V-1: keeps „plan ustala weterynarz”, drops „a nie siła”, adds „nikogo nie prosimy”. |
| 093 | NOT APPLIED | audited wording untouched |
| 094 | CONFLICT/PAUSED | V-1: invented dark-dot recipe deleted; technique and limit routed to the veterinarian. |
| 095 | CONFLICT/PAUSED | V-1/V-3: criterion rewritten around voluntary offering and the owner’s own doubt. |
| 096 | NOT APPLIED | audited wording untouched |
| 097 | NOT APPLIED | audited wording untouched |
| 098 | NOT APPLIED | audited wording untouched |
| 099 | NOT APPLIED | audited wording untouched |
| 100 | CONFLICT/PAUSED | V-3: literal calque replaced by „delikatnie zdejmij brud ręcznikiem”. |
| 101 | CONFLICT/PAUSED | V-5: claim narrowed to „część z nich zawiera ksylitol” (the verified fact). |
| 102 | CONFLICT/PAUSED | V-6: „sam podchodzi do pasty” instead of „sięga po zapach”. |
| 103 | CONFLICT/PAUSED | V-6: „nie chce zlizać pasty nawet za nagrodę” instead of „smakuje psu mniej niż nic”. |
| 104 | CONFLICT/PAUSED | V-6: „lekko uniesioną wargę” instead of „otwarta warga”. |
| 105 | CONFLICT/PAUSED | V-6: „zadzwoń do weterynarza” instead of „idą do weterynarza”. |
| 106 | CONFLICT/PAUSED | V-5: the brush is its own earlier meeting and explicitly not a gate for the stage. |
| 107 | CONFLICT/PAUSED | V-2/V-6: „pozwala delikatnie osuszyć sierść” instead of „odklepać”. |
| 108 | CONFLICT/PAUSED | V-6: „tuż po kąpieli” instead of „świeżo po łazience”. |
| 109 | NOT APPLIED | audited wording untouched |
| 110 | CONFLICT/PAUSED | V-2: the invented „mokre buty” cue was removed altogether. |

## Not checked

- English-side equivalence for each of the 126 rows (the audit is Polish-led; EN was compared
  only where the finding named it).
- Rows whose audited field was renamed or moved since the audit was written: a probe cannot
  distinguish "renamed field" from "not applied"; each of the 108 NOT APPLIED rows is confirmed
  only by the literal spot checks listed above plus the per-file table in `ledger2.tsv`.
