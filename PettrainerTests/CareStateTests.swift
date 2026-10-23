import XCTest
@testable import Pettrainer

/// V-7: the model must publish a maximum only after the write committed, and a
/// failed write must leave the visible state at the last committed value with a
/// retry that works and stays idempotent.
@MainActor
final class CareStateTests: XCTestCase {
    private final class SpyStore: CareRecording {
        var highest: [String: Int] = [:]
        var failNext = false
        private(set) var attempts: [(dogId: String, routineId: String, stage: Int)] = []

        func highestStageTried(dogId: String, routineId: String) throws -> Int {
            highest[routineId] ?? 0
        }

        func recordStageTried(dogId: String, routineId: String, stageOrdinal: Int) throws {
            attempts.append((dogId, routineId, stageOrdinal))
            if failNext {
                throw Checks.contentError(source: "spy", path: "record",
                                            "injected write failure")
            }
            highest[routineId] = max(highest[routineId] ?? 0, stageOrdinal)
        }
    }

    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("pettrainer-care-state-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    private func makeModel() throws -> AppModel {
        AppModel(bundle: .main, databaseURL: directory.appendingPathComponent("model.sqlite"))
    }

    func testPublishesOnlyAfterTheWriteCommitsAndNeverLowers() throws {
        let model = try makeModel()
        XCTAssertEqual(model.state, .ready)
        let spy = SpyStore()
        model.installCareStoreForTests(spy)

        XCTAssertTrue(model.recordCareStageTried(routineId: "care-nails", stageOrdinal: 2))
        XCTAssertEqual(model.careStages["care-nails"], 2)

        // An easier day keeps the record: nothing is published downward.
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-nails", stageOrdinal: 1))
        XCTAssertEqual(model.careStages["care-nails"], 2)
        XCTAssertEqual(spy.attempts.map(\.stage), [2, 1])
        XCTAssertEqual(Set(spy.attempts.map(\.dogId)), Set([model.dogId]),
                       "care must write for the active dog only")
    }

    func testFailedWriteKeepsCommittedStateAndRetrySucceeds() throws {
        let model = try makeModel()
        let spy = SpyStore()
        model.installCareStoreForTests(spy)
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-coat", stageOrdinal: 2))
        XCTAssertEqual(model.careStages["care-coat"], 2)

        spy.failNext = true
        XCTAssertFalse(model.recordCareStageTried(routineId: "care-coat", stageOrdinal: 3),
                       "a failed write must be reported, not swallowed")
        XCTAssertEqual(model.careStages["care-coat"], 2,
                       "the screen keeps the last committed maximum on failure")
        XCTAssertNil(spy.highest["care-teeth"])

        // Retry after the transient failure: published, and idempotent.
        spy.failNext = false
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-coat", stageOrdinal: 3))
        XCTAssertEqual(model.careStages["care-coat"], 3)
        XCTAssertTrue(model.recordCareStageTried(routineId: "care-coat", stageOrdinal: 3))
        XCTAssertEqual(model.careStages["care-coat"], 3)
    }

    /// A relaunch rebuilds the maxima from disk through the real repository.
    func testNewModelReadsDurableCareState() throws {
        let url = directory.appendingPathComponent("durable.sqlite")
        let content = try ContentLoader.load(bundle: .main)
        let db = try AppDatabase.open(url: url, content: content)
        let progress = ProgressRepository(db: db)
        let dogId = try progress.ensureDefaultDog()
        let store = CareRepository(db: db, knownRoutineIds: Set(content.care.map(\.id)))
        try store.recordStageTried(dogId: dogId, routineId: "care-teeth", stageOrdinal: 2)

        let model = AppModel(bundle: .main, databaseURL: url)
        XCTAssertEqual(model.state, .ready)
        XCTAssertEqual(model.careStages["care-teeth"], 2,
                       "furthest stage tried must survive building a new model")
        XCTAssertEqual(model.careStages["care-nails"] ?? 0, 0)
    }
}
