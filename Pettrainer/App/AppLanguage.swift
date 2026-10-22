import SwiftUI

/// App language choice: follow the device or force Polish/English.
///
/// The selection is stored twice on purpose: under our own key (the option
/// the settings UI shows and ContentLocale applies immediately to content),
/// and under AppleLanguages (how iOS picks the String Catalog localisation —
/// honoured for UI strings at the next launch; NSBundle caches the lookup per
/// process). UI copy states this so nobody hunts for a change that already
/// applied to training content but not yet to the chrome.
enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case polish = "pl"
    case english = "en"

    var id: String { rawValue }

    /// Language names are endonyms and stay untranslated; the "system" row
    /// is the only label that goes through the catalogue.
    var displayName: String {
        switch self {
        case .system: return ""  // rendered via language.system
        case .polish: return "Polski"
        case .english: return "English"
        }
    }

    var labelKey: LocalizedStringKey? {
        switch self {
        case .system: return "language.system"
        case .polish, .english: return nil
        }
    }
}

enum LanguageStore {
    private static let selectionKey = "app.language"

    static func load() -> AppLanguage {
        guard let raw = UserDefaults.standard.string(forKey: selectionKey),
              let stored = AppLanguage(rawValue: raw) else { return .system }
        return stored
    }

    /// One-time cleanup of the earlier experiment that steered the bundle
    /// via a persisted AppleLanguages override: that made relaunches lag a
    /// language switch by one session (NSBundle caches per process). All
    /// language resolution is in-process now (environment locale +
    /// StringsTable); the app's own key is the only persisted state.
    static func reconcileOnLaunch() {
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
    }

    /// Persist the choice. `.system` removes the override entirely.
    static func save(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: selectionKey)
    }
}

extension AppLanguage {
    /// The language content fields should use now; `nil` means resolve from
    /// the device as before.
    var contentOverride: String? {
        switch self {
        case .system: return nil
        case .polish: return "pl"
        case .english: return "en"
        }
    }
}
