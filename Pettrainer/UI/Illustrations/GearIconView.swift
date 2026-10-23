import SwiftUI

/// What you need before you start — port of `src/ui/Gear.tsx`. Deliberately
/// geometric rather than illustrative: these sit at 28 px in a row, where a
/// drawing turns to mush but a recognisable outline does not. Each is built
/// from the smallest number of shapes that still names the object.
/// Canvas is 32×32 throughout (drawn in a 100 space scaled by 100/32).
struct GearIconView: View {
    let gear: GearId
    var size: CGFloat = 28
    var color = SVGColor.gearInk

    var body: some View {
        GlyphCanvas(size: size, viewBoxWidth: 100, viewBoxHeight: 100) { context in
            let k: CGFloat = 100 / 32 // 32-unit artwork in the 100-unit canvas
            context.scaleBy(x: k, y: k)
            draw(&context)
        }
    }

    private func draw(_ context: inout GraphicsContext) {
        let color = self.color
        func stroked(_ d: String, opacity: Double = 1) {
            context.stroke(context.svg(d), color, width: 2, opacity: opacity)
        }
        func outlined(_ cx: Double, _ cy: Double, _ r: Double, opacity: Double = 1) {
            context.stroke(context.circle(cx, cy, r), color, width: 2, opacity: opacity)
        }
        func filled(_ cx: Double, _ cy: Double, _ r: Double) {
            context.fill(context.circle(cx, cy, r), color)
        }

        switch gear {
        case .treats: // a pouch with pieces spilling
            stroked("M 7 12 L 25 12 L 23 26 L 9 26 Z")
            stroked("M 11 12 Q 16 5 21 12")
            filled(13, 19, 2)
            filled(19, 21, 2)
        case .lead: // clip and a short curve
            stroked("M 8 8 Q 18 10 20 20 Q 21 25 25 25")
            context.stroke(context.roundedRect(x: 4, y: 5, w: 7, h: 7, radius: 3.5), color, width: 2)
            outlined(25, 25, 3)
        case .longline: // a long, loose line in loops
            stroked("M 4 10 Q 12 2 16 10 Q 20 18 26 12")
            stroked("M 4 20 Q 12 12 16 20 Q 20 28 26 22")
        case .mat:
            context.stroke(context.roundedRect(x: 4, y: 11, w: 24, h: 12, radius: 4), color, width: 2)
            stroked("M 9 17 L 23 17", opacity: 0.5)
        case .towel: // rolled cloth, seen end-on
            context.stroke(context.roundedRect(x: 5, y: 10, w: 22, h: 13, radius: 6.5), color, width: 2)
            stroked("M 12 10 Q 14 16.5 12 23", opacity: 0.6)
            stroked("M 19 10 Q 21 16.5 19 23", opacity: 0.6)
        case .box:
            stroked("M 5 12 L 16 8 L 27 12 L 27 24 L 16 28 L 5 24 Z")
            stroked("M 5 12 L 16 16 L 27 12")
            stroked("M 16 16 L 16 28")
        case .toy: // a tug/bone shape
            stroked("M 10 13 Q 16 16 22 13")
            stroked("M 10 19 Q 16 16 22 19")
            outlined(8, 13, 3.2); outlined(8, 19, 3.2)
            outlined(24, 13, 3.2); outlined(24, 19, 3.2)
        case .cups:
            stroked("M 4 24 L 6 14 L 12 14 L 14 24 Z")
            stroked("M 13 24 L 15 12 L 21 12 L 23 24 Z")
            stroked("M 22 24 L 24 16 L 29 16 L 30 24 Z")
        case .clippers:
            stroked("M 8 6 L 20 20")
            stroked("M 20 6 L 8 20")
            outlined(22, 24, 4)
            outlined(7, 24, 4)
        case .bowl:
            stroked("M 5 14 L 27 14 L 23 25 L 9 25 Z")
            stroked("M 5 14 Q 16 10 27 14")
        case .helper:
            outlined(16, 10, 4.5)
            stroked("M 7 27 Q 8 17 16 17 Q 24 17 25 27")
        case .door:
            context.stroke(context.roundedRect(x: 8, y: 4, w: 16, h: 24, radius: 2), color, width: 2)
            filled(20, 17, 1.6)
        case .grass:
            stroked("M 6 26 Q 7 16 10 13")
            stroked("M 12 26 Q 13 14 17 10")
            stroked("M 19 26 Q 20 15 24 12")
            stroked("M 25 26 Q 26 19 28 16")
        case .brush: // pad with bristles
            context.stroke(context.roundedRect(x: 7, y: 8, w: 18, h: 7, radius: 3.5), color, width: 2)
            stroked("M 9 15 L 9 22")
            stroked("M 13 15 L 13 23")
            stroked("M 16 15 L 16 23")
            stroked("M 19 15 L 19 23")
            stroked("M 23 15 L 23 22")
        case .toothbrush: // handle angled up to a small head
            stroked("M 6 26 L 17 15")
            stroked("M 17 15 Q 21 11 25 7")
            stroked("M 18 11 L 21 14", opacity: 0.6)
            stroked("M 21 8 L 24 11", opacity: 0.6)
        case .dogToothpaste: // tube, crimped at the top, paste at the nozzle
            stroked("M 12 8 L 20 8")
            stroked("M 12 8 L 12 18 Q 16 23 20 18 L 20 8")
            filled(16, 25, 2)
        case .dogShampoo: // bottle with a pump
            context.stroke(context.roundedRect(x: 12, y: 13, w: 9, h: 13, radius: 3), color, width: 2)
            stroked("M 15 13 L 15 10 L 19 10 L 19 13")
            stroked("M 17 10 L 17 6 L 22 6")
        case .styptic: // jar marked with a cross
            context.stroke(context.roundedRect(x: 11, y: 13, w: 11, h: 12, radius: 2), color, width: 2)
            context.stroke(context.roundedRect(x: 12, y: 9, w: 9, h: 4, radius: 1.5), color, width: 2)
            stroked("M 16.5 16 L 16.5 22")
            stroked("M 13.5 19 L 19.5 19")
        case .nothing:
            outlined(16, 16, 11, opacity: 0.5)
            stroked("M 9 23 L 23 9", opacity: 0.5)
        }
    }
}

/// "What you need" — port of `GearRow.tsx`: labelled pills by default, icons
/// alone in list cards (scanned, not read), with the names folded into one
/// accessibility label.
struct GearRowView: View {
    let gear: [GearId]
    var compact = false
    var color = SVGColor.gearInk

    var body: some View {
        if gear.isEmpty {
            EmptyView()
        } else if compact {
            HStack(spacing: 5) {
                ForEach(gear, id: \.self) { id in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(Theme.ground)
                        GearIconView(gear: id, size: 17, color: color)
                    }
                    .frame(width: 26, height: 26)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(gear.accessibilitySummary)
        } else {
            VStack(alignment: .leading, spacing: 7) {
                Text("gear.title")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(color.color)
                    .textCase(.uppercase)
                HStack(spacing: 8) {
                    ForEach(gear, id: \.self) { id in
                        HStack(spacing: 7) {
                            GearIconView(gear: id, size: 26, color: color)
                            Text(verbatim: fmt("gear.\(id.rawValue)"))
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: 0x3a433f))
                        }
                        .padding(.vertical, 6)
                        .padding(.leading, 8)
                        .padding(.trailing, 13)
                        .background(
                            Capsule().fill(Theme.surface)
                                .overlay(Capsule().strokeBorder(Theme.line, lineWidth: 1))
                        )
                    }
                }
            }
        }
    }
}

private extension Array where Element == GearId {
    /// One label for the whole compact row, mirroring the JS
    /// `accessibilityLabel` ("What you need: treats, lead").
    var accessibilitySummary: String {
        func text(_ key: String) -> String {
            NSLocalizedString(key, bundle: .main, comment: "")
        }
        let names = map { text("gear.\($0.rawValue)") }
        return "\(text("gear.title")): \(names.joined(separator: ", "))"
    }
}
