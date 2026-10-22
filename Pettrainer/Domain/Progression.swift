import Foundation

/// Where a dog is on one exercise: a step, in a place.
struct Position: Equatable, Sendable {
    let stepOrdinal: Int
    let environmentId: String
}

/// Moving along the two axes of progress (ported 1:1 from
/// `src/domain/progression.ts`).
///
/// The installation axis is the ordered steps inside one exercise. The
/// generalization axis is the ladder of environments. The rule that governs
/// both: **only one axis moves at a time, and raising one means lowering the
/// other.** So finishing the step ladder does not finish the exercise — it
/// finishes the exercise *here*, and the next move is a harder place with the
/// steps dropped back.
///
/// Unlike the TS original, the ordered environment ids are passed in rather
/// than imported from content, so the domain stays free of content loading.
enum Progression {
    enum Error_: Swift.Error, Equatable, CustomStringConvertible {
        case invalidStepCount(Int)
        case unknownEnvironment(String)

        var description: String {
            switch self {
            case .invalidStepCount(let n): "stepCount must be a positive integer, got \(n)"
            case .unknownEnvironment(let id): "unknown environment: \(id)"
            }
        }
    }

    /// How far back to drop when entering a harder environment.
    ///
    /// Not to the beginning: the early steps install the behaviour and that
    /// work carries over; roughly the final 40% of the ladder is rebuilt.
    /// Integer form of `max(1, ceil(stepCount * 0.6))` — identical results on
    /// the exercise ladder sizes (JS baseline checks: 10→6, 7→5, 4→3, 1→1).
    static func stepAfterEnvironmentChange(stepCount: Int) throws -> Int {
        guard stepCount >= 1 else { throw Error_.invalidStepCount(stepCount) }
        let dropped = (stepCount * 3 + 4) / 5 // ceil(3n/5), n ≥ 1
        return max(1, dropped)
    }

    /// The rung after this one, or `nil` at the top of the ladder.
    static func nextEnvironment(_ id: String, ladder: [String]) throws -> String? {
        guard let index = ladder.firstIndex(of: id) else {
            throw Error_.unknownEnvironment(id)
        }
        guard index + 1 < ladder.count else { return nil }
        return ladder[index + 1]
    }

    /// The rung before this one, or `nil` at the bottom.
    static func previousEnvironment(_ id: String, ladder: [String]) throws -> String? {
        guard let index = ladder.firstIndex(of: id) else {
            throw Error_.unknownEnvironment(id)
        }
        return index == 0 ? nil : ladder[index - 1]
    }

    private static func indexOf(_ id: String, ladder: [String]) -> Int? {
        ladder.firstIndex(of: id)
    }

    /// True when the step ladder has been finished in this environment.
    static func isLadderComplete(_ position: Position, stepCount: Int) -> Bool {
        position.stepOrdinal >= stepCount
    }

    /// True when there is nothing further to climb: the ladder is finished on
    /// the hardest rung there is.
    static func isFullyGeneralized(
        _ position: Position, stepCount: Int, ladder: [String]
    ) throws -> Bool {
        guard isLadderComplete(position, stepCount: stepCount) else { return false }
        return try nextEnvironment(position.environmentId, ladder: ladder) == nil
    }

    /// Apply a move of `delta` steps, rolling over onto the environment axis at
    /// the ends rather than stopping dead.
    ///
    /// - `+1` past the last step moves to the next environment and drops the
    ///   step back, never both forward at once.
    /// - `-1` below the first step moves to the previous environment, landing
    ///   at the point someone arriving there would have started from.
    /// - At the very top and the very bottom the position is simply clamped.
    static func move(
        _ position: Position, stepCount: Int, delta: Int, ladder: [String]
    ) throws -> Position {
        if delta == 0 { return position }

        if delta > 0, position.stepOrdinal >= stepCount {
            guard let harder = try nextEnvironment(position.environmentId, ladder: ladder) else {
                return position
            }
            return Position(
                stepOrdinal: try stepAfterEnvironmentChange(stepCount: stepCount),
                environmentId: harder
            )
        }

        if delta < 0, position.stepOrdinal <= 1 {
            guard let easier = try previousEnvironment(position.environmentId, ladder: ladder) else {
                return position
            }
            return Position(stepOrdinal: stepCount, environmentId: easier)
        }

        return Position(
            stepOrdinal: min(stepCount, max(1, position.stepOrdinal + delta)),
            environmentId: position.environmentId
        )
    }

    /// How many rungs have been fully climbed, for a progress read-out.
    /// Unknown environments read as zero, matching the TS behaviour.
    static func rungsCleared(_ position: Position, stepCount: Int, ladder: [String]) -> Int {
        guard let index = indexOf(position.environmentId, ladder: ladder) else { return 0 }
        return isLadderComplete(position, stepCount: stepCount) ? index + 1 : index
    }
}
