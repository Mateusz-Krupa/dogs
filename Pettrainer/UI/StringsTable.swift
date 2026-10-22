import Foundation

/// Runtime-resolved access to the compiled String Catalog.
///
/// `NSLocalizedString` binds to the language the bundle picked at first use
/// (NSBundle caches it per process), which is why the in-app language menu
/// used to leave the chrome in the old language until the next launch. This
/// table reads the same per-language `Localizable.strings` Apple compiled
/// from `Localizable.xcstrings` out of the bundle on demand, so a language
/// change applies to every string immediately.
enum StringsTable {
    private static var cache: [String: [String: String]] = [:]
    private static let lock = NSLock()

    /// Localizes `key` for `language`, falling back to the base table, then
    /// to the key itself (mirrors NSLocalizedString semantics).
    static func string(_ key: String, language: String) -> String {
        table(for: language)[key]
            ?? table(for: baseLanguage)[key]
            ?? key
    }

    /// The bundle's development region (the catalog's base side).
    static var baseLanguage: String {
        Bundle.main.developmentLocalization ?? "pl"
    }

    private static func table(for language: String) -> [String: String] {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[language] { return cached }
        let loaded = load(language) ?? [:]
        cache[language] = loaded
        return loaded
    }

    private static func load(_ language: String) -> [String: String]? {
        guard let url = Bundle.main.url(forResource: "Localizable",
                                        withExtension: "strings",
                                        subdirectory: nil,
                                        localization: language),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
              let dictionary = plist as? [String: String] else { return nil }
        return dictionary
    }
}
