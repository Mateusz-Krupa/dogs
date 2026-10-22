import XCTest
@testable import Pettrainer

/// Ported 1:1 from `src/features/session/setMachine.test.ts`.
final class SetStateTests: XCTestCase {

    private func recordAll(_ state: SetState, _ outcomes: [RepOutcome]) -> SetState {
        outcomes.reduce(state) { $0.applying(.record($1)) }
    }

    private func setWithHits(_ hits: Int) -> [RepOutcome] {
        (0..<hits).map { _ in .hit } + (0..<max(0, TrainingRules.setSize - hits)).map { _ in .miss }
    }

    private func stateWithHits(_ hits: Int) -> SetState {
        recordAll(.empty, setWithHits(hits))
    }

    func testInitialStateIsEmptyAndUndecided() {
        XCTAssertEqual(SetState.empty.reps, [])
        XCTAssertNil(SetState.empty.verdict)
        XCTAssertFalse(SetState.empty.decided)
    }

    func testRecordAppendsInOrder() {
        let state = recordAll(.empty, [.hit, .miss, .cancelled])
        XCTAssertEqual(state.reps, [.hit, .miss, .cancelled])
        XCTAssertNil(state.verdict)
    }

    func testFiveHitsIsPushAndDecided() {
        let state = recordAll(.empty, Array(repeating: .hit, count: 5))
        XCTAssertEqual(state.verdict, .push)
        XCTAssertTrue(state.decided)
    }

    func testDecidedIncompleteSetStillHasNoVerdict() {
        // `decided` means the outcome cannot change; `verdict` waits for the
        // set to be actually complete.
        let state = recordAll(.empty, [.miss, .miss, .miss])
        XCTAssertTrue(state.decided)
        XCTAssertNil(state.verdict)
        XCTAssertEqual(state.reps.count, 3)
    }

    func testSixthRecordIsIgnored() {
        let complete = stateWithHits(3)
        XCTAssertEqual(complete.reps.count, TrainingRules.setSize)
        let after = complete.applying(.record(.hit))
        XCTAssertEqual(after, complete)
        XCTAssertEqual(after.reps.count, TrainingRules.setSize)
    }

    func testUndoRemovesExactlyTheLastRep() {
        let before = recordAll(.empty, [.hit, .hit, .miss])
        let after = before.applying(.undo)
        XCTAssertEqual(after.reps, [.hit, .hit])
    }

    func testUndoReopensACompleteSet() {
        let complete = stateWithHits(4)
        XCTAssertEqual(complete.verdict, .stick)
        let after = complete.applying(.undo)
        XCTAssertNil(after.verdict)
        XCTAssertEqual(after.reps.count, TrainingRules.setSize - 1)
    }

    func testUndoOnEmptySetIsANoOp() {
        let empty = SetState.empty
        XCTAssertEqual(empty.applying(.undo), empty)
    }

    func testResetReturnsInitialStateFromAnyState() {
        let sources: [SetState] = [
            .empty,
            recordAll(.empty, [.hit, .miss]),
            stateWithHits(5),
            recordAll(.empty, [.miss, .miss, .miss]),
        ]
        for source in sources {
            XCTAssertEqual(source.applying(.reset), SetState.empty)
        }
    }

    func testActionsNeverMutateInputReps() {
        let state = recordAll(.empty, [.hit, .hit, .miss, .miss])
        let snapshot = state.reps
        for action in [SetState.Action.record(.hit), .record(.miss), .undo, .reset] {
            _ = state.applying(action)
            XCTAssertEqual(state.reps, snapshot)
        }
        XCTAssertEqual(state.reps.count, 4)
    }

    func testReducerAgreesWithDomainRuleForEveryHitCount() throws {
        for hits in 0...TrainingRules.setSize {
            let expected = try VerdictRules.verdictForSet(setWithHits(hits))
            XCTAssertEqual(stateWithHits(hits).verdict, expected)
        }
    }
}
