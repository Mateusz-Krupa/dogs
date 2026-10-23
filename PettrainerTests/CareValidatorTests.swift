import XCTest
@testable import Pettrainer

/// Ported behaviour from `src/content/schema/care.test.ts`: the native
/// validator must accept and reject exactly what the JS one does, because the
/// same JSON ships to both runtimes. Error text is asserted verbatim so a
/// drifted rule in either validator shows up as a failing test, not as content
/// that quietly loads in one build and fails in the other.
final class CareValidatorTests: XCTestCase {

    private func json(_ text: String) throws -> JSONValue {
        try JSONValue(data: Data(text.utf8))
    }

    private func stage(_ ordinal: Int, stopOverride: String? = nil,
                       extra: String = "", gearJSON: String = "[\"treats\",\"mat\"]") throws -> String {
        let copy = """
        {"title":"Etap \(ordinal)","setup":"s","how":"h","watchFor":"w",\
        "stop":"\(stopOverride ?? "Stop dla etapu \(ordinal)")"}
        """
        let en = """
        {"title":"Stage \(ordinal)","setup":"s","how":"h","watchFor":"w",\
        "stop":"Stop for stage \(ordinal)"}
        """
        return """
        {"ordinal":\(ordinal),"gear":\(gearJSON),"pl":\(copy),"en":\(en)\(extra)}
        """
    }

    /// A routine copy-pasted into both runtimes' fixtures: valid on purpose,
    /// so every test below changes exactly one thing.
    private func routine(
        id: String = "care-nails",
        stagesJSON: String? = nil,
        sourcesJSON: String = """
        [{"title":"VCA: Taking the Stress out of Nail Trimming for Dogs",\
        "url":"https://vcahospitals.com/know-your-pet/taking-the-stress-out-of-nail-trimming-for-dogs"}]
        """,
        practicesJSON: String = "[\"handling\",\"mat\"]",
        urgentJSON: String? = nil,
        professionalJSON: String? = nil,
        extra: String = ""
    ) throws -> JSONValue {
        let stages = try stagesJSON ?? "[\(stage(1)),\(stage(2)),\(stage(3))]"
        let urgent = urgentJSON ?? """
        {"pl":"Ból, krwawienie albo warczenie — stop i weterynarz.",\
        "en":"Pain, bleeding or growling — stop and call the vet."}
        """
        let professional = professionalJSON ?? """
        {"pl":"Bardzo długie pazury planuje weterynarz, nie siła.",\
        "en":"Very long nails are a veterinarian plan, not a struggle."}
        """
        return try json("""
        {"id":"\(id)","pose":"stand","sortOrder":2,
         "names":{"pl":{"name":"Pielęgnacja pazurów","description":"d"},
                  "en":{"name":"Nail care","description":"d"}},
         "tagline":{"pl":"t","en":"t"},
         "urgent":\(urgent),
         "professional":\(professional),
         "practices":\(practicesJSON),
         "sources":\(sourcesJSON),
         "stages":\(stages)\(extra)}
        """)
    }

    private func message(_ value: JSONValue, source: String = "care-nails.json") -> String {
        do {
            _ = try CareValidator.parseRoutine(value, source: source)
            return "no error"
        } catch {
            return "\(error)"
        }
    }

    // MARK: happy path

    func testWellFormedRoutineParses() throws {
        let routine = try CareValidator.parseRoutine(try routine(), source: "care-nails.json")
        XCTAssertEqual(routine.id, "care-nails")
        XCTAssertEqual(routine.stages.count, 3)
        XCTAssertEqual(routine.stages.first?.pl.stop, "Stop dla etapu 1")
        XCTAssertEqual(routine.sources.count, 1)
    }

    // MARK: identity and shape

    func testIdMustCarryTheCarePrefix() throws {
        XCTAssertEqual(try message(try routine(id: "nails")),
                       "care-nails.json: id must start with \"care-\" so ids cannot collide")
    }

    func testExactlyThreeStagesAreRequired() throws {
        let two = try message(try routine(stagesJSON: "[\(try stage(1)),\(try stage(2))]"))
        XCTAssertTrue(two.contains("stages must offer exactly 3 stages"), two)
    }

    func testStageOrdinalsMustRunContiguously() throws {
        let repeated = try message(try routine(
            stagesJSON: "[\(try stage(1)),\(try stage(2)),\(try stage(2))]"))
        XCTAssertTrue(repeated.contains("stages[2].ordinal must be 3"), repeated)
    }

    // MARK: safety boundaries

    func testBothSafetyBoundariesAreRequiredInBothLocales() throws {
        for field in ["urgent", "professional"] {
            let missing = try message(try routine(
                urgentJSON: field == "urgent" ? "null" : nil,
                professionalJSON: field == "professional" ? "null" : nil))
            XCTAssertTrue(missing.contains("\(field) must be an object"), missing)

            let halfTranslated = "{\"pl\":\"Jest treść.\",\"en\":\"\"}"
            let blank = try message(try routine(
                urgentJSON: field == "urgent" ? halfTranslated : nil,
                professionalJSON: field == "professional" ? halfTranslated : nil))
            XCTAssertTrue(blank.contains("\(field).en must be a non-empty string"), blank)
        }
    }

    func testStageStopLineIsRequiredInBothLocales() throws {
        // Empty stop in pl of stage 3.
        let blanked = try routine(stagesJSON: """
        [\(try stage(1)),\(try stage(2)),\
        {"ordinal":3,"gear":["treats"],\
        "pl":{"title":"t","setup":"s","how":"h","watchFor":"w","stop":""},\
        "en":{"title":"t","setup":"s","how":"h","watchFor":"w","stop":"s"}}]
        """)
        XCTAssertEqual(try message(blanked),
                       "care-nails.json: stages[2].pl.stop must be a non-empty string")
    }

    // MARK: nothing here may be scored

    func testScoringAndGatingKeysAreRejectedByName() throws {
        for key in ["criterion", "reps", "target", "verdict", "requires", "environmentId"] {
            let message = try message(try routine(extra: ",\"\(key)\":1"))
            XCTAssertEqual(message,
                "care-nails.json: \(key) is not allowed on a care routine: participation is never scored")
        }
        let onStage = try message(try routine(
            stagesJSON: "[\(try stage(1)),\(try stage(2)),\(try stage(3, extra: ",\"criterion\":\"5/5\""))]"))
        XCTAssertEqual(onStage,
            "care-nails.json: stages[2].criterion is not allowed on a care routine: participation is never scored")
    }

    func testStageMayOnlyCarryItsOwnKeys() throws {
        let message = try message(try routine(
            stagesJSON: "[\(try stage(1)),\(try stage(2)),\(try stage(3, extra: ",\"sources\":[]"))]"))
        XCTAssertEqual(message,
            "care-nails.json: stages[2] may only carry ordinal, gear, pl, en, found sources")
    }

    // MARK: references

    func testPracticesMustLinkSomethingAndGearMustBeKnown() throws {
        XCTAssertEqual(try message(try routine(practicesJSON: "[]")),
                       "care-nails.json: practices must point at at least one exercise")
        let unknownGear = try message(try routine(stagesJSON: """
        [\(try stage(1)),\(try stage(2)),\(try stage(3, gearJSON: "[\"lamp\"]"))]
        """))
        XCTAssertTrue(unknownGear.contains("stages[2].gear[0] must be one of"), unknownGear)
    }

    // MARK: source contract (reviewer A-3)

    func testSourcesMustExistAndStaySmall() throws {
        XCTAssertEqual(try message(try routine(sourcesJSON: "[]")),
                       "care-nails.json: sources must cite at least one source")
        XCTAssertEqual(try message(try routine(sourcesJSON: "null")),
                       "care-nails.json: sources must be an array of sources")
        let many = (0...5).map { i in "{\"title\":\"Źródło \(i)\",\"url\":\"https://example.com/\(i)\"}" }
            .joined(separator: ",")
        XCTAssertTrue(try message(try routine(sourcesJSON: "[\(many)]"))
                        .contains("must cite at most 5 sources"))
    }

    func testSourceTitleMustBeOneTrimmedLine() throws {
        for (title, reason) in [
            ("\"  docięte  \"", "must be a single trimmed line"),
            ("\"a\\nb\"", "must be a single trimmed line"),
            ("\"\(String(repeating: "x", count: 121))\"", "must be at most 120 characters"),
        ] {
            let message = try message(try routine(
                sourcesJSON: "[{\"title\":\(title),\"url\":\"https://example.com\"}]"))
            XCTAssertTrue(message.contains(reason), "\(reason) → \(message)")
        }
    }

    func testSourceURLMustBeCleanHTTPS() throws {
        for url in [
            "http://example.com",
            "ftp://example.com",
            "example.com/x",
            "https://example.com/a b",
            "https://user@pass.example.com",
            "https://localhost",
        ] {
            let message = try message(try routine(
                sourcesJSON: "[{\"title\":\"Źródło\",\"url\":\"\(url)\"}]"))
            XCTAssertTrue(message.hasPrefix("care-nails.json: sources[0].url "), message)
            XCTAssertFalse(message.contains("no error"), "\(url) should not validate: \(message)")
        }
    }

    func testSourceURLsMustNotRepeatAndMayNotGrowExtraFields() throws {
        let duplicated = try message(try routine(sourcesJSON: """
        [{"title":"A","url":"https://example.com/x"},{"title":"B","url":"https://example.com/x"}]
        """))
        XCTAssertEqual(duplicated, "care-nails.json: sources must not repeat https://example.com/x")

        let extraField = try message(try routine(
            sourcesJSON: "[{\"title\":\"A\",\"url\":\"https://example.com\",\"note\":\"x\"}]"))
        XCTAssertEqual(extraField,
            "care-nails.json: sources[0] may only carry title and url, found note")
    }
}
