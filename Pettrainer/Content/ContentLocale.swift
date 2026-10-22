import Foundation

/// Which of the two shipped catalogues the UI shows.
///
/// Port of `resolveLocale` in `src/i18n/index.ts`: match on the primary
/// subtag, first hit wins, anything unsupported falls back to Polish (the
/// default locale). The String Catalog resolves UI keys itself through iOS
/// with the same fallback; this helper decides which copy field of the
/// bilingual content JSON to read (cue names, step text, cards) so one
/// language is chosen consistently everywhere.
enum ContentLocale {
    static let supported = ["pl", "en"]
    static let fallback = "pl"

    /// Pure port of `resolveLocale(preferred)`; unit-testable without the
    /// device.
    static func resolve(preferredTags: [String]) -> String {
        for tag in preferredTags {
            let primary = tag.lowercased()
                .split(whereSeparator: { $0 == "-" || $0 == "_" })
                .first.map(String.init) ?? ""
            let trimmed = primary.trimmingCharacters(in: .whitespaces)
            if supported.contains(trimmed) { return trimmed }
            if !trimmed.isEmpty { continue }
        }
        return fallback
    }

    /// Explicit owner choice from Settings (nil = follow the device).
    static var override: String?

    /// The active language on this device, resolved onto a supported one.
    static var current: String {
        if let override, supported.contains(override) { return override }
        return resolve(preferredTags: Locale.preferredLanguages)
    }

    /// Picks one side of a localized record.
    static func value<Value>(_ localized: Localized<Value>) -> Value {
        current == "en" ? localized.en : localized.pl
    }

    /// Explicit two-field form for records kept as separate `pl`/`en`
    /// members (steps, level copy, mistakes) instead of a `Localized` pair.
    static func value<V>(_ pl: V, en: V) -> V {
        current == "en" ? en : pl
    }

    /// The step copy in the active content language.
    static func stepCopy(_ step: StepSeed) -> StepCopy {
        value(step.pl, en: step.en)
    }
}
