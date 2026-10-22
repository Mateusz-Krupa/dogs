import XCTest
@testable import Pettrainer

/// Covers tasks 4.3–4.5 behaviour contracts: commit-before-ack, interruption
/// recovery, owner-choice idempotency, and the F-2 mastery earning rule.
final class SessionRepositoryTests: XCTestCase {

    private typealias Value = SQLiteDatabase.Value

    private var directory: URL!
    private var url: URL!
    private var db: SQLiteDatabase!
    private var progress: ProgressRepository!
    private var sessions: SessionRepository!
    private var clock: String = "2026-03-01T00:00:00Z"

    private let ladder = ["quiet-room", "garden", "street"]

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("pettrainer-sess-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("test.sqlite")
        db = try SQLiteDatabase(url: url)
        _ = try MigrationRunner.runMigrations(on: db)
        try seedContent()
        progress = ProgressRepository(db: db) { [self] in clock }
        sessions = SessionRepository(db: db, progress: progress) { [self] in clock }
        clock = "2026-03-01T00:00:00Z"
    }

    override func tearDown() {
        db = nil
        try? FileManager.default.removeItem(at: directory)
    }

    /// Minimal seeded content: one two-step exercise, three environments.
    private func seedContent() throws {
        try db.exec("""
        INSERT INTO exercise VALUES ('sit','foundation',1);
        INSERT INTO step VALUES ('sit#1','sit',1,NULL), ('sit#2','sit',2,NULL);
        INSERT INTO environment VALUES
          ('quiet-room',1,'none',1), ('garden',5,'outdoor_novelty',2), ('street',8,'dogs',3);
        """)
    }

    private func dog() throws -> String { try progress.ensureDefaultDog() }

    /// Kill/relaunch simulation: a second connection to the same file sees
    /// everything the first one acknowledged.
    private func reopen() throws -> SQLiteDatabase {
        let reopened = try SQLiteDatabase(url: url)
        _ = try MigrationRunner.runMigrations(on: reopened)
        db = reopened
        progress = ProgressRepository(db: reopened) { [self] in clock }
        sessions = SessionRepository(db: reopened, progress: progress) { [self] in clock }
        return reopened
    }

    private func advanceClock() { clock += "1" } // unique, still ISO-sortable-ish

    // MARK: commit-before-ack + interruption (F-1)

    func testRepsSurviveReopenAndResume() throws {
        let dogId = try dog()
        var set = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                            environmentId: "quiet-room", stepId: "sit#1")
        _ = try sessions.recordRep(.hit, sessionId: set.sessionId)
        _ = try sessions.recordRep(.miss, sessionId: set.sessionId)
        _ = try sessions.recordRep(.cancelled, sessionId: set.sessionId)

        try reopen()
        set = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                        environmentId: "quiet-room", stepId: "sit#1")
        XCTAssertEqual(set.reps, [.hit, .miss, .cancelled])
        XCTAssertNil(set.verdict) // incomplete set → no completed verdict
    }

    func testFifthRepCompletesAtomicallyAndSurvivesKill() throws {
        let dogId = try dog()
        let set = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                            environmentId: "quiet-room", stepId: "sit#1")
        var current = set
        for outcome in [RepOutcome.hit, .hit, .hit, .hit] {
            current = try sessions.recordRep(outcome, sessionId: current.sessionId)
        }
        XCTAssertEqual(current.lifecycle, .active)
        current = try sessions.recordRep(.hit, sessionId: current.sessionId)
        XCTAssertEqual(current.lifecycle, .completed)
        XCTAssertEqual(current.verdict, .push)

        try reopen()
        let resumed = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                                environmentId: "quiet-room", stepId: "sit#1")
        XCTAssertEqual(resumed.lifecycle, .completed) // F-1: pending choice surfaces
        XCTAssertEqual(resumed.reps.count, 5)
    }

    func testSuccessorSetIsCreatedOnDemandNotPreCreated() throws {
        let dogId = try dog()
        let set = try completeSet(dogId: dogId, outcomes: [.hit, .hit, .hit, .hit, .hit])
        let applied = try progress.applyOwnerChoice(
            sessionId: set.sessionId, dogId: dogId, exerciseId: "sit",
            delta: 1, stepCount: 2, ladder: ladder, startingEnvironmentId: "quiet-room")
        XCTAssertTrue(applied)
        let openSessions = try db.query("SELECT COUNT(*) AS n FROM session WHERE lifecycle = 'active';")
        if case .integer(let n)? = openSessions.first?["n"] { XCTAssertEqual(n, 0) }
        else { XCTFail() }
    }

    func testChoiceIsIdempotentUnderDuplicateTaps() throws {
        let dogId = try dog()
        let set = try completeSet(dogId: dogId, outcomes: [.hit, .hit, .hit, .miss, .hit])
        // 4/5 → stick… wait: that is still 4 hits → stick. Choice +1 is legal
        // (owner decides), applied once:
        let first = try progress.applyOwnerChoice(
            sessionId: set.sessionId, dogId: dogId, exerciseId: "sit",
            delta: 1, stepCount: 2, ladder: ladder, startingEnvironmentId: "quiet-room")
        let second = try progress.applyOwnerChoice(
            sessionId: set.sessionId, dogId: dogId, exerciseId: "sit",
            delta: 1, stepCount: 2, ladder: ladder, startingEnvironmentId: "quiet-room")
        XCTAssertTrue(first)
        XCTAssertFalse(second)
        let position = try progress.position(dogId: dogId, exerciseId: "sit",
                                             startingEnvironmentId: "quiet-room")
        XCTAssertEqual(position, Position(stepOrdinal: 2, environmentId: "quiet-room"))
    }

    // MARK: undo rules

    func testUndoReopensCompletedSetUntilChoice() throws {
        let dogId = try dog()
        let set = try completeSet(dogId: dogId, outcomes: [.hit, .hit, .hit, .hit, .hit])
        let undone = try sessions.undoLastRep(sessionId: set.sessionId)
        XCTAssertEqual(undone.reps.count, 4)
        XCTAssertEqual(undone.lifecycle, .active)
        // Mastery of the undone, never-chosen push set is rolled back to raw truth.
        let mastery = try progress.mastery(dogId: dogId)
        XCTAssertNil(mastery["sit"]?["quiet-room"])

        // A fresh fifth rep can be recorded again.
        _ = try sessions.recordRep(.miss, sessionId: set.sessionId)
        let again = try sessions.set(sessionId: set.sessionId)
        XCTAssertEqual(again.lifecycle, .completed)
    }

    func testUndoAfterCommittedChoiceIsRefused() throws {
        let dogId = try dog()
        let set = try completeSet(dogId: dogId, outcomes: [.hit, .hit, .hit, .hit, .hit])
        _ = try progress.applyOwnerChoice(
            sessionId: set.sessionId, dogId: dogId, exerciseId: "sit",
            delta: 0, stepCount: 2, ladder: ladder, startingEnvironmentId: "quiet-room")
        XCTAssertThrowsError(try sessions.undoLastRep(sessionId: set.sessionId)) { error in
            XCTAssertEqual("\(error)", RepositoryError.choiceAlreadyApplied(set.sessionId).description)
        }
    }

    func testUndoOnEmptyAndAbandonedSets() throws {
        let dogId = try dog()
        let set = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                            environmentId: "quiet-room", stepId: "sit#1")
        XCTAssertThrowsError(try sessions.undoLastRep(sessionId: set.sessionId))
        let abandoned = try sessions.abandon(sessionId: set.sessionId)
        XCTAssertEqual(abandoned.lifecycle, .abandoned)
        XCTAssertEqual(abandoned.reps, []) // raw rows retained, no verdict
        XCTAssertNil(abandoned.verdict)
    }

    // MARK: F-2 mastery earning rule

    func testMasteryOnlyFromPushSets() throws {
        let dogId = try dog()
        // stick set: 4/5 → no mastery even at the final step.
        _ = try completeSet(dogId: dogId, stepId: "sit#2",
                            outcomes: [.hit, .hit, .hit, .hit, .miss], choiceDelta: 0)
        var mastery = try progress.mastery(dogId: dogId)
        XCTAssertNil(mastery["sit"]?["quiet-room"])

        // drop set: no mastery.
        _ = try completeSet(dogId: dogId, stepId: "sit#2",
                            outcomes: [.miss, .miss, .miss, .hit, .cancelled], choiceDelta: 0)
        mastery = try progress.mastery(dogId: dogId)
        XCTAssertNil(mastery["sit"]?["quiet-room"])

        // push at step 1 → mastery 1; later push at step 2 → 2; a drop never erases.
        _ = try completeSet(dogId: dogId, stepId: "sit#1",
                            outcomes: [.hit, .hit, .hit, .hit, .hit], choiceDelta: 0)
        mastery = try progress.mastery(dogId: dogId)
        XCTAssertEqual(mastery["sit"]?["quiet-room"], 1)
        _ = try completeSet(dogId: dogId, stepId: "sit#2",
                            outcomes: [.hit, .hit, .hit, .hit, .hit], choiceDelta: 0)
        mastery = try progress.mastery(dogId: dogId)
        XCTAssertEqual(mastery["sit"]?["quiet-room"], 2)
        _ = try completeSet(dogId: dogId, stepId: "sit#1",
                            outcomes: [.miss, .miss, .miss, .miss, .miss], choiceDelta: 0)
        mastery = try progress.mastery(dogId: dogId)
        XCTAssertEqual(mastery["sit"]?["quiet-room"], 2)
    }

    func testEnteringFinalStepDoesNotFakeMastery() throws {
        let dogId = try dog()
        _ = try progress.position(dogId: dogId, exerciseId: "sit", startingEnvironmentId: "quiet-room")
        // 3/5 stick at step 1, then the owner explicitly chooses "harder".
        let stick = try completeSet(dogId: dogId, stepId: "sit#1",
                                    outcomes: [.hit, .hit, .hit, .miss, .miss], choiceDelta: 1)
        _ = stick
        let position = try progress.position(dogId: dogId, exerciseId: "sit",
                                             startingEnvironmentId: "quiet-room")
        XCTAssertEqual(position.stepOrdinal, 2) // owner advanced to the final step
        let mastery = try progress.mastery(dogId: dogId)
        XCTAssertNil(mastery["sit"]?["quiet-room"]) // … and nothing is "mastered"
    }

    // MARK: context isolation (2 dogs, env switching)

    func testContextsKeepTheirOwnProgressAcrossEnvironmentMoves() throws {
        let dogId = try dog()
        // Push step 1 → advance to step 2 in the same environment.
        let set1 = try completeSet(dogId: dogId, stepId: "sit#1",
                                   outcomes: [.hit, .hit, .hit, .hit, .hit], choiceDelta: 1)
        var position = try progress.position(dogId: dogId, exerciseId: "sit",
                                             startingEnvironmentId: "quiet-room")
        XCTAssertEqual(position, Position(stepOrdinal: 2, environmentId: "quiet-room"))

        // Push step 2 → the ladder rolls onto the harder environment at the
        // domain boundary point (ceil(2*0.6) = 2).
        _ = try completeSet(dogId: dogId, stepId: "sit#2", environmentId: "quiet-room",
                            outcomes: [.hit, .hit, .hit, .hit, .hit], choiceDelta: 1)
        _ = set1
        position = try progress.position(dogId: dogId, exerciseId: "sit",
                                         startingEnvironmentId: "quiet-room")
        XCTAssertEqual(position, Position(stepOrdinal: 2, environmentId: "garden"))

        // Walk back down: step first, then across the boundary; the return to
        // quiet-room lands on quiet-room's own stored step (2), not a fresh 1.
        _ = try completeSet(dogId: dogId, stepId: "sit#2", environmentId: "garden",
                            outcomes: [.hit, .hit, .hit, .hit, .miss], choiceDelta: -1)
        position = try progress.position(dogId: dogId, exerciseId: "sit",
                                         startingEnvironmentId: "quiet-room")
        XCTAssertEqual(position, Position(stepOrdinal: 1, environmentId: "garden"))
        _ = try completeSet(dogId: dogId, stepId: "sit#1", environmentId: "garden",
                            outcomes: [.hit, .hit, .hit, .hit, .hit], choiceDelta: -1)
        position = try progress.position(dogId: dogId, exerciseId: "sit",
                                         startingEnvironmentId: "quiet-room")
        XCTAssertEqual(position, Position(stepOrdinal: 2, environmentId: "quiet-room"))
        // quiet-room mastery survived all of that.
        let mastery = try progress.mastery(dogId: dogId)
        XCTAssertEqual(mastery["sit"]?["quiet-room"], 2)
    }

    func testTwoDogsNeverShareProgress() throws {
        let dogA = try progress.ensureDefaultDog()
        try db.run("INSERT INTO dog VALUES ('dog-b','B',NULL,'2026-01-01T00:00:00Z');")
        let dogB = "dog-b"
        _ = try completeSet(dogId: dogA, outcomes: [.hit, .hit, .hit, .hit, .hit], choiceDelta: 0)
        _ = try completeSet(dogId: dogB, stepId: "sit#1",
                            outcomes: [.miss, .miss, .hit, .miss, .hit])
        let masteryA = try progress.mastery(dogId: dogA)
        let masteryB = try progress.mastery(dogId: dogB)
        XCTAssertEqual(masteryA["sit"]?["quiet-room"], 1)
        XCTAssertNil(masteryB["sit"])
        XCTAssertEqual(try progress.allPositions(dogId: dogB).count, 0) // B never chose
        XCTAssertEqual(try progress.allPositions(dogId: dogA).count, 1)
    }

    // MARK: helpers

    @discardableResult
    private func completeSet(dogId: String, stepId: String = "sit#1",
                             environmentId: String = "quiet-room",
                             outcomes: [RepOutcome], choiceDelta: Int? = nil) throws -> StoredSet {
        precondition(outcomes.count == 5)
        var set = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                            environmentId: environmentId, stepId: stepId)
        for outcome in outcomes {
            set = try sessions.recordRep(outcome, sessionId: set.sessionId)
        }
        if let delta = choiceDelta {
            let applied = try progress.applyOwnerChoice(
                sessionId: set.sessionId, dogId: dogId, exerciseId: "sit",
                delta: delta, stepCount: 2, ladder: ladder,
                startingEnvironmentId: "quiet-room")
            XCTAssertTrue(applied, "test fixture choice was unexpectedly duplicated")
        }
        return set
    }
}
