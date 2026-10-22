import XCTest
@testable import Pettrainer

/// Ported expectations from `src/db/migrate.test.ts`, plus the F-3 legacy
/// classification contract from this change's design.
final class MigrationRunnerTests: XCTestCase {

    private typealias Value = SQLiteDatabase.Value
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("pettrainer-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
    }

    private func makeDatabase(_ name: String = "test.sqlite") throws -> SQLiteDatabase {
        try SQLiteDatabase(url: directory.appendingPathComponent(name))
    }

    // MARK: versioning contract

    func testEmptyInstallAppliesAllMigrationsAndIsIdempotent() throws {
        let db = try makeDatabase()
        XCTAssertEqual(try MigrationRunner.runMigrations(on: db), [1, 2])
        XCTAssertEqual(try MigrationRunner.userVersion(db), Migrations.all.count)
        XCTAssertEqual(try MigrationRunner.runMigrations(on: db), [])
        XCTAssertEqual(try MigrationRunner.userVersion(db), Migrations.all.count)
    }

    func testForeignKeysAreEnabledAndEnforced() throws {
        let db = try makeDatabase()
        _ = try MigrationRunner.runMigrations(on: db)
        XCTAssertThrowsError(try db.run(
            "INSERT INTO session (id, dog_id, step_id, environment_id, started_at) "
            + "VALUES ('s', 'ghost', 'ghost', 'ghost', 'now')"))
    }

    func testRollbackLeavesDatabaseUntouched() throws {
        // A migration that fails midway must not leave half a schema or bump
        // user_version. Simulate with a bad custom migration after v1.
        let db = try makeDatabase()
        _ = try MigrationRunner.runMigrations(on: db, migrations: [Migrations.all[0]])
        let broken = Migration(id: 2, name: "broken", up: """
        CREATE TABLE half_made (id TEXT PRIMARY KEY);
        INSERT INTO no_such_table VALUES (1);
        """)
        XCTAssertThrowsError(try MigrationRunner.runMigrations(on: db, migrations: [Migrations.all[0], broken]))
        XCTAssertEqual(try MigrationRunner.userVersion(db), 1)
        let tables = try db.query("SELECT name FROM sqlite_master WHERE name = 'half_made';")
        XCTAssertTrue(tables.isEmpty, "failed migration must roll back its own tables")
    }

    func testRefusesToDowngrade() throws {
        let db = try makeDatabase()
        _ = try MigrationRunner.runMigrations(on: db)
        try db.exec("PRAGMA user_version = 99;")
        XCTAssertThrowsError(try MigrationRunner.runMigrations(on: db)) { error in
            XCTAssertTrue("\(error)".contains("refusing to downgrade"))
        }
    }

    func testNonContiguousIdsRejected() throws {
        let db = try makeDatabase()
        XCTAssertThrowsError(try MigrationRunner.runMigrations(on: db, migrations: [
            Migrations.all[0],
            Migration(id: 3, name: "gap", up: "SELECT 1;"),
        ]))
    }

    // MARK: F-3 legacy classification (v1 → v2 upgrade)

    /// Seeds a v1-shaped dog/step/environment graph, then inserts legacy
    /// session rows plus reps and runs migration 2 over them.
    private func seedV1Scenario(db: SQLiteDatabase) throws {
        try db.exec(Migrations.initialSchema)
        try db.exec("PRAGMA user_version = 1;")
        try db.exec("""
        INSERT INTO dog VALUES ('dog-1', 'Test dog', NULL, '2026-01-01T00:00:00Z');
        INSERT INTO exercise VALUES ('sit', 'foundation', 1);
        INSERT INTO step VALUES ('sit#1', 'sit', 1, NULL);
        INSERT INTO environment VALUES ('quiet-room', 1, 'none', 1);
        """)
    }

    private func insert(_ db: SQLiteDatabase, session id: String, startedAt: String, endedAt: String?,
                        reps: Int) throws {
        try db.run("""
        INSERT INTO session (id, dog_id, step_id, environment_id, started_at, ended_at)
        VALUES (?, 'dog-1', 'sit#1', 'quiet-room', ?, ?)
        """, [.text(id), .text(startedAt), endedAt.map { Value.text($0) } ?? .null])
        for ordinal in 1...max(1, reps) where ordinal <= reps {
            try db.run("INSERT INTO rep VALUES (?, ?, 'hit')", [.text(id), .integer(ordinal)])
        }
    }

    private func lifecycle(_ db: SQLiteDatabase, _ id: String) throws -> String {
        let rows = try db.query("SELECT lifecycle FROM session WHERE id = ?", [.text(id)])
        return rows.first.map { row in
            if case .text(let value)? = row["lifecycle"] { return value }; return "?"
        } ?? "missing"
    }

    func testLegacyRowsClassifyPerTheF3Table() throws {
        let db = try makeDatabase()
        try seedV1Scenario(db: db)
        try insert(db, session: "full-timestamped", startedAt: "2026-02-01T00:00:00Z",
                   endedAt: "2026-02-01T00:02:00Z", reps: 5)
        try insert(db, session: "full-no-timestamp", startedAt: "2026-02-02T00:00:00Z",
                   endedAt: nil, reps: 5)
        try insert(db, session: "partial-timestamped", startedAt: "2026-02-03T00:00:00Z",
                   endedAt: "2026-02-03T00:01:00Z", reps: 3)
        // Two partial open sessions in the same context: only the newest lives.
        try insert(db, session: "partial-open-old", startedAt: "2026-02-04T00:00:00Z", endedAt: nil, reps: 2)
        try insert(db, session: "partial-open-new", startedAt: "2026-02-05T00:00:00Z", endedAt: nil, reps: 1)
        try insert(db, session: "empty-no-timestamp", startedAt: "2026-01-31T00:00:00Z", endedAt: nil, reps: 0)

        let applied = try MigrationRunner.runMigrations(
            on: db, migrations: [Migrations.all[0], Migrations.all[1]])
        XCTAssertEqual(applied, [2])
        XCTAssertEqual(try lifecycle(db, "full-timestamped"), "completed")
        XCTAssertEqual(try lifecycle(db, "full-no-timestamp"), "completed")
        XCTAssertEqual(try lifecycle(db, "partial-timestamped"), "abandoned")
        XCTAssertEqual(try lifecycle(db, "partial-open-old"), "abandoned")
        XCTAssertEqual(try lifecycle(db, "partial-open-new"), "active")
        // A 0-rep open row is still 0–4 reps: it competes as an active
        // candidate and is older, so it is retired rather than resurrected.
        XCTAssertEqual(try lifecycle(db, "empty-no-timestamp"), "abandoned")
        // Raw reps survived untouched.
        let repCount = try db.query("SELECT COUNT(*) AS n FROM rep;")
        if case .integer(let n)? = repCount.first?["n"] { XCTAssertEqual(n, 16) }
        else { XCTFail("count missing") }
        // A pending completed set has no choice marker → UI must re-offer the
        // choice (tested at the repository level).
        let choices = try db.query("SELECT COUNT(*) AS n FROM session_choice;")
        if case .integer(let n)? = choices.first?["n"] { XCTAssertEqual(n, 0) } else { XCTFail() }
    }

    func testFreshInstallHasEmptyLifecycleTablesReady() throws {
        let db = try makeDatabase()
        _ = try MigrationRunner.runMigrations(on: db)
        for table in ["session_choice", "position", "context_progress", "nosework_progress"] {
            let rows = try db.query("SELECT COUNT(*) AS n FROM \(table);")
            if case .integer(let n)? = rows.first?["n"] { XCTAssertEqual(n, 0) } else { XCTFail(table) }
        }
    }
}
