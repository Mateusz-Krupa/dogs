import XCTest
@testable import Pettrainer

/// Storage contract for care participation (task 4.1): reuse of the existing
/// namespaced table must behave like a maximum of *attempts*, stay isolated per
/// dog and routine, refuse ids it cannot read back, and leave every scored row
/// sharing the database untouched (reviewer C-1, A-2).
final class CareRepositoryTests: XCTestCase {
    private var directory: URL!
    private var db: SQLiteDatabase!
    private var care: CareRepository!
    private var nosework: NoseworkRepository!
    private var clock = "2026-10-23T00:00:00Z"

    private let routines = ["care-paw-rinse", "care-nails", "care-bath", "care-teeth"]

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("pettrainer-care-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        db = try SQLiteDatabase(url: directory.appendingPathComponent("test.sqlite"))
        _ = try MigrationRunner.runMigrations(on: db)
        try ContentSeeder.seed(db, content: ContentLoader.load(bundle: .main))
        for id in ["dog-a", "dog-b"] {
            try db.run("INSERT INTO dog VALUES (?, ?, NULL, '2026-01-01T00:00:00Z');",
                       [.text(id), .text(String(id.prefix(3)).uppercased())])
        }
        care = CareRepository(db: db, knownRoutineIds: Set(routines)) { [self] in clock }
        nosework = NoseworkRepository(db: db) { [self] in clock }
    }

    override func tearDown() {
        // SQLiteDatabase closes in deinit; dropping the reference is the API.
        db = nil
        care = nil
        nosework = nil
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    private func count(of table: String) throws -> Int {
        guard case .integer(let value)? = try db.query("SELECT COUNT(*) AS n FROM \(table)").first?["n"] else {
            return -1
        }
        return value
    }

    func testUntriedRoutineReadsAsZero() throws {
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 0)
    }

    func testRecordsAFurthestAttemptAndNeverLowersIt() throws {
        try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 2)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 2)

        // A harder day is not a regression: an easier attempt keeps the record.
        try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 1)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 2)

        try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 3)
        try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 3)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 3)
    }

    func testDogsAndRoutinesDoNotShareARecord() throws {
        try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 3)
        try care.recordStageTried(dogId: "dog-b", routineId: "care-nails", stageOrdinal: 1)
        try care.recordStageTried(dogId: "dog-a", routineId: "care-bath", stageOrdinal: 2)

        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 3)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-b", routineId: "care-nails"), 1)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-bath"), 2)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-b", routineId: "care-bath"), 0)
    }

    func testRejectsIdsAndStagesItCannotReadBack() throws {
        XCTAssertThrowsError(
            try care.recordStageTried(dogId: "dog-a", routineId: "sit", stageOrdinal: 1))
        XCTAssertThrowsError(
            try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 0))
        XCTAssertThrowsError(
            try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 4))
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 0)
        XCTAssertEqual(try count(of: "nosework_progress"), 0, "a rejected write must leave no row")
    }

    /// The shared table holds both families, so the content layer is what keeps
    /// them apart: a care id is not a scent game and not an exercise.
    func testFamiliesStayApartAtTheContentLayer() throws {
        try nosework.recordLevelCompletion(dogId: "dog-a", activityId: "cups", levelOrdinal: 3)
        try care.recordStageTried(dogId: "dog-a", routineId: "care-nails", stageOrdinal: 2)

        XCTAssertEqual(try nosework.highestLevel(dogId: "dog-a", activityId: "cups"), 3)
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-nails"), 2)

        let content = try ContentLoader.load(bundle: .main)
        XCTAssertNil(content.noseworkActivity(id: "care-nails"))
        XCTAssertNil(content.exercise(id: "care-nails"))
        XCTAssertNotNil(content.careRoutine(id: "care-nails"))
    }

    /// Writing care must never touch the scored history around it.
    func testScoredHistoryIsUntouchedByCare() throws {
        let sessions = try count(of: "session")
        let reps = try count(of: "rep")
        let positions = try count(of: "context_progress")

        try care.recordStageTried(dogId: "dog-a", routineId: "care-paw-rinse", stageOrdinal: 1)
        try care.recordStageTried(dogId: "dog-a", routineId: "care-bath", stageOrdinal: 3)

        XCTAssertEqual(try count(of: "session"), sessions)
        XCTAssertEqual(try count(of: "rep"), reps)
        XCTAssertEqual(try count(of: "context_progress"), positions)
    }

    /// A relaunch reads from disk, not from memory.
    func testAttemptsSurviveReopeningTheDatabase() throws {
        try care.recordStageTried(dogId: "dog-a", routineId: "care-teeth", stageOrdinal: 1)
        clock = "2026-10-24T09:00:00Z"

        // A new connection to the same file is the relaunch: nothing but the
        // database survives the hand-off.
        db = try SQLiteDatabase(url: directory.appendingPathComponent("test.sqlite"))
        care = CareRepository(db: db, knownRoutineIds: Set(routines)) { [self] in clock }
        XCTAssertEqual(try care.highestStageTried(dogId: "dog-a", routineId: "care-teeth"), 1)
    }
}
