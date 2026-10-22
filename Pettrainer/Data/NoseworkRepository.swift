import Foundation

/// Participation-only progress for scent games. There is no hit, miss or
/// verdict anywhere on this path — sniffing cannot be done wrong, and the
/// stored number records the highest level the owner completed, nothing more.
final class NoseworkRepository {
    private let db: SQLiteDatabase
    private let now: () -> String

    init(db: SQLiteDatabase, now: @escaping () -> String = ISODate.now) {
        self.db = db
        self.now = now
    }

    /// Highest level completed for one activity, 0 when none.
    func highestLevel(dogId: String, activityId: String) throws -> Int {
        let rows = try db.query(
            "SELECT highest_level_ordinal FROM nosework_progress WHERE dog_id = ? AND activity_id = ?",
            [.text(dogId), .text(activityId)])
        guard case .integer(let ordinal)? = rows.first?["highest_level_ordinal"] else { return 0 }
        return ordinal
    }

    /// Never lowers progress: the max of old and new is stored, mirroring the
    /// shell's `Math.max(current, ordinal)`.
    func recordLevelCompletion(dogId: String, activityId: String, levelOrdinal: Int) throws {
        guard levelOrdinal >= 1 else { return }
        try db.run("""
        INSERT INTO nosework_progress (dog_id, activity_id, highest_level_ordinal, updated_at)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(dog_id, activity_id) DO UPDATE SET
          highest_level_ordinal = MAX(nosework_progress.highest_level_ordinal,
                                       excluded.highest_level_ordinal),
          updated_at = excluded.updated_at;
        """, [.text(dogId), .text(activityId), .integer(levelOrdinal), .text(now())])
    }
}
