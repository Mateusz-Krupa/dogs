import SwiftUI

/// Pose glyphs: a chunky dog silhouette in each trained position — a port of
/// `src/ui/DogPose.tsx`. Filled silhouettes, not line art: at ~64 px thin
/// outlines turn to scribble, a solid shape still reads as a dog. One breed,
/// one angle, one weight throughout, because these exist so an owner can
/// compare their dog's body to the picture, not to decorate the list.
///
/// Canvas is 100×100 with the ground at y=82.
enum DogPoseGlyph {
    static let ground = 82.0

    /// Head, muzzle and ear as one solid shape, rotated into place.
    static func head(_ context: inout GraphicsContext, x: Double, y: Double,
                     tilt: Double = 0, color: SVGColor) {
        context.translateBy(x: x, y: y)
        context.rotate(by: .degrees(tilt))
        context.fill(context.circle(0, 0, 11), color) // skull
        context.fill(context.svg("M 6 1 L 22 4 Q 25 6 22 9 L 6 10 Z"), color) // muzzle
        context.fill(context.svg("M -7 -8 Q -16 -20 -2 -16 Q 2 -13 -1 -8 Z"), color) // folded ear
        // Eye punched out of the silhouette.
        context.fill(context.circle(3, -2, 2.1), .white, opacity: 0.92)
        context.rotate(by: .degrees(-tilt))
        context.translateBy(x: -x, y: -y)
    }

    /// Tail as a tapered sweep.
    static func tail(_ context: inout GraphicsContext, _ d: String, color: SVGColor) {
        context.stroke(context.svg(d), color, width: 6)
    }

    /// Draws the pose into the current transform (no <Svg> wrapper), so
    /// `ProblemScene` can translate and scale it inside a larger drawing.
    static func draw(_ context: inout GraphicsContext, pose: Pose,
                     color: SVGColor = .ink, accent: SVGColor = .accent) {
        let g = ground
        // ground
        context.fill(context.roundedRect(x: 8, y: g, w: 84, h: 3.5, radius: 1.75),
                     color, opacity: 0.18)

        func sitBody() {
            context.fill(context.svg(
                "M 30 \(g) Q 24 58 34 46 Q 44 34 58 40 L 62 \(g) L 50 \(g) L 52 56 Q 42 60 38 \(g) Z"), color)
            tail(&context, "M 30 66 Q 18 62 22 50", color: color)
        }

        switch pose {
        case .sit:
            sitBody()
            head(&context, x: 64, y: 34, color: color)
        case .look:
            // A head tilted this far up reads as "looking at you" on its own.
            sitBody()
            head(&context, x: 62, y: 26, tilt: -38, color: color)
        case .leave:
            // The item being left alone is StepDiagram's crossed-out mark.
            sitBody()
            head(&context, x: 64, y: 34, tilt: -22, color: color)
        case .stay:
            // A held position is shown by StepDiagram's pause bars.
            sitBody()
            head(&context, x: 62, y: 34, color: color)
        case .down, .mat:
            let lift = pose == .mat ? 9.0 : 0
            if pose == .mat {
                context.fill(context.roundedRect(x: 14, y: g - 9, w: 76, h: 11, radius: 5.5),
                             color, opacity: 0.28)
            }
            // body low, elbows and chest down
            context.fill(context.svg(
                "M 26 \(g - lift) Q 24 58 40 56 L 70 56 Q 80 56 80 \(g - lift) Z"), color)
            tail(&context, "M 26 \(g - 12) Q 12 \(g - 14) 16 \(g - 24)", color: color)
            head(&context, x: 84, y: 54, color: color)
        case .stand:
            context.fill(context.svg(
                "M 30 46 L 74 46 L 74 \(g) L 66 \(g) L 66 56 L 40 56 L 40 \(g) L 32 \(g) Z"), color)
            tail(&context, "M 30 44 Q 18 38 24 28", color: color)
            head(&context, x: 80, y: 40, color: color)
        case .sniff, .search:
            // standing, head low to the ground, working
            context.fill(context.svg(
                "M 32 48 L 72 46 L 72 \(g) L 64 \(g) L 64 56 L 40 57 L 40 \(g) L 32 \(g) Z"), color)
            tail(&context, pose == .search ? "M 32 46 Q 18 36 26 26" : "M 32 46 Q 18 42 22 32",
                 color: color)
            head(&context, x: 80, y: 64, tilt: 34, color: color)
            // scent, rising from the ground where the nose is
            context.fill(context.circle(88, g - 4, 3), accent, opacity: 0.9)
            context.fill(context.circle(80, g - 1, 2.2), accent, opacity: 0.6)
            if pose == .search {
                context.fill(context.circle(70, g - 3, 1.8), accent, opacity: 0.4)
            }
        case .come:
            // one solid body, head to chest, so the dog does not fall apart at
            // small sizes; legs reach forward and back — mid-stride toward you
            context.fill(context.svg("M 24 52 Q 26 42 40 40 L 62 38 Q 74 37 76 46 L 72 56 L 30 58 Z"), color)
            context.fill(context.svg("M 60 52 L 74 70 L 80 82 L 73 82 L 63 68 L 55 58 Z"), color)
            context.fill(context.svg("M 34 54 L 22 70 L 15 82 L 22 82 L 31 68 L 40 58 Z"), color)
            tail(&context, "M 24 48 Q 10 42 16 30", color: color)
            head(&context, x: 78, y: 36, tilt: -10, color: color)
        }
    }
}

/// The standalone glyph, exactly where `DogPose` was used.
struct DogPoseView: View {
    let pose: Pose
    var size: CGFloat = 72
    var color = SVGColor.ink
    var accent = SVGColor.accent

    var body: some View {
        GlyphCanvas(size: size) { context in
            DogPoseGlyph.draw(&context, pose: pose, color: color, accent: accent)
        }
            }
}
