import SwiftUI

/// A tiny SVG-path subset parser: the illustration data in this app uses only
/// `M`, `L`, `Q`, `Z` with absolute coordinates, and the ported JS sources
/// build those strings from numeric templates. Parsing the literals keeps the
/// Swift drawings coordinate-identical to `src/ui/*.tsx` instead of
/// hand-translating every number. Unsupported commands trap — that is a
/// build-time content error, not runtime data.
enum SVGPathParser {
    static func path(_ d: String) -> Path {
        var path = Path()
        let tokens = d.split { $0 == " " || $0 == "," }
        var index = 0
        while index < tokens.count {
            switch tokens[index] {
            case "M":
                path.move(to: point(tokens, index + 1, d))
                index += 3
            case "L":
                path.addLine(to: point(tokens, index + 1, d))
                index += 3
            case "Q":
                let control = point(tokens, index + 1, d)
                let end = point(tokens, index + 3, d)
                path.addQuadCurve(to: end, control: control)
                index += 5
            case "Z":
                path.closeSubpath()
                index += 1
            default:
                preconditionFailure("SVG path: unsupported command '\(tokens[index])' in '\(d)'")
            }
        }
        return path
    }

    private static func point(_ tokens: [Substring], _ at: Int, _ source: String) -> CGPoint {
        guard at + 1 < tokens.count, let x = Double(tokens[at]), let y = Double(tokens[at + 1])
        else { preconditionFailure("SVG path: malformed numbers in '\(source)'") }
        return CGPoint(x: x, y: y)
    }
}

/// Illustration-space colors (hex ints); resolved to SwiftUI colors by the
/// Canvas helpers. Values copied from `src/ui/*.tsx`.
struct SVGColor: Equatable {
    let hex: Int
    init(hex: Int) { self.hex = hex }

    static let ink = SVGColor(hex: 0x2f3a35)      // dog silhouettes
    static let gearInk = SVGColor(hex: 0x4a554f)  // gear + schematic scenes
    static let accent = SVGColor(hex: 0x2e6f4e)
    static let treat = SVGColor(hex: 0xc9872b)
    static let blue = SVGColor(hex: 0x2a4a6b)
    static let white = SVGColor(hex: 0xffffff)

    var color: Color { Color(hex: hex) }
}

/// One drawing in a fixed viewBox, scaled to a point size like the SVG
/// `width/height + viewBox` pair it replaces.
struct GlyphCanvas: View {
    let size: CGFloat
    var viewBoxWidth: CGFloat = 100
    var viewBoxHeight: CGFloat = 100
    let draw: (inout GraphicsContext) -> Void

    var body: some View {
        Canvas { context, _ in
            var context = context
            context.scaleBy(x: size / viewBoxWidth, y: size / viewBoxHeight)
            draw(&context)
        }
        .frame(width: size, height: size * viewBoxHeight / viewBoxWidth)
        .accessibilityHidden(true) // every consumer labels the drawing itself
    }
}

extension GraphicsContext {
    mutating func fill(_ path: Path, _ color: SVGColor, opacity: Double = 1) {
        fill(path, with: .color(color.color.opacity(opacity)))
    }

    mutating func stroke(_ path: Path, _ color: SVGColor, width: CGFloat = 3,
                         dash: [CGFloat] = [], opacity: Double = 1) {
        stroke(path, with: .color(color.color.opacity(opacity)),
               style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dash))
    }

    func circle(_ cx: Double, _ cy: Double, _ r: Double) -> Path {
        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    }

    func roundedRect(x: Double, y: Double, w: Double, h: Double, radius: Double = 0) -> Path {
        Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: radius)
    }

    func svg(_ d: String) -> Path { SVGPathParser.path(d) }
}
