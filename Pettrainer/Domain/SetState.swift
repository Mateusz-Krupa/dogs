import Foundation

/// Pure state machine for a single training set of `TrainingRules.setSize`
/// repetitions. Ported 1:1 from `src/features/session/setMachine.ts`.
///
/// No UI, no I/O. The verdict rules themselves live in `VerdictRules`; this
/// type only sequences reps and re-derives the verdict after every change, so
/// the verdict can never drift from the reps that produced it.
struct SetState: Equatable, Sendable {
    let reps: [RepOutcome]
    /// Set once the set is complete; `nil` while in progress.
    let verdict: Verdict?
    /// True when the remaining reps cannot change the outcome.
    let decided: Bool

    /// Builds a state from reps, deriving verdict and decided from them.
    private static func state(fromReps reps: [RepOutcome]) -> SetState {
        SetState(
            reps: reps,
            verdict: try? VerdictRules.verdictSoFar(reps),
            decided: (try? VerdictRules.isVerdictDecided(reps)) ?? false
        )
    }

    /// A set with no reps recorded.
    static let empty = SetState(reps: [], verdict: nil, decided: false)

    /// The owner's available actions.
    enum Action: Sendable {
        case record(RepOutcome)
        case undo
        case reset
    }

    /// Applies an action. Pure: never mutates its input.
    ///
    /// - `record` appends an outcome. Ignored (returns the same state) once the
    ///   set already holds `setSize` reps — the UI must never be able to record
    ///   a sixth.
    /// - `undo` removes the last rep. On an empty set it is a no-op.
    /// - `reset` returns to the empty state.
    func applying(_ action: Action) -> SetState {
        switch action {
        case .record(let outcome):
            guard reps.count < TrainingRules.setSize else { return self }
            return Self.state(fromReps: reps + [outcome])
        case .undo:
            guard !reps.isEmpty else { return self }
            return Self.state(fromReps: Array(reps.dropLast()))
        case .reset:
            return .empty
        }
    }
}
