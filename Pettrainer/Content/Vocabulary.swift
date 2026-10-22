import Foundation

/// Closed vocabularies shared by content validation and illustration code.
/// `allCases` order is significant: it is the order the JS validators listed
/// the ids in (`checks.ts`), and error messages print it verbatim.
///
/// Raw values are stable content ids — they appear in the JSON files and in
/// persisted rows, and must never be renamed by a UI refactor.

/// Training categories an exercise belongs to (the `exercise` table CHECK).
enum ExerciseCategory: String, CaseIterable {
    case foundation
    case impulseControl = "impulse_control"
    case advanced
}

/// A rung's trigger class.
enum DistractionKind: String, CaseIterable {
    case none
    case household
    case handler
    case objectStill = "object_still"
    case objectMoving = "object_moving"
    case outdoorNovelty = "outdoor_novelty"
    case people
    case children
    case foodGround = "food_ground"
    case wildlife
    case dogs
}

/// Dog silhouettes available to the illustrations (port of `ui/DogPose`).
enum Pose: String, CaseIterable {
    case sit
    case down
    case stand
    case stay
    case come
    case look
    case mat
    case leave
    case sniff
    case search
}

/// Equipment icons available to `GearRow` (port of `ui/Gear`).
enum GearId: String, CaseIterable {
    case treats
    case lead
    case longline
    case mat
    case towel
    case box
    case toy
    case cups
    case clippers
    case bowl
    case helper
    case door
    case grass
    case nothing
}

/// What a step diagram draws (port of `MOTION_IDS` in `schema/checks.ts`).
enum StepMotion: String, CaseIterable {
    case up // treat above the nose, dog folds into a sit
    case down // nose to floor, straight in front of the paws
    case draw // down to the floor and drawn toward the handler
    case hold // nothing moves; the handler and the dog both stay put
    case away // the dog travels toward the hand held up in front
    case leg // the treat arrives low, at the handler's leg
    case refuse // a forbidden item on the ground, crossed out
    case deny // the same item offered at muzzle height, crossed out
    case swap // a better piece at the nose, the held item dropping to the floor
    case contact // a hand rests on the dog's back
    case touchPaw // a hand reaches down to a front paw
    case lift // a paw goes up and comes back down
    case face // the muzzle is lifted and inspected
    /// The handler steps away from the held dog and comes back. Backticks:
    /// `return` is a Swift keyword; the raw value stays the stable id.
    case `return`
    case collar // a hand closes on the collar and lets go
    case door // a door, and the gap being opened
    case bowl // a food bowl lowered, lifted back when the dog moves
    case toss // a treat tossed in an arc onto the mat
}
