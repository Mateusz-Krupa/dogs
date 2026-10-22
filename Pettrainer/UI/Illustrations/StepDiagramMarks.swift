import Foundation

/// Which dot or arrow each motion draws — a verbatim port of `MARKS` in
/// `src/ui/StepDiagram.tsx`. Coordinates live in the 100×100 glyph space; the
/// fade rules live in the sets below, not here.
enum StepDiagramMarks {
    struct MotionMarks {
        /// Where the dot (or ring) sits; the arrow leaves from there.
        var from: (Double, Double)? = nil
        /// Dashed travel path and its head, when the motion moves something.
        var curve: String? = nil
        var head: String? = nil
    }

    static let marks: [StepMotion: MotionMarks] = [
        .up: MotionMarks(from: (92, 30),
                         curve: "M 90 23 Q 86 12 76 9", head: "M 68 8 L 78 3 L 78 14 Z"),
        .down: MotionMarks(from: (94, 44),
                           curve: "M 95 51 Q 95 64 93 71", head: "M 91 80 L 86 71 L 97 72 Z"),
        // Down to the floor and then drawn toward the handler — the full down shape.
        .draw: MotionMarks(from: (94, 44),
                           curve: "M 95 51 Q 97 63 92 67", head: "M 96 74 L 87 70 L 93 63 Z"),
        .hold: MotionMarks(),
        // Recall and loose lead: the dog travels toward the hand held up in
        // front, so the arrow starts low at the chest and ends at the dot.
        // It is about the dog's route, not the hand, so it stays once the
        // food is gone.
        .away: MotionMarks(from: (94, 42),
                           curve: "M 58 62 Q 70 58 79 51", head: "M 87 48 L 78 43 L 80 54 Z"),
        // Loose lead paying spot: low, at the handler's leg — never out in
        // front, which would send the dog forward into the pulling.
        .leg: MotionMarks(from: (90, 66),
                          curve: "M 56 72 Q 68 70 78 68", head: "M 85 67 L 76 62 L 77 73 Z"),
        .refuse: MotionMarks(from: (92, 74)),
        .deny: MotionMarks(from: (92, 40)),
        // The better piece at the nose; the held item drops to the ground in
        // front, where the dog will find it again — trade, not confiscation.
        .swap: MotionMarks(from: (92, 30),
                           curve: "M 92 38 Q 92 52 91 62", head: "M 90 72 L 85 63 L 96 63 Z"),
        // A hand, not a treat: the contact dot is accent-coloured on purpose.
        .contact: MotionMarks(from: (50, 22),
                              curve: "M 50 29 L 50 36", head: "M 50 44 L 44 33 L 56 33 Z"),
        .touchPaw: MotionMarks(curve: "M 70 40 L 70 56", head: "M 70 66 L 64 56 L 76 56 Z"),
        .lift: MotionMarks(curve: "M 70 50 L 70 64", head: "M 70 44 L 65 52 L 75 52 Z"),
        .face: MotionMarks(from: (94, 46)),
        // Your steps out and back to the held dog: one shaft, heads both ways.
        .return: MotionMarks(curve: "M 68 66 L 90 66",
                             head: "M 62 66 L 70 61 L 70 71 Z M 96 66 L 88 61 L 88 71 Z"),
        .collar: MotionMarks(from: (72, 46),
                             curve: "M 92 32 Q 84 36 78 41", head: "M 76 45 L 84 42 L 80 33 Z"),
        .door: MotionMarks(curve: "M 64 48 Q 74 47 82 45", head: "M 89 44 L 80 40 L 80 49 Z"),
        .bowl: MotionMarks(from: (88, 70), curve: "M 95 44 L 95 60",
                           head: "M 95 38 L 90 46 L 100 46 Z M 95 66 L 90 58 L 100 58 Z"),
        .toss: MotionMarks(from: (85, 66),
                           curve: "M 48 34 Q 64 26 78 48", head: "M 83 58 L 73 55 L 79 44 Z"),
    ]

    /// Motions whose dot is food: it fades with the lure stage.
    static let foodDots: Set<StepMotion> = [.up, .down, .draw, .away, .leg, .swap, .toss]
    /// Motions whose dot is something else — a hand, a bowl — always visible.
    static let objectDots: Set<StepMotion> = [.contact, .bowl]
    /// Pure lure-path arrows: they fade with the food, or they would
    /// contradict the copy.
    static let lureArrows: Set<StepMotion> = [.up, .down, .draw, .swap, .toss, .leg]

    /// Every motion must have an entry; a missing key is a port bug.
    static var completeCoverage: Bool { marks.count == StepMotion.allCases.count }
}
