import XCTest
@testable import Pettrainer

/// Welfare acceptance for the two cards added on 2026-10-22 (reviewer R-6):
/// the stop-lines must route to the right professional in BOTH locales, the
/// bed protocol must protect sleeping dogs and real night-time needs, and the
/// mounting protocol must keep basic needs unconditional. Byte parity proves
/// the shipped copy is the reviewed copy; these tests pin its meaning.
final class BehaviourWelfareCopyTests: XCTestCase {
    private static let content = try! ContentLoader.load(bundle: .main)

    private func issue(_ id: String) -> BehaviourIssue {
        Self.content.behaviourIssue(id: id)!
    }

    // MARK: mounting

    func testMountingStopLinesRouteToVetAndBehaviourist() {
        let card = issue("mounting")
        XCTAssertTrue(card.urgent.pl.contains("weterynarz"), "sudden/compulsive → vet (PL)")
        XCTAssertTrue(card.urgent.en.lowercased().contains("vet"), "sudden/compulsive → vet (EN)")
        XCTAssertTrue(card.urgent.pl.contains("warczenie") && card.urgent.en.lowercased().contains("growl"),
                      "growl/snap interruption must route to professionals in both locales")
        XCTAssertTrue(card.urgent.pl.contains("pogryzienie") && card.urgent.en.lowercased().contains("bite"),
                      "bite history must short-circuit DIY")
        XCTAssertTrue(card.professional.pl.contains("behawior")
                       && card.professional.en.lowercased().contains("professional"))
        XCTAssertEqual(card.names.pl.name, "Wspinanie się na nogę") // R-5 spelling lock
    }

    func testMountingKeepsBasicNeedsUnconditional() {
        let card = issue("mounting")
        XCTAssertTrue(card.work.pl[0].contains("bezwarunkowe") && card.work.pl[0].contains("miska"),
                      "R-3: basic-needs guard must be explicit in PL")
        XCTAssertTrue(card.work.en[0].lowercased().contains("unconditional")
                       && card.work.en[0].lowercased().contains("bowl"),
                      "R-3: basic-needs guard must be explicit in EN")
    }

    // MARK: bed

    func testBedProtocolProtectsSleepingDogs() {
        let card = issue("bed")
        XCTAssertTrue(card.work.pl[2].contains("śpiącego psa nie tykaj")
                       && card.work.pl[2].contains("nie budź"),
                      "R-1: the evening reward must never mean touching a sleeping dog (PL)")
        XCTAssertTrue(card.work.en[2].lowercased().contains("never touch or wake a sleeping dog"),
                      "R-1: same guard in EN")
    }

    func testBedProtocolServesNeedsBeforeBoundaries() {
        let card = issue("bed")
        XCTAssertTrue(card.work.pl[3].contains("siusiu"), "R-2: night-time needs first (PL)")
        XCTAssertTrue(card.work.en[3].lowercased().contains("toilet break"), "R-2: needs first (EN)")
        XCTAssertTrue(card.work.pl[1].contains("wróć do poprzedniego ustawienia"), "R-2: demotion when the dog struggles (PL)")
        XCTAssertTrue(card.work.en[1].lowercased().contains("go back one stage"), "R-2: demotion (EN)")
        XCTAssertTrue(card.work.pl[3].contains("nie negocjacja"),
                      "R-2: night-time fear framed as a signal, not bargaining (PL)")
        XCTAssertTrue(card.work.en[3].lowercased().contains("not bargaining"), "R-2: same framing (EN)")
        XCTAssertTrue(card.now.pl[0].contains("potrzeba") && card.now.en[0].lowercased().contains("real need"),
                      "R-2: the management rule states the needs exception (PL/EN)")
    }

    func testBedStopLineForbidsForcefulRemoval() {
        let card = issue("bed")
        XCTAssertTrue(card.urgent.pl.contains("behawioryst")
                       && card.urgent.en.lowercased().contains("behaviour professional"))
        XCTAssertTrue(card.urgent.pl.contains("nie próbuj zdejmować go siłą")
                       && card.urgent.en.lowercased().contains("do not pull"),
                      "guarding must never be met with force")
        XCTAssertTrue(card.professional.pl.contains(" Nocny lęk")
                       && card.professional.en.contains(" Night-time fear"),
                      "R-2: fear routes to professionals in the closing line too")
    }

    // MARK: shared

    func testNewCardsPracticeLinksResolve() {
        for id in ["mounting", "bed"] {
            for exerciseId in issue(id).practices {
                XCTAssertNotNil(Self.content.exercise(id: exerciseId),
                                "unresolved practice link \(exerciseId) on \(id)")
            }
        }
    }
}
