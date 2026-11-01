import XCTest
@testable import Pettrainer

/// Ported behaviour from `src/content/schema.test.ts`, `sit.test.ts` and
/// `environments.test.ts`: malformed content must name the source file and the
/// exact field path, so the person editing JSON knows which key to fix.
final class ContentValidatorTests: XCTestCase {

    private func json(_ text: String) throws -> JSONValue {
        try JSONValue(data: Data(text.utf8))
    }

    private func minimalExercise(_ stepsJSON: String) throws -> JSONValue {
        try json("""
        {"id":"x","category":"foundation","sortOrder":1,"requires":[],
         "pose":"sit","gear":["treats"],
         "names":{"pl":{"name":"x","description":"d"},"en":{"name":"x","description":"d"}},
         "tagline":{"pl":"t","en":"t"},
         "steps":\(stepsJSON)}
        """)
    }

    // MARK: exercises

    func testBlankCriterionNamesTheExactField() throws {
        let entry = """
        [{"ordinal":1,"pl":{"instruction":"i","criterion":""},
          "en":{"instruction":"i","criterion":"c"}}]
        """
        let parsed = try minimalExercise(entry)
        XCTAssertThrowsError(try ExerciseValidator.parseCatalogueEntry(parsed, source: "exercises/x.json")) { error in
            XCTAssertEqual("\(error)",
                "exercises/x.json: steps[0].pl.criterion must be a non-empty string")
        }
    }

    func testUnknownMotionListsTheVocabulary() throws {
        let entry = """
        [{"ordinal":1,"motion":"levitate",
          "pl":{"instruction":"i","criterion":"c"},
          "en":{"instruction":"i","criterion":"c"}}]
        """
        let parsed = try minimalExercise(entry)
        XCTAssertThrowsError(try ExerciseValidator.parseCatalogueEntry(parsed, source: "exercises/x.json")) { error in
            XCTAssertTrue("\(error)".hasPrefix(
                "exercises/x.json: steps[0].motion must be one of: up, down, draw, hold"))
        }
    }

    func testOrdinalsMustRunContiguously() throws {
        let entry = """
        [{"ordinal":1,"pl":{"instruction":"i","criterion":"c"},
          "en":{"instruction":"i","criterion":"c"}},
         {"ordinal":3,"pl":{"instruction":"i","criterion":"c"},
          "en":{"instruction":"i","criterion":"c"}}]
        """
        let parsed = try minimalExercise(entry)
        XCTAssertThrowsError(try ExerciseValidator.parseCatalogueEntry(parsed, source: "exercises/x.json")) { error in
            XCTAssertTrue("\(error)".contains("must be 2; ordinals run contiguously from 1"))
        }
    }

    func testEmptyOptionalListIsAHalfEdit() throws {
        let entry = """
        [{"ordinal":1,"pl":{"instruction":"i","criterion":"c","setup":[]},
          "en":{"instruction":"i","criterion":"c"}}]
        """
        let parsed = try minimalExercise(entry)
        XCTAssertThrowsError(try ExerciseValidator.parseCatalogueEntry(parsed, source: "exercises/x.json")) { error in
            XCTAssertTrue("\(error)".contains("steps[0].pl.setup must list something or be left out"))
        }
    }

    func testEmptyStepsAndMissingLocaleFail() throws {
        XCTAssertThrowsError(try ExerciseValidator.parseCatalogueEntry(
            minimalExercise("[]"), source: "exercises/x.json"))
        XCTAssertThrowsError(try ExerciseValidator.parseCatalogueEntry(
            minimalExercise("""
            [{"ordinal":1,"pl":{"instruction":"i","criterion":"c"}}]
            """), source: "exercises/x.json")) { error in
            XCTAssertTrue("\(error)".contains("steps[0].en must be an object"))
        }
    }

    // MARK: environments

    private let rung = """
    {"id":"r%d","difficulty":%d,"distractionKind":"none","sortOrder":%d,
     "thresholdMetres":null,"names":{"pl":"p","en":"e"}}
    """

    func testDifficultyWindowMonotonicityAndDuplicates() throws {
        let good = String(format: rung, 1, 3, 1)
        let low = String(format: rung, 0, 0, 1) // difficulty 0 → below window
        XCTAssertThrowsError(try EnvironmentValidator.parseEnvironments(
            json("[\(low)]"), source: "environments.json")) { error in
            XCTAssertTrue("\(error)".contains("difficulty must be between 1 and 10"))
        }
        // Going down the ladder is rejected; ties are allowed.
        let down = [String(format: rung, 1, 5, 1), String(format: rung, 2, 2, 2)].joined(separator: ",")
        XCTAssertThrowsError(try EnvironmentValidator.parseEnvironments(
            json("[\(down)]"), source: "environments.json")) { error in
            XCTAssertTrue("\(error)".contains("must not be below 'r1' at 5.0"))
        }
        let dup = [String(format: rung, 1, 3, 1), String(format: rung, 1, 3, 2)].joined(separator: ",")
        XCTAssertThrowsError(try EnvironmentValidator.parseEnvironments(
            json("[\(dup)]"), source: "environments.json")) { error in
            XCTAssertTrue("\(error)".contains("id 'r1' is already used"))
        }
        _ = good
    }

    func testSetReferencesMustResolve() throws {
        let body = """
        {"environments":[\(String(format: rung, 1, 3, 1))],
         "startingEnvironmentId":"nowhere","beyondPuppyScope":["ghost"],
         "categoryOrder":["foundation","impulse_control","advanced"]}
        """
        XCTAssertThrowsError(try EnvironmentValidator.parseEnvironmentSet(
            json(body), source: "environments.json")) { error in
            XCTAssertTrue("\(error)".contains("startingEnvironmentId names 'nowhere'"))
        }
    }

    // MARK: nosework / behaviour / mistakes / references

    func testNoseworkMinutesMustBePositive() throws {
        let activity = """
        {"id":"n","pose":"sniff","sortOrder":1,
         "names":{"pl":{"name":"n","description":"d"},"en":{"name":"n","description":"d"}},
         "tagline":{"pl":"t","en":"t"},
         "levels":[{"ordinal":1,"minutes":0,"gear":["treats"],
           "pl":{"title":"t","setup":"s","how":"h","watchFor":"w"},
           "en":{"title":"t","setup":"s","how":"h","watchFor":"w"}}]}
        """
        XCTAssertThrowsError(try NoseworkValidator.parseActivity(
            json(activity), source: "nosework/n.json")) { error in
            XCTAssertTrue("\(error)".contains("levels[0].minutes must be more than 0"))
        }
    }

    func testBehaviourEmptyAvoidListIsRejected() throws {
        let card = """
        {"id":"b","sortOrder":1,
         "names":{"pl":{"name":"n","tagline":"t"},"en":{"name":"n","tagline":"t"}},
         "recognizes":{"pl":"r","en":"r"},"urgent":{"pl":"u","en":"u"},
         "avoid":{"pl":[],"en":[]},
         "now":{"pl":["x"],"en":["y"]},"work":{"pl":["x"],"en":["y"]},
         "professional":{"pl":"p","en":"p"},"practices":["sit"]}
        """
        XCTAssertThrowsError(try BehaviourValidator.parseIssue(
            json(card), source: "behaviour/b.json")) { error in
            XCTAssertTrue("\(error)".contains("avoid.pl must list something"))
        }
    }

    // MARK: puppy-start extensions (optional, but never half-written)

    private var behaviourCore: String {
        """
        {"id":"b","sortOrder":1,
         "names":{"pl":{"name":"n","tagline":"t"},"en":{"name":"n","tagline":"t"}},
         "recognizes":{"pl":"r","en":"r"},"urgent":{"pl":"u","en":"u"},
         "avoid":{"pl":["x"],"en":["y"]},
         "now":{"pl":["x"],"en":["y"]},"work":{"pl":["x"],"en":["y"]},
         "professional":{"pl":"p","en":"p"},"practices":["sit"]
        """
    }

    private func parseBehaviour(_ tail: String) throws -> BehaviourIssue {
        try BehaviourValidator.parseIssue(
            json(behaviourCore + tail + "}"), source: "behaviour/b.json")
    }

    func testBehaviourWithoutExtensionsStillParses() throws {
        // The compatibility rule: old cards are untouched by the new fields.
        let card = try parseBehaviour("")
        XCTAssertNil(card.observe)
        XCTAssertNil(card.evidence)
    }

    func testBehaviourObserveMissingOneLocaleFails() {
        XCTAssertThrowsError(try parseBehaviour(
            #","observe":{"pl":["a"]}"#)) { error in
            XCTAssertTrue("\(error)".contains("observe.en"), "\(error)")
        }
    }

    func testBehaviourObserveEmptyListIsAHalfEdit() {
        XCTAssertThrowsError(try parseBehaviour(
            #","observe":{"pl":[],"en":[]}"#)) { error in
            XCTAssertTrue("\(error)".contains("observe.pl must list something"), "\(error)")
        }
    }

    func testBehaviourMalformedEvidenceFailsRatherThanIgnored() {
        XCTAssertThrowsError(try parseBehaviour(
            #","evidence":{"verifiedOn":"2026-01-01","sources":[{"title":"T","url":"http://x.example/a"}]}"#
        )) { error in
            XCTAssertTrue("\(error)".contains("https:// address"), "\(error)")
        }
    }

    func testBehaviourCompleteEvidenceParses() throws {
        let card = try parseBehaviour(
            #","evidence":{"verifiedOn":"2026-01-01","sources":[{"title":"T","url":"https://x.example/a"}]}"#
        )
        XCTAssertEqual(card.evidence?.sources.count, 1)
        XCTAssertEqual(card.evidence?.verifiedOn, "2026-01-01")
    }

    func testMistakeEntryRequiresAllThreePartsInBothLocales() throws {
        XCTAssertThrowsError(try MistakeValidator.parseMistakes(
            json("""
            [{"pl":{"symptom":"s","why":"w","fix":"f"},
              "en":{"symptom":"s","why":"w"}}]
            """), source: "mistakes/sit.json")) { error in
            XCTAssertTrue("\(error)".contains("mistakes/sit.json: [0].en.fix must be a string"))
        }
    }

    func testPracticesProblemsNameBothSidesOfABrokenLink() throws {
        func makeIssue(id: String, practices: [String]) throws -> BehaviourIssue {
            let practicesJSON = practices.map { "\"\($0)\"" }.joined(separator: ",")
            let card = """
            {"id":"\(id)","sortOrder":1,
             "names":{"pl":{"name":"n","tagline":"t"},"en":{"name":"n","tagline":"t"}},
             "recognizes":{"pl":"r","en":"r"},"urgent":{"pl":"u","en":"u"},
             "avoid":{"pl":["x"],"en":["y"]},
             "now":{"pl":["x"],"en":["y"]},"work":{"pl":["x"],"en":["y"]},
             "professional":{"pl":"p","en":"p"},"practices":[\(practicesJSON)]}
            """
            return try BehaviourValidator.parseIssue(try json(card), source: "behaviour/\(id).json")
        }
        let issues = [try makeIssue(id: "b", practices: ["sit", "telepathy"])]
        XCTAssertEqual(
            TrainingContent.practicesProblems(behaviour: issues, knownExerciseIds: ["sit"]),
            ["behaviour/b points at unknown exercise 'telepathy'"]
        )
    }
}
