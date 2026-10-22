import SwiftUI

/// The one palette the JS screens repeated in four files (ink/green/amber/
/// brick/white/surface/line/blue). Values are copied verbatim so screenshots
/// stay comparable; screens reference these tokens, never raw hex again.
enum Theme {
    static let ink = Color(hex: 0x14181a)
    static let muted = Color(hex: 0x6b_746e)
    static let green = Color(hex: 0x2e_6f4e)
    static let amber = Color(hex: 0x91_661a)
    static let brick = Color(hex: 0xa8_402c)
    static let surface = Color(hex: 0xff_ffff)
    static let ground = Color(hex: 0xf1_f3ee)
    static let line = Color(hex: 0xe3_e7_df)
    static let blue = Color(hex: 0x2a_4a6b)

    /// Reading column of the phone-first screens (maxWidth in the JS styles).
    static let contentWidth: CGFloat = 560
    static let gutter: CGFloat = 18

    static let verdictColor: [Verdict: Color] = [
        .push: green, .stick: amber, .drop: brick,
    ]
}

extension Color {
    init(hex: Int) {
        self = Color(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: 1
        )
    }
}

/// Formats a String-Catalog key with positional arguments. SwiftUI's
/// `Text("\(interpolated)")` keys include the literal text between the
/// arguments, which would make the catalog keys unmanageable; this helper
/// keeps one clean key per phrase (e.g. `catalogue.stepMeta` =
/// "Krok %1$d/%2$d · %3$@"). Ints bridge through NSNumber so %d is exact.
func fmt(_ key: String, _ arguments: Any...) -> String {
    // Ints must pass through raw with %lld in the catalog; NSNumber with
    // %d/%lld encodes a pointer and prints garbage (caught in the phone sim).
    let args: [CVarArg] = arguments.map { value in
        if let int = value as? Int { return int }
        if let string = value as? String { return string }
        preconditionFailure("fmt: unsupported argument type \(type(of: value))")
    }
    let template: String
    if let language = ContentLocale.override {
        template = StringsTable.string(key, language: language)
    } else {
        template = NSLocalizedString(key, bundle: .main, comment: "")
    }
    return String(format: template, arguments: args)
}
