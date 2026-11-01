import XCTest
@testable import Pettrainer

/// Reviewer A-2 and A-1, proven the hard way (V-8): care is read and written
/// through the production model while the scored history around it is REAL —
/// a partial set with raw reps, earned mastery, a current position and nosework
/// progress. Exact values, not row counts, must survive care participation.
@MainActor
final class CareIsolationTests: XCTestCase {
    private var directory: URL!
    private var url: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("pettrainer-iso-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("iso.sqlite")
        try seedScoredHistory()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    /// A dog that is mid-training: two reps recorded in an unfinished set, one
    /// earned mastery and one nosework level tried.
    private func seedScoredHistory() throws {
        let content = try ContentLoader.load(bundle: .main)
        let db = try AppDatabase.open(url: url, content: content)
        let progress = ProgressRepository(db: db)
        let dogId = try progress.ensureDefaultDog()
        let sessions = SessionRepository(db: db, progress: progress)

        let stepId = ContentSeeder.stepId(exerciseId: "sit", ordinal: 1)
        var stored = try sessions.resumableSet(dogId: dogId, exerciseId: "sit",
                                               environmentId: "quiet-room", stepId: stepId)
        stored = try sessions.recordRep(.hit, sessionId: stored.sessionId)
        _ = try sessions.recordRep(.miss, sessionId: stored.sessionId)

        // Earn mastery for `look` on the starting rung: 5/5, pushed.
        let lookStep = ContentSeeder.stepId(exerciseId: "look", ordinal: 1)
        let look = try sessions.resumableSet(dogId: dogId, exerciseId: "look",
                                             environmentId: "quiet-room", stepId: lookStep)
        var partial = look
        for _ in 0..<TrainingRules.setSize {
            partial = try sessions.recordRep(.hit, sessionId: partial.sessionId)
        }
        let applied = try progress.applyOwnerChoice(
            sessionId: partial.sessionId, dogId: dogId, exerciseId: "look", delta: 1,
            stepCount: content.exercise(id: "look")?.steps.count ?? 1,
            ladder: content.environmentLadder, startingEnvironmentId: "quiet-room")
        XCTAssertTrue(applied, "fixture choice was unexpectedly rejected")

        try NoseworkRepository(db: db).recordLevelCompletion(dogId: dogId, activityId: "cups",
                                                             levelOrdinal: 2)
    }

    private func snapshot(_ model: AppModel) -> (positions: [String: Position],
                                                mastery: [String: [String: Int]],
                                                nosework: [String: Int],
                                                recommended: String) {
        (model.positions, model.mastery, model.noseworkLevels, model.recommendedExerciseId)
    }

    private func assertIdentical(_ before: (positions: [String: Position],
                                            mastery: [String: [String: Int]],
                                            nosework: [String: Int],
                                            recommended: String),
                                 _ after: (positions: [String: Position],
                                           mastery: [String: [String: Int]],
                                           nosework: [String: Int],
                                           recommended: String)) throws {
        XCTAssertEqual(after.positions, before.positions, "care moved a current position")
        XCTAssertEqual(after.mastery, before.mastery, "care changed earned mastery")
        XCTAssertEqual(after.nosework, before.nosework, "care changed nosework progress")
        XCTAssertEqual(after.recommended, before.recommended,
                       "care changed the recommended exercise")
    }

    /// Care participation cannot be read as, or rewrite, scored progress.
    func testCareWritesLeaveRealScoredHistoryUntouched() throws {
        let model = AppModel(bundle: .main, databaseURL: url)
        XCTAssertEqual(model.state, .ready)
        // The seeded state is visible, so the comparisons below cannot be vacuous.
        XCTAssertFalse(model.positions.isEmpty, "seeding produced no scored position")
        XCTAssertFalse(model.mastery.isEmpty, "seeding produced no earned mastery")
        XCTAssertEqual(model.noseworkLevels["cups"], 2)
        let before = snapshot(model)

        XCTAssertTrue(model.recordCareStageTried(routineId: "care-nails", stageOrdinal: 3))
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-bath", stageOrdinal: 1))
        try model.reload()
        try assertIdentical(before, snapshot(model))

        // Reading care only, with no write at all, is likewise inert.
        _ = model.careStages["care-coat"]
        try model.reload()
        try assertIdentical(before, snapshot(model))

        // Reviewer 4.4: the store itself is inert too — schema version and the
        // seeded exercise/step inventory must not move while care writes land.
        let db = try AppDatabase.open(url: url, content: ContentLoader.load(bundle: .main))
        func counts() throws -> [String: Int] {
            var out: [String: Int] = [:]
            for table in ["exercise", "step"] {
                let rows = try db.query("SELECT COUNT(*) AS n FROM \(table)")
                if case .integer(let n)? = rows.first?["n"] { out[table] = n }
            }
            out["user_version"] = try db.query("PRAGMA user_version").first?["user_version"]
                .flatMap { if case .integer(let v) = $0 { v } else { nil } }
            return out
        }
        let beforeCounts = try counts()
        XCTAssertFalse(beforeCounts.isEmpty)
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-teeth", stageOrdinal: 2))
        XCTAssertEqual(try counts(), beforeCounts,
                       "a care write moved the schema version or the seeded inventory")
    }

    /// A care identifier is never reachable as scored content anywhere.
    func testCareIdsAreAbsentFromScoredCollectionsAndSeeding() throws {
        let content = try ContentLoader.load(bundle: .main)
        let careIds = Set(content.care.map(\.id))
        XCTAssertEqual(careIds.count, 7)
        XCTAssertTrue(Set(content.catalogue.map(\.id)).isDisjoint(with: careIds))
        XCTAssertTrue(Set(content.nosework.map(\.id)).isDisjoint(with: careIds))

        let db = try AppDatabase.open(url: url, content: content)
        let seededRows = try db.query("SELECT id FROM exercise")
        let seededExercises = Set(seededRows.compactMap { row -> String? in
            if case .text(let value)? = row["id"] { return value }
            return nil
        })
        XCTAssertTrue(seededExercises.isDisjoint(with: careIds),
                      "care was seeded as if it were a scored exercise")
        let recommended = AppModel(bundle: .main, databaseURL: url).recommendedExerciseId
        XCTAssertFalse(careIds.contains(recommended), "care was recommended as training")
    }

    /// A relaunch reads care back without inventing scored state.
    func testReopeningTheDatabaseKeepsBothFamiliesSeparate() throws {
        let model = AppModel(bundle: .main, databaseURL: url)
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-checks", stageOrdinal: 2))
        let before = snapshot(model)

        let reopened = AppModel(bundle: .main, databaseURL: url)
        XCTAssertEqual(reopened.careStages["care-checks"], 2)
        try assertIdentical(before, snapshot(reopened))
        XCTAssertNil(reopened.content.exercise(id: "care-checks"))
        XCTAssertNil(reopened.content.noseworkActivity(id: "care-checks"))
    }
}
