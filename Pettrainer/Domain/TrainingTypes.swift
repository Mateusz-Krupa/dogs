import Foundation

/// Result recorded for one repetition. A cancelled rep counts as a failure.
enum RepOutcome: String, Codable, Sendable {
    case hit
    case miss
    case cancelled
}

/// What to do next: make it harder, repeat the level, or go back a step.
enum Verdict: String, Sendable {
    case push
    case stick
    case drop
}

/// The product's fixed training constants — one source of truth for the
/// Push/Drop/Stick rule (Jean Donaldson, adjusted here to require 5/5).
enum TrainingRules {
    /// A set always contains exactly this many repetitions.
    static let setSize = 5
    /// Hits needed to advance. Five out of five — four is `stick`, not `push`.
    static let pushHits = 5
    /// Hits needed to stay at the level rather than go back a step.
    static let stickHits = 3
}

/// Domain misuse errors, the Swift counterpart of the TS `RangeError`s.
/// Messages intentionally name the offending value so tests and logs stay
/// comparable with the JS baseline.
enum DomainError: Error, Equatable, CustomStringConvertible {
    case wrongSetSize(count: Int, expected: Int)
    case tooManyReps(count: Int, max: Int)
    case invalidMaxIndex(value: Int)
    case invalidCurrentIndex(current: Int, maxIndex: Int)

    var description: String {
        switch self {
        case .wrongSetSize(let count, let expected):
            "expected \(expected) reps, got \(count)"
        case .tooManyReps(let count, let max):
            "expected at most \(max) reps, got \(count)"
        case .invalidMaxIndex(let value):
            "maxIndex must be at least 0, got \(value)"
        case .invalidCurrentIndex(let current, let maxIndex):
            "currentIndex must be within [0, \(maxIndex)], got \(current)"
        }
    }
}
