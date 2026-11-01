import Foundation

/// Navigation routes for the single `NavigationStack`.
/// Mirrors the four destinations the JS shell switched between by hand.
enum Route: Hashable {
    case exercise(exerciseId: String)
    case nosework(activityId: String)
    case problem(issueId: String)
    case care(routineId: String)
    /// The puppy-start hub: one entry, never a scored activity.
    case puppyStart
    case puppyGuide(guideId: String)
}
