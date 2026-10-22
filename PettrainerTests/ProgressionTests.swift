import XCTest
@testable import Pettrainer

/// Ported 1:1 from `src/domain/progression.test.ts`. The TS suite used the
/// real 23-rung ladder; the behaviour under test only needs its ordering, so
/// these tests use a synthetic ladder with the same shape. The real ladder is
/// exercised through the content tests once the loader exists.
final class ProgressionTests: XCTestCase {

    private let ladder = ["quiet-room", "second", "third", "fourth", "last"]
    private let start = "quiet-room"
    private var second: String { ladder[1] }
    private var last: String { ladder[4] }

    func testStepAfterEnvironmentChangeDropsBackWithoutRestarting() throws {
        // The early steps install the behaviour and carry over; only the last
        // stretch is rebuilt in a new place.
        XCTAssertEqual(try Progression.stepAfterEnvironmentChange(stepCount: 10), 6)
        XCTAssertEqual(try Progression.stepAfterEnvironmentChange(stepCount: 7), 5)
        XCTAssertEqual(try Progression.stepAfterEnvironmentChange(stepCount: 4), 3)
    }

    func testStepAfterEnvironmentChangeNeverBelowOne() throws {
        XCTAssertEqual(try Progression.stepAfterEnvironmentChange(stepCount: 1), 1)
    }

    func testStepAfterEnvironmentChangeRejectsNonsensicalLadders() {
        XCTAssertThrowsError(try Progression.stepAfterEnvironmentChange(stepCount: 0))
        XCTAssertThrowsError(try Progression.stepAfterEnvironmentChange(stepCount: -3))
    }

    func testEnvironmentNeighboursWalkTheLadder() throws {
        XCTAssertEqual(try Progression.nextEnvironment(start, ladder: ladder), second)
        XCTAssertEqual(try Progression.previousEnvironment(second, ladder: ladder), start)
    }

    func testNoRungBelowTheFirstOrAboveTheLast() throws {
        XCTAssertNil(try Progression.previousEnvironment(start, ladder: ladder))
        XCTAssertNil(try Progression.nextEnvironment(last, ladder: ladder))
    }

    func testNeighboursThrowForUnknownEnvironment() {
        XCTAssertThrowsError(try Progression.nextEnvironment("nowhere", ladder: ladder))
        XCTAssertThrowsError(try Progression.previousEnvironment("nowhere", ladder: ladder))
    }

    func testStepWithinTheLadderDoesNotTouchTheEnvironment() throws {
        let here = Position(stepOrdinal: 4, environmentId: start)
        let after = try Progression.move(here, stepCount: 10, delta: 1, ladder: ladder)
        XCTAssertEqual(after, Position(stepOrdinal: 5, environmentId: start))
    }

    func testRollsOverToAHarderEnvironmentAtTheTop() throws {
        // The move the whole product exists for.
        let here = Position(stepOrdinal: 10, environmentId: start)
        let after = try Progression.move(here, stepCount: 10, delta: 1, ladder: ladder)
        XCTAssertEqual(after.environmentId, second)
        XCTAssertEqual(after.stepOrdinal, 6)
    }

    func testNeverAdvancesBothAxesAtOnce() throws {
        let before = Position(stepOrdinal: 10, environmentId: start)
        let after = try Progression.move(before, stepCount: 10, delta: 1, ladder: ladder)
        XCTAssertNotEqual(after.environmentId, before.environmentId)
        XCTAssertLessThan(after.stepOrdinal, before.stepOrdinal)
    }

    func testRollsBackToThePreviousEnvironmentBelowStepOne() throws {
        let here = Position(stepOrdinal: 1, environmentId: second)
        let after = try Progression.move(here, stepCount: 10, delta: -1, ladder: ladder)
        XCTAssertEqual(after, Position(stepOrdinal: 10, environmentId: start))
    }

    func testClampsAtTheVeryTopAndTheVeryBottom() throws {
        let bottom = Position(stepOrdinal: 1, environmentId: start)
        XCTAssertEqual(try Progression.move(bottom, stepCount: 10, delta: -1, ladder: ladder), bottom)
        let top = Position(stepOrdinal: 10, environmentId: last)
        XCTAssertEqual(try Progression.move(top, stepCount: 10, delta: 1, ladder: ladder), top)
    }

    func testDeltaZeroChangesNothing() throws {
        let here = Position(stepOrdinal: 3, environmentId: second)
        XCTAssertEqual(try Progression.move(here, stepCount: 10, delta: 0, ladder: ladder), here)
    }

    func testMovesStayInsideTheLadderForEveryStepAndDirection() throws {
        for step in 1...10 {
            for delta in [-1, 1] {
                let after = try Progression.move(
                    Position(stepOrdinal: step, environmentId: second),
                    stepCount: 10, delta: delta, ladder: ladder
                )
                XCTAssertGreaterThanOrEqual(after.stepOrdinal, 1)
                XCTAssertLessThanOrEqual(after.stepOrdinal, 10)
                XCTAssertTrue(ladder.contains(after.environmentId))
            }
        }
    }

    func testLadderCompleteOnlyAtTheLastStep() {
        XCTAssertFalse(Progression.isLadderComplete(
            Position(stepOrdinal: 9, environmentId: second), stepCount: 10))
        XCTAssertTrue(Progression.isLadderComplete(
            Position(stepOrdinal: 10, environmentId: second), stepCount: 10))
    }

    func testFullyGeneralizedOnlyOnTheHardestRung() throws {
        // Finishing the steps in a quiet room is one rung of mastery, not mastery.
        XCTAssertFalse(try Progression.isFullyGeneralized(
            Position(stepOrdinal: 10, environmentId: start), stepCount: 10, ladder: ladder))
        XCTAssertTrue(try Progression.isFullyGeneralized(
            Position(stepOrdinal: 10, environmentId: last), stepCount: 10, ladder: ladder))
        XCTAssertFalse(try Progression.isFullyGeneralized(
            Position(stepOrdinal: 9, environmentId: last), stepCount: 10, ladder: ladder))
    }

    func testRungsClearedCountsCompletedEnvironments() {
        XCTAssertEqual(Progression.rungsCleared(
            Position(stepOrdinal: 5, environmentId: start), stepCount: 10, ladder: ladder), 0)
        XCTAssertEqual(Progression.rungsCleared(
            Position(stepOrdinal: 10, environmentId: start), stepCount: 10, ladder: ladder), 1)
        XCTAssertEqual(Progression.rungsCleared(
            Position(stepOrdinal: 6, environmentId: second), stepCount: 10, ladder: ladder), 1)
        XCTAssertEqual(Progression.rungsCleared(
            Position(stepOrdinal: 10, environmentId: last), stepCount: 10, ladder: ladder), ladder.count)
        // Unknown environment reads as zero, like the TS behaviour.
        XCTAssertEqual(Progression.rungsCleared(
            Position(stepOrdinal: 10, environmentId: "nowhere"), stepCount: 10, ladder: ladder), 0)
    }
}
