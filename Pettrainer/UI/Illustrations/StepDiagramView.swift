import SwiftUI

/// A still diagram of one step — port of `src/ui/StepDiagram.tsx`. The
/// vocabulary (and nothing else): a filled dot is the treat where it should be
/// held; a dashed arrow is a travel path; a hollow dot is the same position
/// with the food faded out; a sound arc means the owner spoke; an accent ring
/// or bars mean a hand or a held position; a door line and a bowl are the
/// objects a step is about. The dog faces right in every pose, so every mark
/// sits in front of the muzzle, above the back, or beside the paws.
///
/// Which version of the movement a step practises (`DiagramStage`) comes from
/// the lure-stage ladder; the food dot and lure arrows fade with it, while
/// object marks and dog-routes survive — the same rules as the JS original.
enum DiagramStage: String {
    case lure
    case emptyHand = "empty-hand"
    case verbal
}

/// Lure-stage boundaries per exercise (port of `lureStages.ts`). Exercises
/// missing here never fade a lure — recall, loose lead and handling are
/// food-led the whole way through.
enum LureStages {
    struct Boundary {
        let lureUntil: Int
        let handUntil: Int
    }

    static let boundaries: [String: Boundary] = [
        "sit": Boundary(lureUntil: 5, handUntil: 8),
        "down": Boundary(lureUntil: 3, handUntil: 5),
        "look": Boundary(lureUntil: 2, handUntil: 3),
        "mat": Boundary(lureUntil: 2, handUntil: 3),
        "leave": Boundary(lureUntil: 4, handUntil: 4),
        "name": Boundary(lureUntil: 0, handUntil: 0),
        "stay": Boundary(lureUntil: 0, handUntil: 0),
        "wait": Boundary(lureUntil: 0, handUntil: 0),
    ]

    static func stage(exerciseId: String, stepOrdinal: Int) -> DiagramStage {
        guard let bounds = boundaries[exerciseId] else { return .lure }
        if stepOrdinal <= bounds.lureUntil { return .lure }
        if stepOrdinal <= bounds.handUntil { return .emptyHand }
        return .verbal
    }
}

/// The motion each exercise practises at its early steps; steps override it
/// (port of `MOTION_BY_EXERCISE`).
enum MotionByExercise {
    static let values: [String: StepMotion] = [
        "name": .hold, "sit": .up, "look": .up, "down": .down, "stay": .hold,
        "come": .away, "leave": .refuse, "drop": .swap, "wait": .hold,
        "leash": .away, "mat": .down, "handling": .contact,
    ]

    static func motion(forExerciseId id: String) -> StepMotion? { values[id] }
}

struct StepDiagramView: View {
    let pose: Pose
    let motion: StepMotion
    let stage: DiagramStage
    /// The owner's voice is part of this step. Verbal stages imply it.
    var sound: Bool? = nil
    var size: CGFloat = 132
    var color = SVGColor.ink
    var accent = SVGColor.accent

    var body: some View {
        let marks = StepDiagramMarks.marks[motion] ?? StepDiagramMarks.MotionMarks()
        let verbal = stage == .verbal
        let spoke = sound ?? verbal
        let showDot = marks.from != nil
            && (StepDiagramMarks.foodDots.contains(motion) ? !verbal
                : StepDiagramMarks.objectDots.contains(motion))
        let showArrow = marks.curve != nil
            && !(StepDiagramMarks.lureArrows.contains(motion) && verbal)

        GlyphCanvas(size: size) { context in
            if motion == .toss {
                // The mat: a toss always lands somewhere, and the target must
                // be visible even when the step is practised standing on it.
                context.fill(context.svg("M 12 76 L 92 76 L 92 83 L 12 83 Z"), color, opacity: 0.24)
            }
            DogPoseGlyph.draw(&context, pose: pose, color: color, accent: accent)

            if spoke {
                // The fact that you spoke, drawn as two arcs leaving the muzzle.
                context.stroke(context.svg("M 80 20 Q 88 20 88 28"), accent, width: 3)
                context.stroke(context.svg("M 74 14 Q 88 14 88 28"), accent, width: 3, opacity: 0.5)
            }

            if motion == .door {
                // The door itself: a straight leaf at the edge, the arrow the gap.
                context.stroke(context.svg("M 92 26 L 92 80"), accent, width: 4)
            }

            if motion == .face, let from = marks.from {
                // A ring around the muzzle: lifted lip, inspected teeth.
                context.stroke(context.circle(from.0, from.1, 9), accent, width: 3)
            }

            if motion == .collar, let from = marks.from {
                // A ring low on the neck: the collar, taken hold of and let go.
                context.stroke(context.circle(from.0, from.1, 8), accent, width: 3)
            }

            if motion == .hold {
                // A held position: two short bars meaning "nothing moves".
                context.stroke(context.svg("M 88 14 L 88 30"), accent, width: 4)
                context.stroke(context.svg("M 96 14 L 96 30"), accent, width: 4)
            }

            if motion == .refuse || motion == .deny, let from = marks.from {
                // Two crossed strokes over a treat dot: "there, but not for
                // the dog".
                context.fill(context.circle(from.0, from.1, 6), .treat, opacity: 0.9)
                context.stroke(
                    context.svg("M \(from.0 - 9) \(from.1 - 9) L \(from.0 + 9) \(from.1 + 9)"),
                    accent, width: 3.5)
            }

            if showArrow, let curve = marks.curve, let head = marks.head {
                context.stroke(context.svg(curve), accent, width: 3, dash: [6, 5])
                context.fill(context.svg(head), accent)
            }

            if showDot, let from = marks.from {
                switch motion {
                case .contact: // The hand that lands on the dog, not food.
                    context.fill(context.circle(from.0, from.1, 5), accent)
                case .bowl:
                    context.fill(context.circle(from.0, from.1, 6.5), .treat)
                case .up, .down, .draw, .away, .leg, .swap, .toss where stage == .lure:
                    context.fill(context.circle(from.0, from.1, 5.5), .treat)
                default:
                    // Same place, same gesture — the ring is simply no longer
                    // filled. A dashed ring reads as scribble at 64px; a solid
                    // one still reads.
                    context.stroke(context.circle(from.0, from.1, 5.5), accent, width: 3)
                }
            }
        }
    }
}
