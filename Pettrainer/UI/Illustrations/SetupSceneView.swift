import SwiftUI

/// A small top-down diagram of how a scent game is laid out — port of
/// `src/ui/SetupScene.tsx`. Deliberately schematic rather than pictorial:
/// these answer "where do I put things and how far apart", which a photograph
/// would not. Food is dots, the handler is a ring, distance is spacing.
/// Original canvas 160×70; drawn here in a 160-wide viewBox.
struct SetupSceneView: View {
    let activity: String
    let level: Int
    var width: CGFloat = 180

    var body: some View {
        GlyphCanvas(size: width, viewBoxWidth: 160, viewBoxHeight: 70) { context in
            draw(&context)
        }
    }

    private var ink: SVGColor { .gearInk }
    private var food: SVGColor { .treat }
    private var blue: SVGColor { .blue }

    private func stroked(_ context: inout GraphicsContext, _ d: String,
                         dash: [CGFloat] = [], opacity: Double = 1, width: CGFloat = 2) {
        context.stroke(context.svg(d), ink, width: width, dash: dash, opacity: opacity)
    }

    /// Evenly jittered food dots inside a box, deterministic by index.
    private func foodDots(_ context: inout GraphicsContext, x: Double, y: Double,
                          w: Double, h: Double, n: Int) {
        for i in 0..<n {
            let col = i % 5
            let row = i / 5
            let jx = Double((i * 37) % 11) - 5
            let jy = Double((i * 53) % 9) - 4
            context.fill(
                context.circle(x + 8 + Double(col) * ((w - 16) / 4) + jx * 0.6,
                               y + 8 + Double(row) * ((h - 16) / 2) + jy * 0.6, 2.4),
                food)
        }
    }

    private func draw(_ context: inout GraphicsContext) {
        switch activity {
        case "scatter":
            if level == 2 {
                context.stroke(context.roundedRect(x: 14, y: 14, w: 132, h: 44, radius: 6),
                               ink, width: 2, dash: [5, 4])
                for i in 0..<8 {
                    stroked(&context, "M \(22 + i * 17) 58 Q \(24 + i * 17) 46 \(28 + i * 17) 42",
                            opacity: 0.4, width: 1.6)
                }
                foodDots(&context, x: 14, y: 14, w: 132, h: 44, n: 10)
            } else {
                context.stroke(context.roundedRect(x: 34, y: 16, w: 92, h: 40, radius: 5), ink, width: 2)
                foodDots(&context, x: 34, y: 16, w: 92, h: 40, n: 9)
            }
        case "snuffle":
            if level == 3 {
                // box with crumpled paper
                context.stroke(context.roundedRect(x: 44, y: 18, w: 72, h: 38, radius: 4), ink, width: 2)
                for i in 0..<3 {
                    context.stroke(context.circle(60 + Double(i) * 22, 34, 10), ink,
                                   width: 1.8, dash: [4, 3])
                }
                context.fill(context.circle(60, 40, 2.4), food)
                context.fill(context.circle(92, 30, 2.4), food)
            } else {
                // rolled towel, end on
                context.stroke(context.roundedRect(x: 34, y: 22, w: 92, h: 28, radius: 14), ink, width: 2)
                stroked(&context, "M 58 22 Q 62 36 58 50", opacity: 0.6, width: 1.8)
                stroked(&context, "M 84 22 Q 88 36 84 50", opacity: 0.6, width: 1.8)
                for x in [46.0, 71, 100] { context.fill(context.circle(x, 36, 2.4), food) }
            }
        case "cups":
            let count = level == 1 ? 2 : level == 2 ? 3 : 5
            let hidden = count / 2
            for i in 0..<count {
                let gap = 130.0 / Double(count)
                let x = 22.0 + Double(i) * gap
                stroked(&context, "M \(x - 11) 52 L \(x - 7) 26 L \(x + 7) 26 L \(x + 11) 52 Z")
                if i == hidden { context.fill(context.circle(x, 46, 2.6), food) }
            }
        case "find-toy":
            // room outline with a toy tucked behind furniture
            context.stroke(context.roundedRect(x: 14, y: 12, w: 132, h: 48, radius: 4), ink, width: 2)
            context.stroke(context.roundedRect(x: 24, y: 34, w: 34, h: 18, radius: 3), ink,
                           width: 2, opacity: 0.6)
            if level >= 2 {
                context.stroke(context.roundedRect(x: 96, y: 20, w: 30, h: 14, radius: 3), ink,
                               width: 2, opacity: 0.6)
            }
            let toyX = level == 1 ? 80.0 : level == 2 ? 68 : 112
            let toyY = level == 3 ? 27.0 : 44
            context.fill(context.circle(toyX, toyY, 4.5), blue)
            if level == 3 {
                stroked(&context, "M 80 12 L 80 60", dash: [4, 4], opacity: 0.5)
            }
        case "find-person":
            context.stroke(context.roundedRect(x: 14, y: 12, w: 132, h: 48, radius: 4), ink, width: 2)
            if level >= 2 { stroked(&context, "M 80 12 L 80 60", dash: [4, 4], opacity: 0.5) }
            // dog start … person hidden … the route between
            context.stroke(context.circle(34, 36, 6), ink, width: 2)
            context.fill(context.circle(level == 1 ? 86 : 122, 36, 7), blue)
            stroked(&context,
                    "M 42 36 Q \(level == 1 ? 64 : 82) \(level == 1 ? 26 : 20) \(level == 1 ? 78 : 114) 36",
                    dash: [5, 4], opacity: 0.6)
        case "track":
            // footprints, with a corner at level 3
            let count = level == 1 ? 5 : 8
            for i in 0..<count {
                let corner = level == 3 && i >= 5
                let x = corner ? 104.0 : 20.0 + Double(i) * (level == 1 ? 20 : 14)
                let y = corner ? 50.0 - Double(i - 5) * 13 : 46.0
                context.fill(context.circle(x, y, 3), ink, opacity: 0.5)
            }
            let endX = level == 3 ? 104.0 : level == 1 ? 108 : 124
            let endY = level == 3 ? 14.0 : 46
            context.fill(context.circle(endX, endY, 4.5), food)
            if level >= 2 { stroked(&context, "M 20 60 L 140 60", dash: [3, 5], opacity: 0.4) }
        default:
            EmptyView()
        }
    }
}
