import Foundation

/// Push / Drop / Stick verdict rules for a single training set.
///
/// Pure domain logic: no UI, no database, no I/O. Ported 1:1 from
/// `src/domain/verdict.ts`; the thresholds live in `TrainingRules`.
enum VerdictRules {
    /// Number of reps that count as correct. `.hit` counts; `.miss` and
    /// `.cancelled` do not.
    static func countHits(_ reps: [RepOutcome]) -> Int {
        reps.filter { $0 == .hit }.count
    }

    /// Maps a number of correct reps onto the verdict band it falls in.
    private static func verdict(fromHits hits: Int) -> Verdict {
        if hits >= TrainingRules.pushHits { return .push }
        if hits >= TrainingRules.stickHits { return .stick }
        return .drop
    }

    private static func assertFullSet(_ reps: [RepOutcome]) throws {
        guard reps.count == TrainingRules.setSize else {
            throw DomainError.wrongSetSize(count: reps.count, expected: TrainingRules.setSize)
        }
    }

    private static func assertAtMostSetSize(_ reps: [RepOutcome]) throws {
        guard reps.count <= TrainingRules.setSize else {
            throw DomainError.tooManyReps(count: reps.count, max: TrainingRules.setSize)
        }
    }

    /// Verdict for a completed set. Throws if `reps.count != SET_SIZE`.
    static func verdictForSet(_ reps: [RepOutcome]) throws -> Verdict {
        try assertFullSet(reps)
        return verdict(fromHits: countHits(reps))
    }

    /// Verdict for a set that may still be in progress. `nil` when fewer than
    /// `SET_SIZE` reps have been recorded. Throws if more than `SET_SIZE`.
    static func verdictSoFar(_ reps: [RepOutcome]) throws -> Verdict? {
        try assertAtMostSetSize(reps)
        guard reps.count >= TrainingRules.setSize else { return nil }
        return verdict(fromHits: countHits(reps))
    }

    /// True once the remaining reps cannot change the verdict, so the UI may
    /// offer to end the set early. Throws if more than `SET_SIZE` reps.
    static func isVerdictDecided(_ reps: [RepOutcome]) throws -> Bool {
        try assertAtMostSetSize(reps)
        let hits = countHits(reps)
        let remaining = TrainingRules.setSize - reps.count
        // Verdicts are monotonic in the hit count, so the outcome is decided
        // exactly when the worst-case and best-case final scores land in the
        // same band.
        return verdict(fromHits: hits) == verdict(fromHits: hits + remaining)
    }

    /// Apply a verdict to a position on a ladder of difficulty steps. `push`
    /// moves +1, `drop` moves -1, `stick` stays. Clamped to `[0, maxIndex]`.
    /// Throws when `maxIndex` is negative or `current` is outside the ladder.
    /// (Fractional/NaN inputs the TS version rejects are unrepresentable in
    /// `Int`; the type system is the first line of defence here.)
    static func nextStepIndex(current: Int, maxIndex: Int, verdict: Verdict) throws -> Int {
        guard maxIndex >= 0 else {
            throw DomainError.invalidMaxIndex(value: maxIndex)
        }
        guard (0...maxIndex).contains(current) else {
            throw DomainError.invalidCurrentIndex(current: current, maxIndex: maxIndex)
        }
        let target: Int
        switch verdict {
        case .push: target = current + 1
        case .stick: target = current
        case .drop: target = current - 1
        }
        return min(maxIndex, max(0, target))
    }
}
