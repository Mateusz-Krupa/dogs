import Foundation

/// One shared ISO-8601 stamp source for all repositories.
enum ISODate {
    private static let formatter = ISO8601DateFormatter()
    static func now() -> String { formatter.string(from: Date()) }
}

/// Opens, migrates and seeds the app's on-device database.
///
/// The file lives in Application Support (not the bundle, not Caches, not
/// temp): it must survive relaunches and updates, and iOS decides backups
/// from user/device settings — the app itself promises none. A corrupt or
/// newer-than-supported database is reported through `StorageFailure` and the
/// app blocks unsafe writes; nothing here ever deletes or resets user data.
enum AppDatabase {
    enum StorageFailure: Error, Equatable {
        case missingApplicationSupportDirectory
    }

    static let fileName = "pettrainer.sqlite"

    static func defaultURL() throws -> URL {
        let support = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
        let directory = support.appendingPathComponent("Pettrainer", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        // UI tests must not inherit (or pollute) the owner's progress file:
        // PETTRAINER_DB_NAME swaps only the filename inside the same folder.
        let name = ProcessInfo.processInfo.environment["PETTRAINER_DB_NAME"] ?? fileName
        return directory.appendingPathComponent(name)
    }

    /// Open → migrate → seed. Idempotent; call on every launch.
    static func open(url: URL, content: TrainingContent) throws -> SQLiteDatabase {
        let db = try SQLiteDatabase(url: url)
        _ = try MigrationRunner.runMigrations(on: db)
        try ContentSeeder.seed(db, content: content)
        return db
    }

    /// Composition-root helper: `Result` so the UI can show a localized
    /// recovery message instead of crashing on damaged storage.
    static func openWithRecovery(content: TrainingContent) -> Result<SQLiteDatabase, Error> {
        do {
            return .success(try open(url: try defaultURL(), content: content))
        } catch {
            return .failure(error)
        }
    }
}
