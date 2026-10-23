import Foundation

/// What the app model needs from care storage, kept as a protocol so a test can
/// drive a real write failure (reviewer V-7). `CareRepository` is the only
/// production implementation.
protocol CareRecording {
    func highestStageTried(dogId: String, routineId: String) throws -> Int
    func recordStageTried(dogId: String, routineId: String, stageOrdinal: Int) throws
}

/// Participation-only progress for hygiene routines.
///
/// This is a thin, honest facade over the storage `NoseworkRepository` already
/// owns: `nosework_progress` keys rows by (dog, activity), stores a maximum
/// ordinal and has no foreign key to `exercise`, so `care-*` ids fit without a
/// migration or a second table. What it does NOT do is borrow their meaning —
/// the vocabulary here is about *trying*, never about achieving (reviewer C-1).
/// A stored 3 says "this owner got that far", not "the dog accepts a bath".
final class CareRepository: CareRecording {
    /// Routines an owner may record. Anything else is a stale build or a typo.
    private let knownRoutineIds: Set<String>
    private let store: NoseworkRepository

    init(db: SQLiteDatabase, knownRoutineIds: Set<String>,
         now: @escaping () -> String = ISODate.now) {
        self.store = NoseworkRepository(db: db, now: now)
        self.knownRoutineIds = knownRoutineIds
    }

    /// Highest stage tried for one routine, 0 when the owner touched nothing.
    func highestStageTried(dogId: String, routineId: String) throws -> Int {
        try store.highestLevel(dogId: dogId, activityId: routineId)
    }

    /// Records that a stage was attempted. The dog refusing contact is a
    /// legitimate outcome worth remembering, so this never lowers the maximum
    /// and never implies the next stage is safe to attempt.
    ///
    /// Throws on an unknown routine or an out-of-range stage: a care row must
    /// never be written for an id the app cannot read back as care.
    func recordStageTried(dogId: String, routineId: String, stageOrdinal: Int) throws {
        guard knownRoutineIds.contains(routineId) else {
            throw Checks.contentError(source: "care", path: routineId, "is not a known care routine")
        }
        guard (1...CareValidator.stageCount).contains(stageOrdinal) else {
            throw Checks.contentError(source: "care/\(routineId)", path: "stage",
                                      "must be between 1 and \(CareValidator.stageCount)")
        }
        try store.recordLevelCompletion(dogId: dogId, activityId: routineId,
                                        levelOrdinal: stageOrdinal)
    }
}
