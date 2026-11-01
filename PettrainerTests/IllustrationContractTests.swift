import XCTest
@testable import Pettrainer

/// Structural parity checks for the ported illustration layer. Screenshots
/// verify pixels at task 8.2; these guard the parts that are data.
final class IllustrationContractTests: XCTestCase {

    func testEveryMotionHasMarksAndArrowsWithinVocabulary() {
        XCTAssertTrue(StepDiagramMarks.completeCoverage,
                      "MARKS lost a motion during the port")
        // Arrow sets must name real motions that actually have curves.
        for motion in StepDiagramMarks.lureArrows {
            XCTAssertNotNil(StepDiagramMarks.marks[motion]?.curve)
        }
        for motion in StepDiagramMarks.foodDots {
            XCTAssertNotNil(StepDiagramMarks.marks[motion]?.from)
        }
    }

    func testMarkStringsParseWithTheSVGParser() {
        // Every curve/head literal must parse without trapping.
        for marks in StepDiagramMarks.marks.values {
            if let curve = marks.curve { _ = SVGPathParser.path(curve) }
            if let head = marks.head { _ = SVGPathParser.path(head) }
        }
    }

    func testLureStageBoundariesMatchTheJSTable() {
        XCTAssertEqual(LureStages.stage(exerciseId: "sit", stepOrdinal: 5), .lure)
        XCTAssertEqual(LureStages.stage(exerciseId: "sit", stepOrdinal: 6), .emptyHand)
        XCTAssertEqual(LureStages.stage(exerciseId: "sit", stepOrdinal: 8), .emptyHand)
        XCTAssertEqual(LureStages.stage(exerciseId: "sit", stepOrdinal: 9), .verbal)
        XCTAssertEqual(LureStages.stage(exerciseId: "look", stepOrdinal: 2), .lure)
        XCTAssertEqual(LureStages.stage(exerciseId: "look", stepOrdinal: 3), .emptyHand)
        XCTAssertEqual(LureStages.stage(exerciseId: "look", stepOrdinal: 4), .verbal)
        // Exercises without a fade never leave the lure stage.
        XCTAssertEqual(LureStages.stage(exerciseId: "come", stepOrdinal: 99), .lure)
        XCTAssertEqual(LureStages.stage(exerciseId: "leash", stepOrdinal: 1), .lure)
        // name/stay/wait: lureUntil 0 means empty-hand from step 1 up to handUntil 0 → verbal? JS: stepOrdinal(1) <= 0 false; <=0 false → verbal.
        XCTAssertEqual(LureStages.stage(exerciseId: "name", stepOrdinal: 1), .verbal)
    }

    func testMotionByExerciseMatchesBaseline() {
        XCTAssertEqual(MotionByExercise.values.count, 12)
        XCTAssertEqual(MotionByExercise.motion(forExerciseId: "sit"), .up)
        XCTAssertEqual(MotionByExercise.motion(forExerciseId: "handling"), .contact)
        XCTAssertEqual(MotionByExercise.motion(forExerciseId: "leash"), .away)
        XCTAssertNil(MotionByExercise.motion(forExerciseId: "ghost"))
    }

    func testProblemScenesCoverEveryCard() {
        // Every shipped welfare card renders a thumbnail in its row (6.6 rule);
        // the puppy-start cards joined the set, so the list is every id.
        let ids = ["bark-door", "bark-window", "jumping", "nipping", "stealing",
                   "bolting", "reactivity", "traffic", "noise", "alone",
                   "mounting", "bed", "overarousal", "fear-withdrawal"]
        for id in ids { XCTAssertTrue(ProblemScene.exists(id: id), "missing scene: \(id)") }
        XCTAssertFalse(ProblemScene.exists(id: "unknown"))
    }

    func testSVGParserHandlesTemplateBuiltPaths() {
        // CrossedTreat-style interpolation, e.g. "M 83 65 L 101 83". Parsing
        // without trapping is the assertion (SwiftUI Path has no useful
        // description); malformed input would trap the parser.
        let x = 92.0, y = 74.0
        _ = SVGPathParser.path("M \(x - 9) \(y - 9) L \(x + 9) \(y + 9)")
    }
}
