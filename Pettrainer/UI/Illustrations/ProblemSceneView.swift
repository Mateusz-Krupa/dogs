import SwiftUI

/// A scene pictogram for each behaviour problem — port of
/// `src/ui/ProblemScene.tsx`. Where StepDiagram answers "what does my hand
/// do", these answer "what is going on": the dog, the trigger, and the
/// spatial truth that matters — distance to the tram, the door it bolts
/// through, the clock of an empty flat. One dog scale across all cards.
enum ProblemScene {
    static let dogScale = 0.7
    /// Shift that keeps the scaled dog's own ground line at y=82.
    static let dogShift = 82 * (1 - dogScale)

    /// True when a scene exists for this problem id.
    static func exists(id: String) -> Bool { scenes[id] != nil }

    static let scenes: [String: (pose: Pose, extras: (inout GraphicsContext, SVGColor, SVGColor) -> Void)] = [
        "bark-door": (pose: .sit, extras: { context, color, accent in
            door(&context, color: color, accent: accent)
            bark(&context, x: 62, y: 40, accent: accent)
            context.fill(context.circle(76, 24, 4), accent)
            bark(&context, x: 67, y: 24, accent: accent, flip: true)
        }),
        "bark-window": (pose: .sit, extras: { context, color, accent in
            windowFrame(&context, color: color)
            bark(&context, x: 60, y: 44, accent: accent)
        }),
        "jumping": (pose: .stand, extras: { context, color, accent in
            person(&context, x: 84, color: color)
            context.stroke(context.svg("M 50 48 Q 62 30 74 44"), accent, width: 3, dash: [5, 4])
            context.fill(context.svg("M 76 47 L 68 44 L 73 36 Z"), accent)
        }),
        "nipping": (pose: .stand, extras: { context, color, accent in
            person(&context, x: 80, color: color)
            context.stroke(context.svg("M 72 70 L 66 66 M 71 76 L 64 76 M 72 82 L 66 86"),
                           accent, width: 2.5)
        }),
        "stealing": (pose: .down, extras: { context, color, _ in
            counter(&context, color: color, treat: .treat)
        }),
        "bolting": (pose: .come, extras: { context, color, accent in
            door(&context, color: color, accent: accent)
            person(&context, x: 66, color: color, opacity: 0.45)
            context.stroke(context.svg("M 44 74 L 76 74"), accent, width: 3, dash: [6, 5])
            context.fill(context.svg("M 86 74 L 76 69 L 76 79 Z"), accent)
        }),
        "reactivity": (pose: .stand, extras: { context, color, accent in
            // the lead; friction between two dogs who should not have to meet;
            // a mirrored small dog — facing each other is the whole story.
            context.stroke(context.svg("M 0 50 Q 14 57 26 57"), accent, width: 2.5)
            context.stroke(context.svg("M 50 72 L 56 64 L 52 76 L 60 67"), accent, width: 3)
            context.drawLayer { small in
                small.translateBy(x: 100, y: 82 - 82 * 0.34)
                small.scaleBy(x: -0.34, y: 0.34)
                DogPoseGlyph.draw(&small, pose: .sit, color: color, accent: accent)
            }
        }),
        "traffic": (pose: .stand, extras: { context, color, accent in
            car(&context, color: color)
            distance(&context, accent: accent)
        }),
        "noise": (pose: .down, extras: { context, _, accent in
            context.stroke(context.svg("M 26 12 L 17 31 L 25 31 L 16 47"), accent, width: 3.5)
            context.stroke(context.svg("M 10 58 Q 3 65 10 72"), accent, width: 3, opacity: 0.8)
            context.stroke(context.svg("M 15 54 Q 2 65 15 76"), accent, width: 3, opacity: 0.4)
        }),
        "alone": (pose: .down, extras: { context, color, accent in
            door(&context, color: color, accent: accent)
            clock(&context, accent: accent)
        }),
        "mounting": (pose: .stand, extras: { context, color, accent in
            // The person is a statue, not a sparring partner; the dashed arc
            // names the behaviour without shaming the drawing.
            person(&context, x: 92, color: color)
            context.stroke(context.svg("M 50 36 Q 68 22 84 44"), accent, width: 3, dash: [5, 4])
            context.fill(context.svg("M 87 50 L 82 42 L 80 52 Z"), accent)
        }),
        "bed": (pose: .mat, extras: { context, color, _ in
            // The mat glyph already shows “their own raised bed”; a headboard
            // hint and the paid treat on the mat say: the rule moved, the dog
            // won either way.
            context.fill(context.roundedRect(x: 8, y: 56, w: 5, h: 28, radius: 2.5), color, opacity: 0.3)
            context.fill(context.circle(80, 74, 3), .treat)
        }),
        "overarousal": (pose: .stand, extras: { context, _, accent in
            // The zoom loop overhead and the double motion streak say what the
            // posture cannot: the level keeps climbing, it is not just play.
            context.stroke(context.svg("M 24 18 Q 48 6 72 16"), accent, width: 3, dash: [6, 5])
            context.fill(context.svg("M 74 16 L 66 11 L 68 21 Z"), accent)
            context.stroke(context.svg("M 8 44 Q 18 36 12 28"), accent, width: 3, opacity: 0.8)
            context.stroke(context.svg("M 16 56 Q 26 48 20 40"), accent, width: 3, opacity: 0.45)
        }),
        "fear-withdrawal": (pose: .down, extras: { context, color, accent in
            // The person stays far right; the gap with the arrow pointing away
            // is the whole lesson — distance is the tool, not confrontation.
            person(&context, x: 96, color: color, opacity: 0.7)
            context.stroke(context.svg("M 52 76 L 66 76"), accent, width: 3, dash: [5, 4])
            context.fill(context.svg("M 48 76 L 55 72 L 55 80 Z"), accent)
        }),
    ]

    // MARK: Props (verbatim geometry from ProblemScene.tsx)

    static func person(_ context: inout GraphicsContext, x: Double, color: SVGColor,
                       opacity: Double = 1) {
        context.fill(context.circle(x, 40, 6), color, opacity: 0.85 * opacity)
        context.fill(context.svg(
            "M \(x - 6) 50 Q \(x - 6) 47 \(x - 3) 47 L \(x + 3) 47 Q \(x + 6) 47 \(x + 6) 50 L \(x + 6) 82 L \(x - 6) 82 Z"),
            color, opacity: 0.85 * opacity)
    }

    static func door(_ context: inout GraphicsContext, color: SVGColor, accent: SVGColor) {
        context.stroke(context.svg("M 93 34 L 93 82"), color, width: 3, opacity: 0.55)
        context.fill(context.circle(89, 60, 2.5), accent)
    }

    static func bark(_ context: inout GraphicsContext, x: Double, y: Double,
                     accent: SVGColor, flip: Bool = false) {
        let s = flip ? -1.0 : 1
        context.stroke(context.svg("M \(x) \(y - 6) Q \(x + 6 * s) \(y) \(x) \(y + 6)"), accent, width: 3)
        context.stroke(context.svg("M \(x + 5 * s) \(y - 11) Q \(x + 14 * s) \(y) \(x + 5 * s) \(y + 11)"),
                       accent, width: 3, opacity: 0.5)
    }

    static func car(_ context: inout GraphicsContext, color: SVGColor) {
        context.fill(context.svg("M 72 48 L 92 48 Q 95 48 95 52 L 95 62 L 69 62 L 69 52 Q 69 48 72 48 Z"),
                     color, opacity: 0.4)
        context.fill(context.svg("M 66 60 L 98 60 Q 100 60 100 63 L 100 72 Q 100 75 97 75 L 69 75 Q 66 75 66 72 Z"),
                     color, opacity: 0.55)
        context.fill(context.circle(74, 77, 4), color)
        context.fill(context.circle(92, 77, 4), color)
    }

    static func distance(_ context: inout GraphicsContext, accent: SVGColor) {
        context.stroke(context.svg("M 50 76 L 60 76"), accent, width: 3, dash: [5, 4])
        context.fill(context.svg("M 46 76 L 53 72 L 53 80 Z"), accent)
        context.fill(context.svg("M 64 76 L 57 72 L 57 80 Z"), accent)
    }

    static func clock(_ context: inout GraphicsContext, accent: SVGColor) {
        context.stroke(context.circle(78, 40, 11), accent, width: 3)
        context.stroke(context.svg("M 78 40 L 78 33"), accent, width: 2.5)
        context.stroke(context.svg("M 78 40 L 83 42"), accent, width: 2.5)
    }

    static func windowFrame(_ context: inout GraphicsContext, color: SVGColor) {
        context.stroke(context.svg("M 68 30 L 96 30 L 96 72 L 68 72 Z"), color, width: 3, opacity: 0.5)
        context.stroke(context.svg("M 82 30 L 82 72"), color, width: 2, opacity: 0.35)
    }

    static func counter(_ context: inout GraphicsContext, color: SVGColor, treat: SVGColor) {
        context.fill(context.svg("M 40 46 L 98 46 Q 100 46 100 49 L 100 52 L 40 52 Z"), color, opacity: 0.5)
        context.fill(context.circle(52, 37, 5), treat)
        context.stroke(context.svg("M 50 41 Q 44 50 40 57"), treat, width: 2.5, dash: [4, 4])
    }
}

struct ProblemSceneView: View {
    let id: String
    var size: CGFloat = 140
    var color = SVGColor.ink
    var accent = SVGColor.accent

    var body: some View {
        if let scene = ProblemScene.scenes[id] {
            GlyphCanvas(size: size) { context in
                // The dog lives in its own scaled layer; props draw on the
                // unscaled canvas, exactly like the SVG <G transform> wrapper.
                context.drawLayer { dog in
                    dog.translateBy(x: 0, y: ProblemScene.dogShift)
                    dog.scaleBy(x: ProblemScene.dogScale, y: ProblemScene.dogScale)
                    DogPoseGlyph.draw(&dog, pose: scene.pose, color: color, accent: accent)
                }
                scene.extras(&context, color, accent)
            }
        }
    }
}
