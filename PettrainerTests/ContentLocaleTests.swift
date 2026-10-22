import XCTest
@testable import Pettrainer

/// Ported from `src/i18n/i18n.test.ts` (the pure `resolveLocale` half; the
/// String Catalog covers key parity natively).
final class ContentLocaleTests: XCTestCase {

    func testResolvesPrimarySubtag() {
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["pl-PL"]), "pl")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["en-GB"]), "en")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["en-US", "pl-PL"]), "en")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["de-DE", "en-GB"]), "en")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["zh-Hans", "pl"]), "pl")
    }

    func testUnsupportedAndEmptyFallBackToPolish() {
        XCTAssertEqual(ContentLocale.resolve(preferredTags: []), "pl")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["", "  ", "🐕"]), "pl")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["klingon"]), "pl")
    }

    func testFirstSupportedWins() {
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["en", "pl"]), "en")
        XCTAssertEqual(ContentLocale.resolve(preferredTags: ["pl", "en"]), "pl")
    }

    func testLocalizedValueSelectionFollowsResolutionRule() {
        let record = Localized(pl: "po polsku", en: "in english")
        // current is device-dependent; assert the pure half drives it:
        for tags in [["en"], ["en-GB", "de"], ["pl"]] {
            let expected = ContentLocale.resolve(preferredTags: tags) == "en"
                ? record.en : record.pl
            XCTAssertEqual(expected, tags.first!.hasPrefix("en") ? "in english" : "po polsku")
        }
    }
}
