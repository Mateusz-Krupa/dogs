import Foundation

/// A stored training position plus the stable ids it belongs to.
struct StoredPosition: Equatable {
    let dogId: String
    let exerciseId: String
    let position: Position
}

enum RepositoryError: Error, Equatable, CustomStringConvertible {
    case sessionNotFound(String)
    case sessionNotActive(String, lifecycle: String)
    case setAlreadyComplete(String)
    case nothingToUndo(String)
    case choiceAlreadyApplied(String)
    case unknownStep(String)

    var description: String {
        switch self {
        case .sessionNotFound(let id): "no session with id \(id)"
        case .sessionNotActive(let id, let lifecycle): "session \(id) is \(lifecycle), not active"
        case .setAlreadyComplete(let id): "session \(id) already holds five reps"
        case .nothingToUndo(let id): "session \(id) has no reps to undo"
        case .choiceAlreadyApplied(let id): "the owner choice for session \(id) is already applied"
        case .unknownStep(let id): "content no longer contains step \(id)"
        }
    }
}

/// Current positions, per-context progress and historical mastery.
///
/// Three distinct facts, never conflated (per the change spec):
/// - `position` — where the owner stands right now (one row per dog×exercise),
///   seeded lazily to step 1 / starting environment, moved only by an explicit
///   owner choice;
/// - `context_progress` — the current step inside each environment the dog has
///   reached; entering a context again keeps its stored value, and leaving one
///   never overwrites another;
/// - `mastery` — historical highest step that earned a push (5/5) set; it only
///   ever grows and a later drop never erases it (F-2).
final class ProgressRepository {
    static let defaultDogId = "dog.default"

    private let db: SQLiteDatabase
    private let now: () -> String

    init(db: SQLiteDatabase, now: @escaping () -> String = ISODate.now) {
        self.db = db
        self.now = now
    }

    /// Idempotent default dog; future multi-dog support needs no schema change
    /// because every repository call already takes a dog id.
    @discardableResult
    func ensureDefaultDog() throws -> String {
        try db.run("""
        INSERT INTO dog (id, name, born_on, created_at) VALUES (?, '', NULL, ?)
        ON CONFLICT(id) DO NOTHING;
        """, [.text(Self.defaultDogId), .text(now())])
        return Self.defaultDogId
    }

    // MARK: Position

    func position(dogId: String, exerciseId: String, startingEnvironmentId: String) throws -> Position {
        let rows = try db.query(
            "SELECT step_ordinal, environment_id FROM position WHERE dog_id = ? AND exercise_id = ?",
            [.text(dogId), .text(exerciseId)])
        if let row = rows.first, case .integer(let step)? = row["step_ordinal"],
           case .text(let environment)? = row["environment_id"] {
            return Position(stepOrdinal: step, environmentId: environment)
        }
        // Lazy seed: step 1 in the starting environment. Never derived from
        // mastery — historical achievement is not current position.
        try db.run("""
        INSERT INTO position (dog_id, exercise_id, step_ordinal, environment_id, updated_at)
        VALUES (?, ?, 1, ?, ?)
        ON CONFLICT(dog_id, exercise_id) DO NOTHING;
        """, [.text(dogId), .text(exerciseId), .text(startingEnvironmentId), .text(now())])
        return Position(stepOrdinal: 1, environmentId: startingEnvironmentId)
    }

    func allPositions(dogId: String) throws -> [String: Position] {
        let rows = try db.query(
            "SELECT exercise_id, step_ordinal, environment_id FROM position WHERE dog_id = ?",
            [.text(dogId)])
        var result: [String: Position] = [:]
        for row in rows {
            guard case .text(let exerciseId)? = row["exercise_id"],
                  case .integer(let step)? = row["step_ordinal"],
                  case .text(let environment)? = row["environment_id"] else { continue }
            result[exerciseId] = Position(stepOrdinal: step, environmentId: environment)
        }
        return result
    }

    // MARK: Mastery (F-2: push only)

    func mastery(dogId: String) throws -> [String: [String: Int]] {
        let rows = try db.query(
            "SELECT exercise_id, environment_id, highest_step_ordinal FROM mastery WHERE dog_id = ?",
            [.text(dogId)])
        var result: [String: [String: Int]] = [:]
        for row in rows {
            guard case .text(let exerciseId)? = row["exercise_id"],
                  case .text(let environment)? = row["environment_id"],
                  case .integer(let step)? = row["highest_step_ordinal"] else { continue }
            result[exerciseId, default: [:]][environment] = step
        }
        return result
    }

    /// Called inside the fifth-rep transaction: mastery increases only when a
    /// completed five-rep set at this step earned `push`.
    func earnMasteryPush(dogId: String, exerciseId: String, environmentId: String, stepOrdinal: Int) throws {
        try db.run("""
        INSERT INTO mastery (dog_id, exercise_id, environment_id, highest_step_ordinal, updated_at)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(dog_id, exercise_id, environment_id) DO UPDATE SET
          highest_step_ordinal = MAX(mastery.highest_step_ordinal, excluded.highest_step_ordinal),
          updated_at = excluded.updated_at;
        """, [.text(dogId), .text(exerciseId), .text(environmentId), .integer(stepOrdinal), .text(now())])
    }

    private func contextStep(dogId: String, exerciseId: String, environmentId: String) throws -> Int? {
        let rows = try db.query(
            "SELECT current_step_ordinal FROM context_progress WHERE dog_id = ? AND exercise_id = ? AND environment_id = ?",
            [.text(dogId), .text(exerciseId), .text(environmentId)])
        guard case .integer(let step)? = rows.first?["current_step_ordinal"] else { return nil }
        return step
    }

    private func upsertContextStep(
        dogId: String, exerciseId: String, environmentId: String, stepOrdinal: Int
    ) throws {
        try db.run("""
        INSERT INTO context_progress (dog_id, exercise_id, environment_id, current_step_ordinal, updated_at)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(dog_id, exercise_id, environment_id) DO UPDATE SET
          current_step_ordinal = excluded.current_step_ordinal, updated_at = excluded.updated_at;
        """, [.text(dogId), .text(exerciseId), .text(environmentId), .integer(stepOrdinal), .text(now())])
    }

    /// Applies an owner choice (+1 harder / 0 same / -1 easier) atomically:
    /// records the idempotency marker, moves the position through the domain
    /// rules and preserves each context's own progress. Returns false when the
    /// choice was already applied — a duplicate tap changes nothing.
    func applyOwnerChoice(
        sessionId: String, dogId: String, exerciseId: String,
        delta: Int, stepCount: Int, ladder: [String], startingEnvironmentId: String
    ) throws -> Bool {
        try db.transaction {
            let existing = try db.query(
                "SELECT 1 FROM session_choice WHERE session_id = ?", [.text(sessionId)])
            guard existing.isEmpty else { return false }

            let here = try position(dogId: dogId, exerciseId: exerciseId,
                                    startingEnvironmentId: startingEnvironmentId)
            var target = try Progression.move(here, stepCount: stepCount, delta: delta, ladder: ladder)

            // Per-context progress: re-entering an environment resumes at its
            // stored step when one exists; the domain rule is the fallback.
            if target.environmentId != here.environmentId,
               let stored = try contextStep(dogId: dogId, exerciseId: exerciseId,
                                            environmentId: target.environmentId) {
                target = Position(stepOrdinal: min(stored, stepCount), environmentId: target.environmentId)
            }

            try upsertContextStep(dogId: dogId, exerciseId: exerciseId,
                                  environmentId: here.environmentId, stepOrdinal: here.stepOrdinal)
            try upsertContextStep(dogId: dogId, exerciseId: exerciseId,
                                  environmentId: target.environmentId, stepOrdinal: target.stepOrdinal)
            try db.run("""
            INSERT INTO position (dog_id, exercise_id, step_ordinal, environment_id, updated_at)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(dog_id, exercise_id) DO UPDATE SET
              step_ordinal = excluded.step_ordinal,
              environment_id = excluded.environment_id,
              updated_at = excluded.updated_at;
            """, [.text(dogId), .text(exerciseId), .integer(target.stepOrdinal),
                  .text(target.environmentId), .text(now())])
            try db.run("INSERT INTO session_choice (session_id, delta, applied_at) VALUES (?, ?, ?);",
                       [.text(sessionId), .integer(delta), .text(now())])
            return true
        }
    }

    // MARK: Step identity helpers

    /// Resolves `exerciseId#ordinal` step ids (baseline manifest) against the
    /// seeded content tables.
    func exerciseId(forStepId stepId: String) throws -> (exerciseId: String, ordinal: Int) {
        let rows = try db.query(
            "SELECT exercise_id, ordinal FROM step WHERE id = ?", [.text(stepId)])
        guard let row = rows.first, case .text(let exerciseId)? = row["exercise_id"],
              case .integer(let ordinal)? = row["ordinal"] else {
            throw RepositoryError.unknownStep(stepId)
        }
        return (exerciseId, ordinal)
    }

    static func stepCount(in db: SQLiteDatabase, exerciseId: String) throws -> Int {
        let rows = try db.query("SELECT COUNT(*) AS n FROM step WHERE exercise_id = ?",
                                [.text(exerciseId)])
        guard case .integer(let n)? = rows.first?["n"] else { return 0 }
        return n
    }
}
