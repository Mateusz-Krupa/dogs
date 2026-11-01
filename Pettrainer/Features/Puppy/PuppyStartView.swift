import SwiftUI

/// The single catalogue row that opens the hub. It sits above the scored
/// exercises: one entry, never a grid of puppy "courses" — and no card that
/// pretends resting or feeling safe is a thing the dog can pass or fail.
struct PuppyStartEntryRow: View {
    var body: some View {
        NavigationLink(value: Route.puppyStart) {
            HStack(spacing: 12) {
                // A puppy bounding in: the entry reads as part of the catalogue,
                // not a text banner the other families don't have.
                DogPoseView(pose: .come, size: 56,
                            color: PuppyPalette.dog, accent: PuppyPalette.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("puppy.title")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("puppy.subtitle")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.muted)
            }
            .padding(14)
            .cardSurface(stroke: Theme.green.opacity(0.4))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("puppy-link")
        .accessibilityElement(children: .combine)
    }
}

/// The puppy-start hub: one entry, two short lists, and a disclaimer that is
/// never a tap away. "Help now" links reuse the canonical behaviour cards —
/// there is no second copy of them under a puppy namespace. Order is pinned
/// by `PuppyContentTests`, so this view may not improvise it.
struct PuppyStartView: View {
    @EnvironmentObject private var model: AppModel

    /// Spec order: what may strike in the moment first, the situation-specific
    /// cards after. The ids are behaviour ids, not guide ids.
    static let helpIssueIds = ["overarousal", "fear-withdrawal", "nipping", "mounting"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("puppy.title")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("puppy.subtitle")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.muted)
                // Same non-veterinary statement the care section carries at
                // its section level: mandatory here too, not one tap away.
                Text("care.disclaimer")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                header("puppy.help", "puppy.helpSub")
                ForEach(Self.helpIssueIds, id: \.self) { issueId in
                    if let issue = model.content.behaviourIssue(id: issueId) {
                        NavigationLink(value: Route.problem(issueId: issueId)) {
                            PuppyHubRow(
                                title: ContentLocale.value(issue.names).name,
                                subtitle: ContentLocale.value(issue.names).tagline
                            ) {
                                if ProblemScene.exists(id: issueId) {
                                    // Every shipped card has a scene (contract-tested);
                                    // the guard only protects the layout, never
                                    // hides an action.
                                    ProblemSceneView(id: issueId, size: 56)
                                } else {
                                    Color.clear.frame(width: 56, height: 56)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("puppy-help-link-\(issueId)")
                    }
                }

                header("puppy.foundation", "puppy.foundationSub")
                ForEach(model.content.puppyGuides, id: \.id) { guide in
                    NavigationLink(value: Route.puppyGuide(guideId: guide.id)) {
                        PuppyHubRow(
                            title: ContentLocale.value(guide.names).name,
                            subtitle: ContentLocale.value(guide.names).description
                        ) {
                            DogPoseView(pose: guide.pose, size: 56,
                                        color: SVGColor(hex: 0x6f7a74),
                                        accent: PuppyPalette.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("puppy-guide-link-\(guide.id)")
                }
            }
            .frame(maxWidth: Theme.contentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Theme.gutter)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Theme.ground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func header(_ titleKey: LocalizedStringKey,
                        _ subKey: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titleKey)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(subKey)
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)
        }
        .padding(.top, 10)
    }
}

/// The green accent shared by the puppy hub thumbnails and the catalogue
/// entry row, so the section reads as one family like the blue nosework rows.
enum PuppyPalette {
    static let accent = SVGColor(hex: 0x2e6f4e)
    static let dog = SVGColor(hex: 0x6f7a74)
}

/// A hub line: thumbnail + title + one muted subtitle. No progress state —
/// reading a guide is not an achievement to display.
private struct PuppyHubRow<Thumbnail: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var thumbnail: () -> Thumbnail

    var body: some View {
        HStack(spacing: 12) {
            thumbnail()
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.muted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.muted)
        }
        .padding(14)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
}
