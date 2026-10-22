import SwiftUI

/// App entry point. Composition happens here only: content, storage and the
/// root model are wired once and handed to `RootView`.
@main
struct PettrainerApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                // In-app language override: Text keys resolve through the
                // environment locale, fmt() through StringsTable; `.id`
                // guarantees every already-rendered view re-localizes.
                .environment(\.locale, model.environmentLocale ?? .autoupdatingCurrent)
                .id(model.language)
        }
    }
}
