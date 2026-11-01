import XCTest
@testable import Pettrainer

/// Validation for puppy guides and their evidence block. The guide validator's
/// job is to make scored semantics impossible and to fail loudly on half a
/// translation; the evidence validator's job is to refuse a citation that
/// cannot be opened or a date that cannot be true. Error text is asserted so a
/// loosened rule shows up here, not as content that quietly ships.
final class PuppyGuideValidatorTests: XCTestCase {

    /// A fixed "today" so a fixture pinned to the future is future forever,
    /// whatever day the suite runs on.
    private let today = "2026-06-01"

    private func json(_ text: String) throws -> JSONValue {
        try JSONValue(data: Data(text.utf8))
    }

    private func evidenceJSON(
        verifiedOn: String = "2026-05-20",
        sources: String = """
        [{"title":"Blue Cross — Puppy biting and mouthing",\
        "url":"https://www.bluecross.org.uk/advice/dog/behaviour-and-training/puppy-biting-and-mouthing"}]
        """
    ) -> String {
        """
        {"verifiedOn":"\(verifiedOn)","sources":\(sources)}
        """
    }

    /// Valid on purpose, so each test below changes exactly one thing.
    private func guide(
        id: String = "puppy-rest",
        urgentJSON: String? = nil,
        avoidJSON: String? = nil,
        actionsJSON: String? = nil,
        observeJSON: String? = nil,
        practicesJSON: String = "[]",
        sectionsJSON: String? = nil,
        evidenceJSON overrideEvidence: String? = nil,
        extra: String = ""
    ) throws -> JSONValue {
        let urgent = urgentJSON ?? #"{"pl":"u","en":"u"}"#
        let list = #"{"pl":["a"],"en":["a"]}"#
        let evidence = overrideEvidence ?? self.evidenceJSON()
        let sections = sectionsJSON.map { ",\"sections\":\($0)" } ?? ""
        return try json("""
        {"id":"\(id)","pose":"down","sortOrder":1,
         "names":{"pl":{"name":"n","description":"d"},"en":{"name":"n","description":"d"}},
         "urgent":\(urgent),
         "avoid":\(avoidJSON ?? list),
         "actions":\(actionsJSON ?? list),
         "observe":\(observeJSON ?? list),
         "professional":{"pl":"p","en":"p"},
         "practices":\(practicesJSON),
         "evidence":\(evidence)\(sections)\(extra)}
        """)
    }

    private func parse(_ value: JSONValue) throws -> PuppyGuide {
        try PuppyGuideValidator.parseGuide(value, source: "puppy/x.json", today: today)
    }

    // MARK: happy path

    func testValidGuideParsesAllSections() throws {
        let parsed = try parse(try guide(practicesJSON: "[\"look\"]"))
        XCTAssertEqual(parsed.id, "puppy-rest")
        XCTAssertEqual(parsed.pose, .down)
        XCTAssertEqual(parsed.evidence.sources.count, 1)
        XCTAssertEqual(parsed.evidence.verifiedOn, "2026-05-20")
        XCTAssertEqual(parsed.practices, ["look"])
        XCTAssertFalse(parsed.avoid.pl.isEmpty)
    }

    func testEmptyPracticesIsAllowed() throws {
        // A guide with nothing to drill is honest, not an error.
        XCTAssertEqual(try parse(try guide()).practices, [])
    }

    // MARK: optional sections (add-puppy-toilet-guidance)

    /// One section object, valid unless a test overrides a single field.
    private func section(_ id: String = "routine",
                         title: String = #"{"pl":"t","en":"t"}"#,
                         paragraphs: String = #"{"pl":["p"],"en":["p"]}"#,
                         extra: String = "") -> String {
        "{\"id\":\"\(id)\",\"title\":\(title),\"paragraphs\":\(paragraphs)\(extra)}"
    }

    func testGuideWithoutSectionsParsesWithEmptySections() throws {
        // Absence is the old shape: the four shipped guides must keep loading.
        XCTAssertTrue(try parse(try guide()).sections.isEmpty)
    }

    func testValidSectionsParseInOrder() throws {
        let parsed = try parse(try guide(
            sectionsJSON: "[\(section()),{\"id\":\"second\",\"title\":{\"pl\":\"t\",\"en\":\"t\"},\"paragraphs\":{\"pl\":[\"p\"],\"en\":[\"p\"]}}]"))
        XCTAssertEqual(parsed.sections.map(\.id), ["routine", "second"])
        XCTAssertEqual(parsed.sections.first?.title.pl, "t")
        XCTAssertEqual(parsed.sections.first?.paragraphs.en, ["p"])
    }

    func testEmptySectionsArrayRejected() throws {
        // Present-but-empty is a half-edit, not "no sections".
        XCTAssertThrowsError(try parse(try guide(sectionsJSON: "[]"))) { error in
            XCTAssertTrue("\(error)".contains("must list sections or be left out"), "\(error)")
        }
    }

    func testNonArraySectionsRejected() throws {
        XCTAssertThrowsError(try parse(try guide(sectionsJSON: "{}"))) { error in
            XCTAssertTrue("\(error)".contains("must be an array of sections"), "\(error)")
        }
    }

    func testMissingSectionIdRejected() throws {
        XCTAssertThrowsError(try parse(try guide(sectionsJSON:
            "[{\"title\":{\"pl\":\"t\",\"en\":\"t\"},\"paragraphs\":{\"pl\":[\"p\"],\"en\":[\"p\"]}}]"))) { error in
            XCTAssertTrue("\(error)".contains("sections[0].id"), "\(error)")
        }
    }

    func testSectionMissingEnTitleFailsWithFieldPath() throws {
        // PIT-001 again: the nested `pl` half must not mask a missing `en`.
        XCTAssertThrowsError(try parse(try guide(sectionsJSON:
            "[\(section(title: #"{"pl":"t"}"#))]"))) { error in
            XCTAssertTrue("\(error)".contains("sections[0].title.en"), "\(error)")
        }
    }

    func testSectionBlankParagraphRejected() throws {
        XCTAssertThrowsError(try parse(try guide(sectionsJSON:
            "[\(section(paragraphs: #"{"pl":["   "],"en":["p"]}"#))]"))) { error in
            XCTAssertTrue("\(error)".contains("sections[0].paragraphs.pl[0]"), "\(error)")
        }
    }

    func testSectionEmptyParagraphListRejected() throws {
        XCTAssertThrowsError(try parse(try guide(sectionsJSON:
            "[\(section(paragraphs: #"{"pl":[],"en":["p"]}"#))]"))) { error in
            XCTAssertTrue("\(error)".contains("must list something"), "\(error)")
        }
    }

    func testDuplicateSectionIdsRejected() throws {
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section()),\(section())]"))) { error in
            XCTAssertTrue("\(error)".contains("must be unique"), "\(error)")
        }
    }

    func testUnknownSectionKeyRejected() throws {
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section(extra: ",\"note\":\"x\""))]"))) { error in
            XCTAssertTrue("\(error)".contains("may only carry id, title and paragraphs"),
                          "\(error)")
        }
    }

    func testScoringKeyInsideSectionRejected() throws {
        // A `reps` key inside a reading block would turn prose into a drill.
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section(extra: ",\"reps\":1"))]"))) { error in
            XCTAssertTrue("\(error)".contains("reps"), "\(error)")
            XCTAssertTrue("\(error)".contains("reading is never scored"), "\(error)")
            XCTAssertTrue("\(error)".contains("sections[0]"), "\(error)")
        }
    }

    func testGatingKeyInsideSectionRejected() throws {
        // Prerequisites are the other half of "never gate content" abuse.
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section(extra: ",\"requires\":[]"))]"))) { error in
            XCTAssertTrue("\(error)".contains("requires"), "\(error)")
            XCTAssertTrue("\(error)".contains("reading is never scored"), "\(error)")
        }
    }

    func testExplicitNullSectionsRejected() throws {
        // Absence is compatibility; an explicit null is a half-edit.
        XCTAssertThrowsError(try parse(try guide(sectionsJSON: "null"))) { error in
            XCTAssertTrue("\(error)".contains("must be an array of sections"), "\(error)")
        }
    }

    func testBlankSectionIdRejected() throws {
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section("  "))]"))) { error in
            XCTAssertTrue("\(error)".contains("sections[0].id"), "\(error)")
            XCTAssertTrue("\(error)".contains("non-empty"), "\(error)")
        }
    }

    func testBlankSectionTitleRejected() throws {
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section(title: #"{"pl":"  ","en":"t"}"#))]"))) { error in
            XCTAssertTrue("\(error)".contains("sections[0].title.pl"), "\(error)")
        }
    }

    func testSectionMissingEnParagraphsRejected() throws {
        // PIT-001 over the newest surface: the `pl` half must not mask a
        // missing `en` inside paragraphs.
        XCTAssertThrowsError(try parse(try guide(
            sectionsJSON: "[\(section(paragraphs: #"{"pl":["p"]}"#))]"))) { error in
            XCTAssertTrue("\(error)".contains("sections[0].paragraphs.en"), "\(error)")
        }
    }

    // MARK: identity and scoring

    func testIdMustCarryPuppyPrefix() throws {
        XCTAssertThrowsError(try parse(try guide(id: "rest"))) { error in
            XCTAssertTrue("\(error)".contains("must start with \"puppy-\""), "\(error)")
        }
    }

    func testScoringKeyIsRejectedByName() throws {
        // Even one reps key would turn rest into a thing to pass.
        for forbidden in ["criterion", "reps", "completed", "level", "environment"] {
            XCTAssertThrowsError(try parse(guide(extra: ",\"\(forbidden)\":1"))) { error in
                XCTAssertTrue("\(error)".contains(forbidden), "\(error)")
                XCTAssertTrue("\(error)".contains("reading is never scored"), "\(error)")
            }
        }
    }

    // MARK: locale completeness (CONV-001 / PIT-001)

    func testMissingEnHalfOfANestedListFailsWithFieldPath() {
        // PIT-001: a walker that only checked the top `pl` key would miss this.
        XCTAssertThrowsError(try parse(guide(avoidJSON: #"{"pl":["a"]}"#))) { error in
            XCTAssertTrue("\(error)".contains("avoid.en"), "\(error)")
        }
    }

    func testEmptyLocaleListFails() throws {
        XCTAssertThrowsError(try parse(try guide(actionsJSON: #"{"pl":[],"en":["a"]}"#))) { error in
            XCTAssertTrue("\(error)".contains("must list something"), "\(error)")
        }
    }

    func testBlankUrgentFails() throws {
        XCTAssertThrowsError(try parse(try guide(urgentJSON: #"{"pl":"   ","en":"u"}"#))) { error in
            XCTAssertTrue("\(error)".contains("urgent.pl"), "\(error)")
        }
    }

    // MARK: evidence URLs

    func testHttpSourceRejected() throws {
        let bad = evidenceJSON(sources: #"[{"title":"T","url":"http://x.example/a"}]"#)
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: bad))) { error in
            XCTAssertTrue("\(error)".contains("https:// address"), "\(error)")
        }
    }

    func testWhitespaceUrlRejected() throws {
        let bad = evidenceJSON(sources: #"[{"title":"T","url":"https://x.example/a b"}]"#)
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: bad))) { error in
            XCTAssertTrue("\(error)".contains("whitespace"), "\(error)")
        }
    }

    func testCredentialUrlRejected() throws {
        let bad = evidenceJSON(sources: #"[{"title":"T","url":"https://user:secret@x.example/a"}]"#)
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: bad))) { error in
            XCTAssertTrue("\(error)".contains("credentials"), "\(error)")
        }
    }

    func testHostWithoutDotRejected() throws {
        let bad = evidenceJSON(sources: #"[{"title":"T","url":"https://localhost/a"}]"#)
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: bad))) { error in
            XCTAssertTrue("\(error)".contains("must name a host"), "\(error)")
        }
    }

    func testDuplicateUrlRejected() throws {
        let dup = evidenceJSON(sources: #"""
        [{"title":"A","url":"https://x.example/a"},{"title":"B","url":"https://x.example/a"}]
        """#)
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: dup))) { error in
            XCTAssertTrue("\(error)".contains("must not repeat"), "\(error)")
        }
    }

    func testTooManySourcesRejected() throws {
        let list = (1...6).map { #"{"title":"S\#($0)","url":"https://x.example/\#($0)"}"# }
            .joined(separator: ",")
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: evidenceJSON(sources: "[\(list)]")))) { error in
            XCTAssertTrue("\(error)".contains("at most 5"), "\(error)")
        }
    }

    // MARK: verified date

    func testFutureDateRejected() throws {
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: evidenceJSON(verifiedOn: "2026-07-01")))) { error in
            XCTAssertTrue("\(error)".contains("not be after today"), "\(error)")
        }
    }

    func testBoundaryDateEqualToTodayAccepted() throws {
        // "Verified today" is legitimate; only strictly-later is a fabrication.
        let parsed = try parse(try guide(evidenceJSON: evidenceJSON(verifiedOn: today)))
        XCTAssertEqual(parsed.evidence.verifiedOn, today)
    }

    func testImpossibleDayRejected() throws {
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: evidenceJSON(verifiedOn: "2026-02-30")))) { error in
            XCTAssertTrue("\(error)".contains("real calendar date"), "\(error)")
        }
    }

    func testMalformedDateRejected() throws {
        XCTAssertThrowsError(try parse(try guide(evidenceJSON: evidenceJSON(verifiedOn: "2026-5-1")))) { error in
            XCTAssertTrue("\(error)".contains("YYYY-MM-DD"), "\(error)")
        }
    }

    /// FR-1 guard. Anchored instant 2026-10-23T23:30Z: in UTC it is the 23rd,
    /// at Pacific/Kiritimati (+14) already the 24th. `today` must judge the
    /// deadline against the owner's local civil day (a UTC reading would call
    /// the bundled "verified 2026-10-24" a future date and refuse the app to
    /// launch ahead of UTC), and must always count in the Gregorian system so
    /// a device set to another calendar style cannot report an era year and
    /// false-future every 2026 file. The injectable `timeZone:` is the seam
    /// that makes this deterministic on a machine-wide read-only TimeZone.
    func testTodayIsGregorianLocalCivilDay() throws {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        let instant = try XCTUnwrap(utc.date(
            from: DateComponents(year: 2026, month: 10, day: 23, hour: 23, minute: 30)))

        XCTAssertEqual(GuidanceEvidenceValidator.today(instant,
            timeZone: TimeZone(identifier: "UTC")!), "2026-10-23",
            "in UTC the anchored instant is still the 23rd")
        XCTAssertEqual(GuidanceEvidenceValidator.today(instant,
            timeZone: TimeZone(identifier: "Pacific/Kiritimati")!), "2026-10-24",
            "a +14 device must see the verified civil day, not the UTC day")
    }
}
