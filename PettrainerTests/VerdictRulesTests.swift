import XCTest
@testable import Pettrainer

/// Ported 1:1 from `src/domain/verdict.test.ts`.
final class VerdictRulesTests: XCTestCase {

    /// A set of `max(hits, setSize)`-style length with `hits` hits and the rest
    /// `filler` — mirrors the JS helper, which also builds over-long sets (6, 8,
    /// 9 reps) on purpose to check the rejection paths.
    private func setWithHits(_ hits: Int, filler: RepOutcome = .miss) -> [RepOutcome] {
        (0..<hits).map { _ in .hit } + (0..<max(0, TrainingRules.setSize - hits)).map { _ in filler }
    }

    private let verdictTable: [(hits: Int, expected: Verdict)] = [
        (5, .push), (4, .stick), (3, .stick), (2, .drop), (1, .drop), (0, .drop),
    ]

    func testSetSizeIsFive() {
        XCTAssertEqual(TrainingRules.setSize, 5)
    }

    func testCountHitsTreatsCancellationsLikeMisses() {
        XCTAssertEqual(VerdictRules.countHits([]), 0)
        XCTAssertEqual(VerdictRules.countHits(Array(repeating: .miss, count: 5)), 0)
        XCTAssertEqual(VerdictRules.countHits(Array(repeating: .cancelled, count: 5)), 0)
        XCTAssertEqual(VerdictRules.countHits(Array(repeating: .hit, count: 5)), 5)
        XCTAssertEqual(VerdictRules.countHits([.hit, .miss, .hit, .cancelled, .hit]), 3)
    }

    func testVerdictTable() throws {
        for row in verdictTable {
            XCTAssertEqual(try VerdictRules.verdictForSet(setWithHits(row.hits)), row.expected)
        }
    }

    func testPushRequiresAPerfectSet() throws {
        // The rule most often got wrong: 4/5 is stick, not push.
        let four = try VerdictRules.verdictForSet(setWithHits(4))
        XCTAssertEqual(four, .stick)
        XCTAssertNotEqual(four, .push)
        XCTAssertEqual(try VerdictRules.verdictForSet(setWithHits(5)), .push)
    }

    func testCancelledRepCountsExactlyLikeAMiss() throws {
        let cancelled: [RepOutcome] = [.hit, .hit, .hit, .cancelled, .cancelled]
        let missed: [RepOutcome] = [.hit, .hit, .hit, .miss, .miss]
        XCTAssertEqual(try VerdictRules.verdictForSet(cancelled), try VerdictRules.verdictForSet(missed))
        XCTAssertEqual(VerdictRules.countHits(cancelled), VerdictRules.countHits(missed))
        XCTAssertEqual(try VerdictRules.verdictSoFar(cancelled), try VerdictRules.verdictSoFar(missed))
        XCTAssertEqual(try VerdictRules.isVerdictDecided(cancelled), try VerdictRules.isVerdictDecided(missed))
        XCTAssertEqual(try VerdictRules.verdictForSet(cancelled), .stick)
    }

    func testOrderOfOutcomesDoesNotMatter() throws {
        let permutations: [[RepOutcome]] = [
            [.hit, .hit, .hit, .miss, .miss],
            [.miss, .hit, .miss, .hit, .hit],
            [.miss, .miss, .hit, .hit, .hit],
            [.hit, .miss, .hit, .miss, .hit],
            [.miss, .hit, .miss, .miss, .hit],
        ]
        let verdicts = try permutations.map(VerdictRules.verdictForSet)
        XCTAssertEqual(verdicts, [.stick, .stick, .stick, .stick, .drop])
    }

    func testVerdictForSetRejectsWrongLengths() {
        XCTAssertThrowsError(try VerdictRules.verdictForSet([]))
        XCTAssertThrowsError(try VerdictRules.verdictForSet([.hit, .hit, .hit]))
        XCTAssertThrowsError(try VerdictRules.verdictForSet(setWithHits(5) + [.hit]))
        XCTAssertThrowsError(try VerdictRules.verdictForSet(setWithHits(9)))
    }

    func testErrorMessageNamesTheOffendingLength() {
        XCTAssertThrowsError(try VerdictRules.verdictForSet(setWithHits(5) + [.miss])) { error in
            XCTAssertEqual("\(error)", "expected 5 reps, got 6")
        }
    }

    func testVerdictSoFarIsNilUntilTheSetIsFull() throws {
        for count in 0...4 {
            let partial = Array(repeating: RepOutcome.hit, count: count)
            XCTAssertNil(try VerdictRules.verdictSoFar(partial))
        }
    }

    func testVerdictSoFarMatchesVerdictForSetWhenFull() throws {
        for row in verdictTable {
            let set = setWithHits(row.hits)
            XCTAssertEqual(try VerdictRules.verdictSoFar(set), row.expected)
            XCTAssertEqual(try VerdictRules.verdictSoFar(set), try VerdictRules.verdictForSet(set))
        }
    }

    func testVerdictSoFarRejectsMoreThanFive() {
        XCTAssertThrowsError(try VerdictRules.verdictSoFar(setWithHits(5) + [.hit]))
        XCTAssertThrowsError(try VerdictRules.verdictSoFar(setWithHits(8)))
    }

    func testDecidedIsFalseForEmptySet() throws {
        XCTAssertFalse(try VerdictRules.isVerdictDecided([]))
    }

    func testDecidedOnceThreeFailuresOccurred() throws {
        XCTAssertFalse(try VerdictRules.isVerdictDecided([]))
        XCTAssertTrue(try VerdictRules.isVerdictDecided([.miss, .miss, .cancelled]))
        XCTAssertTrue(try VerdictRules.isVerdictDecided([.cancelled, .hit, .miss, .miss]))
        XCTAssertTrue(try VerdictRules.isVerdictDecided([.miss, .miss, .hit, .hit, .miss]))
    }

    func testDecidedForCompleteSets() throws {
        XCTAssertTrue(try VerdictRules.isVerdictDecided(setWithHits(5)))
        XCTAssertTrue(try VerdictRules.isVerdictDecided(setWithHits(3)))
        XCTAssertTrue(try VerdictRules.isVerdictDecided(setWithHits(0)))
    }

    func testUndecidedWhileEitherBandIsReachable() throws {
        // 3 hits in 3 reps: all-hits ends push, any miss ends stick.
        XCTAssertFalse(try VerdictRules.isVerdictDecided([.hit, .hit, .hit]))
        // 2 hits in 3 reps: stick or drop still open.
        XCTAssertFalse(try VerdictRules.isVerdictDecided([.hit, .hit, .miss]))
        // 1 hit in 2 reps.
        XCTAssertFalse(try VerdictRules.isVerdictDecided([.hit, .miss]))
        // 2 hits in 4 reps: push out of reach, stick and drop both remain.
        XCTAssertFalse(try VerdictRules.isVerdictDecided([.hit, .miss, .hit, .miss]))
    }

    func testIsVerdictDecidedRejectsMoreThanFive() {
        XCTAssertThrowsError(try VerdictRules.isVerdictDecided(setWithHits(5) + [.hit]))
        XCTAssertThrowsError(try VerdictRules.isVerdictDecided(setWithHits(7)))
    }

    func testNextStepIndexMovesAndClamps() throws {
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 2, maxIndex: 5, verdict: .push), 3)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 0, maxIndex: 5, verdict: .push), 1)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 2, maxIndex: 5, verdict: .drop), 1)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 5, maxIndex: 5, verdict: .drop), 4)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 2, maxIndex: 5, verdict: .stick), 2)
        // Clamps at both ends instead of throwing.
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 5, maxIndex: 5, verdict: .push), 5)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 4, maxIndex: 4, verdict: .push), 4)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 0, maxIndex: 0, verdict: .push), 0)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 0, maxIndex: 5, verdict: .drop), 0)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 1, maxIndex: 1, verdict: .drop), 0)
        XCTAssertEqual(try VerdictRules.nextStepIndex(current: 0, maxIndex: 0, verdict: .drop), 0)
    }

    func testNextStepIndexStaysInsideLadderAlways() throws {
        for maxIndex in 0..<TrainingRules.setSize {
            for index in 0...maxIndex {
                for verdict in [Verdict.push, .stick, .drop] {
                    let next = try VerdictRules.nextStepIndex(current: index, maxIndex: maxIndex, verdict: verdict)
                    XCTAssertGreaterThanOrEqual(next, 0)
                    XCTAssertLessThanOrEqual(next, maxIndex)
                }
            }
        }
    }

    func testNextStepIndexRejectsInvalidArguments() {
        XCTAssertThrowsError(try VerdictRules.nextStepIndex(current: -1, maxIndex: 5, verdict: .push))
        XCTAssertThrowsError(try VerdictRules.nextStepIndex(current: 6, maxIndex: 5, verdict: .push))
        XCTAssertThrowsError(try VerdictRules.nextStepIndex(current: 1, maxIndex: 0, verdict: .stick))
        XCTAssertThrowsError(try VerdictRules.nextStepIndex(current: 0, maxIndex: -1, verdict: .push))
    }

    func testNextStepIndexErrorMessages() {
        XCTAssertThrowsError(try VerdictRules.nextStepIndex(current: 6, maxIndex: 5, verdict: .push)) { error in
            XCTAssertEqual("\(error)", "currentIndex must be within [0, 5], got 6")
        }
        XCTAssertThrowsError(try VerdictRules.nextStepIndex(current: 0, maxIndex: -1, verdict: .push)) { error in
            XCTAssertEqual("\(error)", "maxIndex must be at least 0, got -1")
        }
    }
}
