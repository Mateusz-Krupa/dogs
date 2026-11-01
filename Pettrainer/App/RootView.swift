import SwiftUI

/// The root shell: one NavigationStack and the same three destinations the
/// JS `App.tsx` switched between by hand. The list is the root; exercise,
/// nosework and problem screens push on top of it.
struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch model.state {
                case .ready:
                    CatalogueView()
                case .storageUnavailable:
                    StorageRecoveryView(onRetry: model.retryStorage)
                }
            }
            .navigationDestination(for: Route.self) { route in
                destination(route)
            }
        }
        .tint(Theme.green)
    }

    @ViewBuilder
    private func destination(_ route: Route) -> some View {
        switch route {
        case .exercise(let id):
            SetView(exerciseId: id)
        case .nosework(let id):
            NoseworkView(activityId: id)
        case .problem(let id):
            ProblemView(issueId: id)
        case .care(let id):
            CareView(routineId: id)
        case .puppyStart:
            PuppyStartView()
        case .puppyGuide(let id):
            PuppyGuideView(guideId: id)
        }
    }
}

/// Localized recovery screen for damaged/newer storage: never a reset
/// button, never data loss — retry re-opens the same file.
struct StorageRecoveryView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("errors.generic")
                .font(.system(size: 17, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 30)
            Button(action: onRetry) {
                Text("common.retry")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Theme.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.ground)
    }
}


