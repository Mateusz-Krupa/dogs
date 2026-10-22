import Foundation

/// A set as stored on the device. `reps` are the raw rows — the verdict is
/// derived, never persisted, and `awaitingChoice` marks the recovery state
/// from F-1: five reps committed, owner decision not yet made.
struct StoredSet: Equatable {
    let sessionId: String
    let dogId: String
    let stepId: String
    let environmentId: String
    let reps: [RepOutcome]
    let lifecycle: SessionLifecycle

    var awaitingChoice: Bool { lifecycle == .completed }

    /// Derived verdict: nil unless the set is complete.
    var verdict: Verdict? { try? VerdictRules.verdictSoFar(reps) }
    var decided: Bool { (try? VerdictRules.isVerdictDecided(reps)) ?? false }
}

enum SessionLifecycle: String {
    case active
    case completed
    case abandoned
}

/// Raw repetition rows: the source of truth for verdicts and history.
///
/// Durability contract (specs/local-training-storage): every write is a
/// committed transaction before this call returns — the UI acknowledges only
/// what SQLite already has. A fifth rep and the completed transition commit
/// together; undo reopens a completed set transactionally only while no owner
/// choice has been recorded; abandonment retains reps and yields no verdict.
final class SessionRepository {
    private let db: SQLiteDatabase
    private let progress: ProgressRepository
    private let now: () -> String

    init(db: SQLiteDatabase, progress: ProgressRepository,
         now: @escaping () -> String = ISODate.now) {
        self.db = db
        self.progress = progress
        self.now = now
    }

    /// The exercise's resumable set: the newest active set, or a completed set
    /// whose owner choice has not been applied (F-1). Created on demand for a
    /// fresh exercise — the successor set only ever materialises with its
    /// first committed rep.
    func resumableSet(dogId: String, exerciseId: String, environmentId: String, stepId: String) throws -> StoredSet {
        let rows = try db.query("""
        SELECT s.id, s.dog_id, s.step_id, s.environment_id, s.lifecycle
        FROM session s
        WHERE s.dog_id = ?
          AND (
            s.lifecycle = 'active'
            OR (s.lifecycle = 'completed'
                AND NOT EXISTS (SELECT 1 FROM session_choice c WHERE c.session_id = s.id))
          )
          AND s.step_id IN (SELECT id FROM step WHERE exercise_id = ?)
        ORDER BY s.started_at DESC, s.id DESC
        LIMIT 1;
        """, [.text(dogId), .text(exerciseId)])
        if let row = rows.first,
           case .text(let id)? = row["id"], case .text(let step)? = row["step_id"],
           case .text(let env)? = row["environment_id"],
           case .text(let lifecycleRaw)? = row["lifecycle"],
           let lifecycle = SessionLifecycle(rawValue: lifecycleRaw) {
            return StoredSet(sessionId: id, dogId: dogId, stepId: step, environmentId: env,
                             reps: try reps(sessionId: id), lifecycle: lifecycle)
        }
        // No pending set: create one for exactly the position the owner is on.
        let id = "set." + UUID().uuidString
        try db.run("""
        INSERT INTO session (id, dog_id, step_id, environment_id, started_at, lifecycle)
        VALUES (?, ?, ?, ?, ?, 'active');
        """, [.text(id), .text(dogId), .text(stepId), .text(environmentId), .text(now())])
        return StoredSet(sessionId: id, dogId: dogId, stepId: stepId,
                         environmentId: environmentId, reps: [], lifecycle: .active)
    }

    func set(sessionId: String) throws -> StoredSet {
        let rows = try db.query("""
        SELECT dog_id, step_id, environment_id, lifecycle FROM session WHERE id = ?;
        """, [.text(sessionId)])
        guard let row = rows.first,
              case .text(let dogId)? = row["dog_id"], case .text(let stepId)? = row["step_id"],
              case .text(let environmentId)? = row["environment_id"],
              case .text(let lifecycleRaw)? = row["lifecycle"],
              let lifecycle = SessionLifecycle(rawValue: lifecycleRaw) else {
            throw RepositoryError.sessionNotFound(sessionId)
        }
        return StoredSet(sessionId: sessionId, dogId: dogId, stepId: stepId,
                         environmentId: environmentId,
                         reps: try reps(sessionId: sessionId), lifecycle: lifecycle)
    }

    func reps(sessionId: String) throws -> [RepOutcome] {
        let rows = try db.query(
            "SELECT outcome FROM rep WHERE session_id = ? ORDER BY ordinal;", [.text(sessionId)])
        return rows.compactMap { row in
            guard case .text(let raw)? = row["outcome"] else { return nil }
            return RepOutcome(rawValue: raw)
        }
    }

    /// Appends the next rep. On the fifth rep the completion transition (and
    /// the F-2 mastery earning, when the set pushed) commits atomically.
    @discardableResult
    func recordRep(_ outcome: RepOutcome, sessionId: String) throws -> StoredSet {
        try db.transaction {
            let current = try set(sessionId: sessionId)
            guard current.lifecycle == .active else {
                switch current.lifecycle {
                case .completed: throw RepositoryError.setAlreadyComplete(sessionId)
                default: throw RepositoryError.sessionNotActive(sessionId, lifecycle: current.lifecycle.rawValue)
                }
            }
            guard current.reps.count < TrainingRules.setSize else {
                throw RepositoryError.setAlreadyComplete(sessionId)
            }
            let ordinal = current.reps.count + 1
            try db.run("INSERT INTO rep (session_id, ordinal, outcome) VALUES (?, ?, ?);",
                       [.text(sessionId), .integer(ordinal), .text(outcome.rawValue)])
            let updated = try set(sessionId: sessionId)
            guard updated.reps.count == TrainingRules.setSize else { return updated }

            try db.run("""
            UPDATE session SET lifecycle = 'completed', ended_at = ? WHERE id = ?;
            """, [.text(now()), .text(sessionId)])
            // F-2: mastery grows only on a completed set that pushed.
            let verdict = try VerdictRules.verdictForSet(updated.reps)
            if verdict == .push {
                let (exerciseId, stepOrdinal) = try progress.exerciseId(forStepId: updated.stepId)
                try progress.earnMasteryPush(
                    dogId: updated.dogId, exerciseId: exerciseId,
                    environmentId: updated.environmentId, stepOrdinal: stepOrdinal)
            }
            return try set(sessionId: sessionId)
        }
    }

    /// Removes the last rep. A completed set reopens (status and timestamp
    /// revert) only while the owner has not chosen; after that the history is
    /// frozen.
    @discardableResult
    func undoLastRep(sessionId: String) throws -> StoredSet {
        try db.transaction {
            let current = try set(sessionId: sessionId)
            let chosen = try db.query(
                "SELECT 1 FROM session_choice WHERE session_id = ?", [.text(sessionId)])
            guard current.lifecycle == .active || (current.awaitingChoice && chosen.isEmpty) else {
                if current.awaitingChoice, !chosen.isEmpty {
                    throw RepositoryError.choiceAlreadyApplied(sessionId)
                }
                throw RepositoryError.sessionNotActive(sessionId, lifecycle: current.lifecycle.rawValue)
            }
            guard !current.reps.isEmpty else { throw RepositoryError.nothingToUndo(sessionId) }
            try db.run("""
            DELETE FROM rep WHERE session_id = ? AND ordinal = (
              SELECT MAX(ordinal) FROM rep WHERE session_id = ?);
            """, [.text(sessionId), .text(sessionId)])
            if current.lifecycle == .completed {
                try db.run("""
                UPDATE session SET lifecycle = 'active', ended_at = NULL WHERE id = ?;
                """, [.text(sessionId)])
                // F-2: a set undone before its choice was committed never had
                // time to be finalised into a position; mastery of an undone
                // push set is lowered only here, and only back to the highest
                // other push ever recorded for the context.
                try relaxMasteryAfterUndo(current)
            }
            return try set(sessionId: sessionId)
        }
    }

    /// Reverses the F-2 earning of an undone fifth rep when its set pushed and
    /// its choice had not been committed. Recomputes from raw rows instead of
    /// decrementing: mastery is exactly the highest step in this context that
    /// still has a completed five-hit set (the undone session is already back
    /// to 'active', so it cannot count itself).
    private func relaxMasteryAfterUndo(_ undone: StoredSet) throws {
        let (exerciseId, _) = try progress.exerciseId(forStepId: undone.stepId)
        let rows = try db.query("""
        SELECT MAX(ordinal) AS top FROM (
          SELECT st.ordinal AS ordinal
          FROM session s2 JOIN step st ON st.id = s2.step_id
          WHERE s2.dog_id = ? AND s2.environment_id = ? AND st.exercise_id = ?
            AND s2.lifecycle IN ('completed', 'abandoned')
          GROUP BY s2.id
          HAVING (SELECT COUNT(*) FROM rep WHERE session_id = s2.id) = 5
             AND (SELECT COUNT(*) FROM rep WHERE session_id = s2.id AND outcome = 'hit') = 5
        );
        """, [.text(undone.dogId), .text(undone.environmentId), .text(exerciseId)])
        if let row = rows.first, case .integer(let highest)? = row["top"], highest > 0 {
            // Never lower a mastery another push still justifies.
            try progress.earnMasteryPush(
                dogId: undone.dogId, exerciseId: exerciseId,
                environmentId: undone.environmentId, stepOrdinal: highest)
        } else {
            try db.run("""
            DELETE FROM mastery
             WHERE dog_id = ? AND exercise_id = ? AND environment_id = ?;
            """, [.text(undone.dogId), .text(exerciseId), .text(undone.environmentId)])
        }
    }

    /// Keeps the raw reps, marks the set abandoned: never a completed verdict.
    @discardableResult
    func abandon(sessionId: String) throws -> StoredSet {
        try db.transaction {
            let current = try set(sessionId: sessionId)
            guard current.lifecycle == .active else {
                throw RepositoryError.sessionNotActive(sessionId, lifecycle: current.lifecycle.rawValue)
            }
            try db.run("UPDATE session SET lifecycle = 'abandoned', ended_at = ? WHERE id = ?;",
                       [.text(now()), .text(sessionId)])
            return try set(sessionId: sessionId)
        }
    }
}
