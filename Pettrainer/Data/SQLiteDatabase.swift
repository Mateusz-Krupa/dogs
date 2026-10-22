import Foundation
import SQLite3

/// A serialized connection to the app's local SQLite file.
///
/// All access funnels through one internal queue; the UI acknowledges a write
/// only after this class returns, which is what makes "commit before ack"
/// true for every repository call. Statements are always prepared/bound —
/// strings never carry user data.
final class SQLiteDatabase {
    enum DatabaseError: Error, CustomStringConvertible {
        case openFailed(code: Int32, message: String)
        case executionFailed(sql: String, message: String)
        case prepareFailed(sql: String, message: String)
        case stepFailed(message: String)
        case corruptResult

        var description: String {
            switch self {
            case .openFailed(let code, let message): "sqlite open failed (\(code)): \(message)"
            case .executionFailed(_, let message): "sqlite execution failed: \(message)"
            case .prepareFailed(_, let message): "sqlite prepare failed: \(message)"
            case .stepFailed(let message): "sqlite step failed: \(message)"
            case .corruptResult: "sqlite returned an unusable row"
            }
        }
    }

    /// A bindable/readable SQLite value.
    enum Value: Equatable {
        case text(String)
        case integer(Int)
        case real(Double)
        case null
    }

    /// The `SQLITE_TRANSIENT` C macro is not importable as Swift; this is the
    /// canonical stand-in, copied verbatim where SQLite bindings need it.
    private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    let fileURL: URL
    // Recursive, thread-affine on purpose: `transaction(body)` re-enters the
    // public primitives from the same thread, and a plain serial queue would
    // deadlock on its own `sync`.
    private let lock = NSRecursiveLock()
    private var handle: OpaquePointer?

    /// Opens (creating if needed) the database at `url`. `inMemory` is used by
    /// tests with a unique name so multiple connections share it.
    init(url: URL) throws {
        self.fileURL = url
        var opened: OpaquePointer?
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        let code = sqlite3_open_v2(url.path, &opened, flags, nil)
        guard code == SQLITE_OK, let opened else {
            let message = String(cString: sqlite3_errmsg(opened))
            sqlite3_close(opened)
            throw DatabaseError.openFailed(code: code, message: message)
        }
        handle = opened
        try exec("PRAGMA journal_mode = WAL;")
        try exec("PRAGMA busy_timeout = 5000;")
    }

    deinit {
        sqlite3_close_v2(handle)
    }

    /// Runs one or more plain SQL statements (migrations, seeds without args).
    func exec(_ sql: String) throws {
        lock.lock(); defer { lock.unlock() }
        try execUnsafe(sql)
    }

    /// Runs one bound statement; no rows are returned.
    func run(_ sql: String, _ arguments: [Value] = []) throws {
        lock.lock(); defer { lock.unlock() }
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(arguments, to: statement)
        let code = sqlite3_step(statement)
        guard code == SQLITE_DONE else {
            throw DatabaseError.stepFailed(message: lastMessage)
        }
    }

    /// Runs one bound query and materialises every row.
    func query(_ sql: String, _ arguments: [Value] = []) throws -> [[String: Value]] {
        lock.lock(); defer { lock.unlock() }
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(arguments, to: statement)
        var rows: [[String: Value]] = []
        while true {
            let code = sqlite3_step(statement)
            if code == SQLITE_ROW {
                rows.append(try readRow(statement))
            } else if code == SQLITE_DONE {
                break
            } else {
                throw DatabaseError.stepFailed(message: lastMessage)
            }
        }
        return rows
    }

    /// BEGIN IMMEDIATE … COMMIT, rolling back on any throw. The body runs on
    /// the calling thread and may use every other method of this instance
    /// reentrantly; it must not start a second concurrent transaction.
    func transaction<T>(_ body: () throws -> T) throws -> T {
        lock.lock(); defer { lock.unlock() }
        try execUnsafe("BEGIN IMMEDIATE;")
        do {
            let result = try body()
            try execUnsafe("COMMIT;")
            return result
        } catch {
            try? execUnsafe("ROLLBACK;")
            throw error
        }
    }

    // MARK: - internals (call only while holding the lock)

    private func execUnsafe(_ sql: String) throws {
        var error: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(handle, sql, nil, nil, &error)
        guard code == SQLITE_OK else {
            let message = error.map { String(cString: $0) } ?? "unknown"
            sqlite3_free(error)
            throw DatabaseError.executionFailed(sql: sql, message: message)
        }
    }

    private func prepare(_ sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, statement != nil else {
            throw DatabaseError.prepareFailed(sql: sql, message: lastMessage)
        }
        return statement
    }

    private func bind(_ arguments: [Value], to statement: OpaquePointer?) throws {
        for (index, argument) in arguments.enumerated() {
            let position = Int32(index + 1)
            switch argument {
            case .text(let text): sqlite3_bind_text(statement, position, text, -1, sqliteTransient)
            case .integer(let number): sqlite3_bind_int64(statement, position, Int64(number))
            case .real(let number): sqlite3_bind_double(statement, position, number)
            case .null: sqlite3_bind_null(statement, position)
            }
        }
    }

    private func readRow(_ statement: OpaquePointer?) throws -> [String: Value] {
        var row: [String: Value] = [:]
        for index in 0..<sqlite3_column_count(statement) {
            guard let name = sqlite3_column_name(statement, index) else {
                throw DatabaseError.corruptResult
            }
            let key = String(cString: name)
            switch sqlite3_column_type(statement, index) {
            case SQLITE_INTEGER: row[key] = .integer(Int(sqlite3_column_int64(statement, index)))
            case SQLITE_FLOAT: row[key] = .real(sqlite3_column_double(statement, index))
            case SQLITE_TEXT: row[key] = .text(String(cString: sqlite3_column_text(statement, index)))
            default: row[key] = .null
            }
        }
        return row
    }

    private var lastMessage: String { String(cString: sqlite3_errmsg(handle)) }
}
