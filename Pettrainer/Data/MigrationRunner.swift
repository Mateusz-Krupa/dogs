import Foundation

/// Migration runner for the app's SQLite database (port of
/// `src/db/migrate.ts`).
///
/// Tracks the schema version in SQLite's `user_version` pragma rather than a
/// bookkeeping table. `PRAGMA foreign_keys` is applied on every call because
/// SQLite defaults it off per connection.
enum MigrationRunner {
    enum MigrationError: Error, Equatable, CustomStringConvertible {
        case nonContiguousIds(index: Int, id: Int)
        case databaseTooNew(current: Int, latest: Int)

        var description: String {
            switch self {
            case .nonContiguousIds(let index, let id):
                "Migration ids must be contiguous starting at 1, but migrations[\(index)] has id \(id)"
            case .databaseTooNew(let current, let latest):
                "Database is at user_version \(current), newer than the newest migration (\(latest)); refusing to downgrade"
            }
        }
    }

    /// Applies every migration whose id is greater than the database's current
    /// user_version, in ascending id order, then sets user_version to the
    /// highest applied id. Returns the ids actually applied, in order.
    ///
    /// Idempotent: running twice applies nothing the second time. All pending
    /// migrations are applied in one transaction; on failure the transaction
    /// is rolled back and user_version is left untouched.
    static func runMigrations(
        on db: SQLiteDatabase, migrations: [Migration] = Migrations.all
    ) throws -> [Int] {
        for (index, migration) in migrations.enumerated() {
            guard migration.id == index + 1 else {
                throw MigrationError.nonContiguousIds(index: index, id: migration.id)
            }
        }

        let currentVersion = try userVersion(db)
        let latestVersion = migrations.last?.id ?? 0
        guard currentVersion <= latestVersion else {
            throw MigrationError.databaseTooNew(current: currentVersion, latest: latestVersion)
        }

        // Per-connection pragma; a no-op inside a transaction, so it goes first.
        try db.exec("PRAGMA foreign_keys = ON;")

        let pending = migrations.filter { $0.id > currentVersion }
        guard !pending.isEmpty else { return [] }

        var applied: [Int] = []
        try db.transaction {
            for migration in pending {
                try db.exec(migration.up)
                applied.append(migration.id)
            }
            try db.exec("PRAGMA user_version = \(latestVersion);")
        }
        return applied
    }

    static func userVersion(_ db: SQLiteDatabase) throws -> Int {
        let rows = try db.query("PRAGMA user_version;")
        guard let first = rows.first, case .integer(let value)? = first["user_version"] else {
            return 0
        }
        return value
    }
}
