import XCTest
@testable import Pettrainer

/// The shipped puppy guidance as a whole: order the hub promises, the sections
/// the welfare copy depends on, and the namespace wall between reading and
/// scored training. String assertions prove the reviewed copy is what ships;
/// the meaning itself is reviewed by a person, as always for welfare copy.
final class PuppyContentTests: XCTestCase {
    private static let content = try! ContentLoader.load(bundle: .main)

    private func guide(_ id: String) -> PuppyGuide {
        Self.content.puppyGuide(id: id)!
    }

    private func issue(_ id: String) -> BehaviourIssue {
        Self.content.behaviourIssue(id: id)!
    }

    // MARK: hub contract

    func testFoundationsInHubOrder() {
        XCTAssertEqual(Self.content.puppyGuides.map(\.id), [
            "puppy-rest", "puppy-world", "puppy-play", "puppy-first-exercises", "puppy-toilet",
        ])
    }

    func testHelpLinksResolveToCanonicalCards() {
        // Every hub "help now" id must exist as a behaviour card — the hub
        // links to the problems family, it does not own a copy of it.
        for id in PuppyStartView.helpIssueIds {
            XCTAssertNotNil(Self.content.behaviourIssue(id: id), "hub help id \(id) is not a card")
        }
        XCTAssertEqual(PuppyStartView.helpIssueIds,
                       ["overarousal", "fear-withdrawal", "nipping", "mounting"])
    }

    func testNewCardsEnterTheProblemsListBeforeAlone() {
        let ids = Self.content.behaviour.map(\.id)
        XCTAssertEqual(ids.suffix(3), ["overarousal", "fear-withdrawal", "alone"])
    }

    // MARK: required sections on the guidance resources

    func testEveryGuideCarriesSafetyAvoidActionsObserveAndEvidence() {
        // Both locales are checked explicitly: ContentLocale.value would only
        // ever see the one the host currently renders (CONV-001).
        for guide in Self.content.puppyGuides {
            XCTAssertFalse(guide.urgent.pl.isEmpty, "\(guide.id) urgent/pl")
            XCTAssertFalse(guide.urgent.en.isEmpty, "\(guide.id) urgent/en")
            XCTAssertFalse(guide.avoid.pl.isEmpty, "\(guide.id) avoid/pl")
            XCTAssertFalse(guide.avoid.en.isEmpty, "\(guide.id) avoid/en")
            XCTAssertFalse(guide.actions.pl.isEmpty, "\(guide.id) actions/pl")
            XCTAssertFalse(guide.actions.en.isEmpty, "\(guide.id) actions/en")
            XCTAssertFalse(guide.observe.pl.isEmpty, "\(guide.id) observe/pl")
            XCTAssertFalse(guide.observe.en.isEmpty, "\(guide.id) observe/en")
            XCTAssertFalse(guide.professional.pl.isEmpty, "\(guide.id) professional/pl")
            XCTAssertFalse(guide.professional.en.isEmpty, "\(guide.id) professional/en")
            XCTAssertFalse(guide.names.pl.name.isEmpty, "\(guide.id) name/pl")
            XCTAssertFalse(guide.names.en.name.isEmpty, "\(guide.id) name/en")
            XCTAssertFalse(guide.names.pl.description.isEmpty, "\(guide.id) description/pl")
            XCTAssertFalse(guide.names.en.description.isEmpty, "\(guide.id) description/en")
            XCTAssertFalse(guide.evidence.sources.isEmpty, guide.id)
            // Per-guide review dates: `puppy-first-exercises` gained the
            // floor-scavenging copy and was re-read on 2026-10-29;
            // `puppy-toilet` cites pages read in full on 2026-10-31; the
            // original three guides keep their 2026-10-24 date. R-1: a new
            // guide gets its own entry here — never backdate it to keep this
            // test unchanged, and never relax the existing expectations.
            let expectedDate: [String: String] = [
                "puppy-first-exercises": "2026-10-29",
                "puppy-toilet": "2026-10-31",
            ]
            XCTAssertEqual(guide.evidence.verifiedOn,
                           expectedDate[guide.id] ?? "2026-10-24", guide.id)
        }
    }

    func testDesignatedBehaviourCardsCarryTheirExtensions() {
        for id in ["overarousal", "fear-withdrawal"] {
            XCTAssertNotNil(issue(id).observe, "\(id) must carry observation guidance")
            XCTAssertFalse(issue(id).observe!.pl.isEmpty && issue(id).observe!.en.isEmpty)
            XCTAssertNotNil(issue(id).evidence, "\(id) must carry evidence")
        }
        for id in ["nipping", "mounting"] {
            XCTAssertNotNil(issue(id).evidence, "\(id) gained provenance in this change")
            XCTAssertNil(issue(id).observe, "\(id) deliberately keeps its old shape")
        }
    }

    func testOldCardsParseWithoutTheExtensions() {
        // The compatibility rule: untouched cards render exactly as before.
        let bed = issue("bed")
        XCTAssertNil(bed.observe)
        XCTAssertNil(bed.evidence)
    }

    func testFirstExercisesGuideLinksTheSafeCuesIncludingTrading() {
        // Floor-item guidance points at the canonical leave/drop exercises
        // instead of owning a copy of their steps (CONV-002 keeps this a link).
        XCTAssertEqual(guide("puppy-first-exercises").practices,
                       ["name", "look", "mat", "leave", "drop"])
    }

    // MARK: floor-scavenging copy (expand-loose-lead-guidance)

    func testFirstExercisesGuideCarriesFloorItemCopyInBothLocales() throws {
        let guide = guide("puppy-first-exercises")
        // Every clause is asserted per locale and quoted in full: an && pair over
        // both languages, or a keyword, would stay green while one language loses
        // its safeguard (CONV-001).
        XCTAssertTrue(guide.urgent.pl.contains("natychmiastowy kontakt z lekarzem weterynarii"),
                      guide.urgent.pl)
        XCTAssertTrue(guide.urgent.en.contains("calling a veterinarian right away"),
                      guide.urgent.en)
        for text in [guide.urgent.pl, guide.urgent.en] {
            XCTAssertTrue(text.contains("gotowane kości") || text.contains("cooked bones"), text)
        }
        // Guarding short-circuits practice: no self-test, no punishment, stop.
        XCTAssertTrue(guide.urgent.pl
                        .contains("nie sprawdzaj tego na własną rękę, nie karz i przerwij ćwiczenia z przedmiotami"),
                      guide.urgent.pl)
        XCTAssertTrue(guide.urgent.en
                        .contains("do not test that yourself, do not punish it, and stop item practice"),
                      guide.urgent.en)
        // Leave is before the pickup, drop is after it — the order is the skill.
        let tradePl = try XCTUnwrap(guide.actions.pl.first { $0.contains("„zostaw”") })
        let tradeEn = try XCTUnwrap(guide.actions.en.first { $0.contains("“leave it”") })
        XCTAssertTrue(tradePl.contains("zanim pies coś podniesie"), tradePl)
        XCTAssertTrue(tradePl.contains("gdy już trzyma w pysku"), tradePl)
        XCTAssertTrue(tradeEn.contains("before the dog picks something up"), tradeEn)
        XCTAssertTrue(tradeEn.contains("when it is already held"), tradeEn)
        // Payment comes from the owner's hand, and only safe practice toys return.
        XCTAssertTrue(tradePl.contains("z Twojej ręki"), tradePl)
        XCTAssertTrue(tradeEn.contains("paid from your own hand"), tradeEn)
        XCTAssertTrue(tradePl.contains("bezpieczną zabawkę treningową po wymianie oddaj z powrotem"), tradePl)
        XCTAssertTrue(tradePl.contains("niebezpiecznego znaleziska nigdy nie zwracaj"), tradePl)
        XCTAssertTrue(tradeEn.contains("hand the safe practice toy straight back after the trade"), tradeEn)
        XCTAssertTrue(tradeEn.contains("never return a dangerous find"), tradeEn)
        // Practice props are never hazards, and force is not a lesson.
        XCTAssertTrue(guide.avoid.pl.contains { $0.contains("lekarstwa") && $0.contains("toksyczne jedzenie") },
                      "\(guide.avoid.pl)")
        XCTAssertTrue(guide.avoid.en.contains { $0.contains("medication") && $0.contains("toxic food") },
                      "\(guide.avoid.en)")
        XCTAssertTrue(guide.avoid.pl.contains { $0.contains("nie wyciągaj przedmiotów z pyska na siłę") },
                      "\(guide.avoid.pl)")
        XCTAssertTrue(guide.avoid.en.contains { $0.contains("do not take items out of the dog's mouth by force") },
                      "\(guide.avoid.en)")
        // Home performance does not transfer to the street by itself.
        XCTAssertTrue(guide.actions.pl.contains { $0.contains("kuchni") && $0.contains("chodnik") },
                      "\(guide.actions.pl)")
        XCTAssertTrue(guide.actions.en.contains { $0.contains("kitchen") && $0.contains("pavement") },
                      "\(guide.actions.en)")
        // Repeated non-food picking or a sudden change is a veterinary question first.
        XCTAssertTrue(guide.observe.pl.contains { $0.contains("niejadalne") && $0.contains("lekarzem weterynarii") },
                      "\(guide.observe.pl)")
        XCTAssertTrue(guide.observe.en.contains { $0.contains("inedible") && $0.contains("contact a veterinarian first") },
                      "\(guide.observe.en)")
    }

    func testFloorItemCopyCitesItsOwnSources() {
        let sources = guide("puppy-first-exercises").evidence.sources.map(\.url)
        XCTAssertTrue(sources.contains { $0.contains("leave-training") }, "\(sources)")
        XCTAssertTrue(sources.contains { $0.contains("household-and-garden-dangers") }, "\(sources)")
        XCTAssertTrue(sources.contains { $0.contains("chewing-everything") }, "\(sources)")
    }

    func testAllPracticeLinksResolve() {
        for guide in Self.content.puppyGuides {
            for practice in guide.practices {
                XCTAssertNotNil(Self.content.exercise(id: practice),
                                "\(guide.id) links to unknown exercise \(practice)")
            }
        }
    }

    // MARK: namespace wall

    func testGuideIdsAreNeverScoredContent() {
        let guideIds = Set(Self.content.puppyGuides.map(\.id))
        XCTAssertEqual(guideIds.count, 5)
        XCTAssertTrue(Set(Self.content.catalogue.map(\.id)).isDisjoint(with: guideIds))
        XCTAssertTrue(Set(Self.content.nosework.map(\.id)).isDisjoint(with: guideIds))
        XCTAssertTrue(Set(Self.content.care.map(\.id)).isDisjoint(with: guideIds))
        XCTAssertTrue(Set(Self.content.behaviour.map(\.id)).isDisjoint(with: guideIds))
        XCTAssertNil(Self.content.exercise(id: "puppy-rest"))
    }

    func testGuidesNeverSpeakMasteryLanguage() {
        // "Opanowane/mastered" would smuggle a verdict into reading material.
        let banned = ["opanowan", "mastered", "ukończon", "zaliczon", "passed"]
        for guide in Self.content.puppyGuides {
            // Explicit pl+en: the test must fail if either language ever
            // acquires a verdict word, whichever one the host renders.
            var fields: [String] = []
            fields.append(contentsOf: [
                guide.names.pl.name, guide.names.pl.description,
                guide.names.en.name, guide.names.en.description,
                guide.urgent.pl, guide.urgent.en,
                guide.professional.pl, guide.professional.en,
            ])
            fields.append(contentsOf: guide.avoid.pl)
            fields.append(contentsOf: guide.avoid.en)
            fields.append(contentsOf: guide.actions.pl)
            fields.append(contentsOf: guide.actions.en)
            fields.append(contentsOf: guide.observe.pl)
            fields.append(contentsOf: guide.observe.en)
            // R-2 (add-puppy-toilet-guidance): the optional sections hold most
            // of the newest prose — a guard that skipped them would stay green
            // while a verdict word entered the long-form copy. Same banned
            // terms, both locales, no parallel implementation.
            for section in guide.sections {
                fields.append(section.title.pl)
                fields.append(section.title.en)
                fields.append(contentsOf: section.paragraphs.pl)
                fields.append(contentsOf: section.paragraphs.en)
            }
            for text in fields {
                for word in banned {
                    XCTAssertFalse(text.lowercased().contains(word),
                                   "\(guide.id): scored word \"\(word)\" in guidance")
                }
            }
        }
    }

    // MARK: reviewed copy replacements stay replaced

    func testMountingHelpsEarlyInsteadOfWaitingMonths() {
        let card = issue("mounting")
        XCTAssertFalse(card.professional.pl.contains("miesiąc"),
                       "the months-long trial must not come back (PL)")
        XCTAssertFalse(card.professional.en.lowercased().contains("months"),
                       "the months-long trial must not come back (EN)")
        XCTAssertTrue(card.professional.pl.contains("codzienne życie"),
                      "functioning is the new trigger (PL)")
        XCTAssertTrue(card.professional.en.lowercased().contains("daily life"),
                      "functioning is the new trigger (EN)")
    }

    func testNippingEnglishQuotePairsAreClosed() {
        // The PIT-001 lesson applies to EN pairs too: one card shipped two
        // opening curly quotes with escaped straight closers.
        let card = issue("nipping")
        for line in card.avoid.en + card.work.en {
            XCTAssertEqual(line.filter { $0 == "\u{201C}" }.count,
                           line.filter { $0 == "\u{201D}" }.count,
                           "unbalanced quotes: \(line)")
        }
    }

    // MARK: toilet-training guide (add-puppy-toilet-guidance)

    func testToiletGuideHasTheApprovedSectionStructure() {
        let guide = guide("puppy-toilet")
        XCTAssertEqual(guide.sections.map(\.id), [
            "how-learning-works", "outdoor-routine", "reward-and-cue",
            "no-toilet-outside", "signals-and-freedom", "nights-and-absence",
            "pads-to-outdoors", "cleanup-and-setbacks",
        ])
        for section in guide.sections {
            XCTAssertFalse(section.title.pl.isEmpty, section.id)
            XCTAssertFalse(section.title.en.isEmpty, section.id)
            XCTAssertFalse(section.paragraphs.pl.isEmpty, section.id)
            XCTAssertFalse(section.paragraphs.en.isEmpty, section.id)
        }
        // The feature exists for the reading, not for a drill (spec).
        XCTAssertEqual(guide.practices, [])
    }

    func testToiletGuideCarriesTheBeforeDuringAfterRulePerLocale() {
        // Each clause is asserted in its own language and quoted from the
        // approved ledger: an && pair over both would stay green with one
        // language missing the welfare boundary (CONV-001).
        let guide = guide("puppy-toilet")
        XCTAssertTrue(guide.actions.pl[1].contains("pozwól skończyć"), guide.actions.pl[1])
        XCTAssertTrue(guide.actions.pl[1].contains("Nie krzycz, nie klaskaj, nie podnoś"),
                      guide.actions.pl[1])
        XCTAssertTrue(guide.actions.en[1].contains("let it finish"), guide.actions.en[1])
        XCTAssertTrue(guide.actions.en[1].contains("Do not shout, clap, or lift"),
                      guide.actions.en[1])
        // The after-discovered branch: quiet cleanup, no retro punishment.
        XCTAssertTrue(guide.actions.pl[2].contains("Wycieraj spokojnie, bez słowa i miny"),
                      guide.actions.pl[2])
        XCTAssertTrue(guide.actions.en[2].contains("Clean it quietly, without a word"),
                      guide.actions.en[2])
        // Reward belongs to the finished act, outdoors, at the spot.
        XCTAssertTrue(guide.actions.pl[3].contains("Gdy pies skończy sikać"),
                      guide.actions.pl[3])
        XCTAssertTrue(guide.actions.pl[3].contains("jeszcze stojąc przy tym miejscu"),
                      guide.actions.pl[3])
        XCTAssertTrue(guide.actions.en[3].contains("finishes peeing"), guide.actions.en[3])
        XCTAssertTrue(guide.actions.en[3].contains("still standing at the spot"),
                      guide.actions.en[3])
        // Straining without results is triaged as urgent, before any training.
        XCTAssertTrue(guide.urgent.pl.contains("stan nagły"), guide.urgent.pl)
        XCTAssertTrue(guide.urgent.pl.contains("nie zwlekaj"), guide.urgent.pl)
        XCTAssertTrue(guide.urgent.en.lowercased().contains("emergency"), guide.urgent.en)
        XCTAssertTrue(guide.urgent.en.contains("do not delay"), guide.urgent.en)
        // No numeric thresholds shipped: C-8 removed the 1–3-month window,
        // C-11/C-12 the 5/20-minute counters, C-13 the 8–12-week gate, C-18
        // the one-second deadline. Generic wording ("kilka minut", "tygodnie i
        // miesiące") is approved copy — only the rejected numbers are banned.
        let sectionTexts: [String] = guide.sections.flatMap { section in
            section.paragraphs.pl + section.paragraphs.en
        }
        let allProse: [String] = sectionTexts
            + guide.actions.pl + guide.actions.en
            + guide.observe.pl + guide.observe.en
            + [guide.urgent.pl, guide.urgent.en]
        for text in allProse {
            for bannedNumber in ["5 minut", "20 minut", "8–12", "8-12", "w sekundę",
                                 "within a second", "1. a 3. miesiącem"] {
                XCTAssertFalse(text.contains(bannedNumber),
                               "rejected numeric claim returned (\(bannedNumber)): \(text)")
            }
        }
        // Separation distress and bite risk route to professionals, no DIY.
        // F-2: the attribution stays tentative in both languages — the pattern
        // may point to separation distress; it never diagnoses it.
        XCTAssertTrue(guide.observe.pl[3].contains("mogą wskazywać na lęk separacyjny"),
                      guide.observe.pl[3])
        XCTAssertFalse(guide.observe.pl[3].contains("to sprawa lęku separacyjnego"),
                       "definitive PL diagnosis returned: \(guide.observe.pl[3])")
        XCTAssertTrue(guide.observe.en[3].contains("may point to separation-related distress"),
                      guide.observe.en[3])
        XCTAssertFalse(guide.observe.en[3].contains("point to separation distress"),
                       "definitive EN diagnosis returned: \(guide.observe.en[3])")
        XCTAssertTrue(guide.observe.pl[3].contains("ugryzienie"), guide.observe.pl[3])
        XCTAssertTrue(guide.observe.en[3].contains("bite"), guide.observe.en[3])
    }

    func testToiletCleanupStaysEnzymaticAndPaperJournalOnly() {
        // The approved variant 1: enzymatic product, no household recipes
        // (vinegar was considered and rejected for lack of authority), and the
        // journal stays a paper habit — no app diary feature smuggled in.
        let guide = guide("puppy-toilet")
        let cleanup = guide.sections[7]
        XCTAssertTrue(cleanup.paragraphs.pl[0].contains("preparatem enzymatycznym"),
                      cleanup.paragraphs.pl[0])
        XCTAssertTrue(cleanup.paragraphs.en[0].contains("enzymatic product"),
                      cleanup.paragraphs.en[0])
        XCTAssertTrue(cleanup.paragraphs.pl[1].contains("na kartce"),
                      cleanup.paragraphs.pl[1])
        XCTAssertTrue(cleanup.paragraphs.en[1].contains("on paper"),
                      cleanup.paragraphs.en[1])
        for text in cleanup.paragraphs.pl + cleanup.paragraphs.en {
            XCTAssertFalse(text.lowercased().contains("ocet"), "vinegar claim returned: \(text)")
            XCTAssertFalse(text.lowercased().contains("vinegar"), "vinegar claim returned: \(text)")
        }
    }

    func testToiletGuideCitesItsFiveReadPages() {
        let sources = guide("puppy-toilet").evidence.sources.map(\.url)
        XCTAssertEqual(sources.count, 5)
        XCTAssertTrue(sources.contains { $0.contains("dogstrust.org.uk") && $0.contains("toilet") }, "\(sources)")
        XCTAssertTrue(sources.contains { $0.contains("house-training-your-puppy") }, "\(sources)")
        XCTAssertTrue(sources.contains { $0.contains("house-soiling") }, "\(sources)")
        XCTAssertTrue(sources.contains { $0.contains("urinary-tract-infections") }, "\(sources)")
        // The marking page is the load-bearing citation for the
        // straining-is-an-emergency instruction (reviewer finding C-4).
        XCTAssertTrue(sources.contains { $0.contains("marking-behavior") }, "\(sources)")
    }
}
