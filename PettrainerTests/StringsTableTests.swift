import XCTest
@testable import Pettrainer

/// The runtime table must see the same strings Apple compiled into the
/// per-language .lproj files — that is the whole contract of the in-app
/// language switch.
final class StringsTableTests: XCTestCase {
    func testPolishAndEnglishTablesLoadFromBundle() throws {
        for language in ["pl", "en"] {
            XCTAssertFalse(StringsTable.string("session.hit", language: language).isEmpty)
            XCTAssertNotEqual(StringsTable.string("session.hit", language: language), "session.hit",
                              "no compiled table found for \(language)")
        }
    }

    func testKnownTranslationsResolvePerLanguage() {
        XCTAssertEqual(StringsTable.string("session.hit", language: "pl"), "Zaliczone")
        XCTAssertEqual(StringsTable.string("session.hit", language: "en"), "Got it")
        XCTAssertEqual(StringsTable.string("verdict.push.label", language: "pl"),
                       "Podnieś poprzeczkę")
    }

    func testFormatKeysCarryPositionalPlaceholders() {
        // The %@/%lld contract fmt() depends on for both languages.
        let rungs = StringsTable.string("session.rungs", language: "pl")
        XCTAssertTrue(rungs.contains("%1$lld") && rungs.contains("%2$lld"), rungs)
        XCTAssertTrue(StringsTable.string("session.rungs", language: "en")
            .contains("%1$lld"))
    }

    func testCareKeysResolveWithTheirInterpolation() {
        // Reviewer 5.1: at least one pinned care label per language plus the
        // furthest-tried placeholder shape, so the catalogue strings cannot
        // silently drop out of the compiled tables.
        XCTAssertEqual(StringsTable.string("care.title", language: "pl"), "Pielęgnacja")
        XCTAssertEqual(StringsTable.string("care.title", language: "en"), "Hygiene care")
        let furthest = StringsTable.string("care.furthestTried", language: "pl")
        XCTAssertTrue(furthest.contains("%1$lld") && furthest.contains("%2$lld"), furthest)
        XCTAssertTrue(StringsTable.string("care.furthestTried", language: "en")
            .contains("%1$lld/%2$lld"))
    }

    func testUnknownKeyFallsBackToTheKeyItself() {
        XCTAssertEqual(StringsTable.string("no.such.key", language: "pl"), "no.such.key")
    }
}
