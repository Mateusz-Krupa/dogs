import SwiftUI

/// One puppy-start foundation guide. The order is the safety contract: stop
/// first, what never helps, what to do right now, what to watch for, when to
/// hand over to a professional, optional later skills, and the citations.
/// Nothing here is scorable: no stage, no set, no completion control, no
/// saved reading state (spec: foundations are educational rather than scored).
struct PuppyGuideView: View {
    @EnvironmentObject private var model: AppModel
    let guideId: String

    private var guide: PuppyGuide? { model.content.puppyGuide(id: guideId) }

    var body: some View {
        if let guide {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DogPoseView(pose: guide.pose, size: 120,
                                color: PuppyPalette.dog, accent: PuppyPalette.accent)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .cardSurface()
                    Text(ContentLocale.value(guide.names).name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text(ContentLocale.value(guide.names).description)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.muted)
                    // Same non-veterinary statement as the hub and the care
                    // screens: never one tap away from the advice it qualifies.
                    Text("care.disclaimer")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    stopBlock(ContentLocale.value(guide.urgent))
                    bulletsBlock("problems.dont", ContentLocale.value(guide.avoid),
                                 accent: Theme.brick)
                    stepsBlock("problems.now", ContentLocale.value(guide.actions))
                    // Titled reading sections sit after the quick response and
                    // before the observation list: they are the long-form
                    // detail, never a ladder (no stage, no completion — spec:
                    // optional foundation sections).
                    ForEach(guide.sections, id: \.id) { section in
                        readingSection(section)
                    }
                    bulletsBlock("problems.observe", ContentLocale.value(guide.observe),
                                 accent: Theme.muted)
                    professionalBlock(ContentLocale.value(guide.professional))
                    if !guide.practices.isEmpty {
                        practiceChips(guide.practices)
                    }
                    GuidanceEvidenceView(evidence: guide.evidence)
                }
                .frame(maxWidth: Theme.contentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.gutter)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .background(Theme.ground)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// The same stop-box visual language as the problem cards: an owner
    /// skimming on one hand recognises where the advice stops.
    private func stopBlock(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("problems.stop")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.brick)
                .textCase(.uppercase)
            Text(text)
                .font(.system(size: 13.5))
                .foregroundStyle(Color(hex: 0x5A2417))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF7E8E2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) { Rectangle().fill(Theme.brick).frame(width: 3) }
    }

    private func professionalBlock(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("problems.professional")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.blue)
                .textCase(.uppercase)
            Text(text)
                .font(.system(size: 13.5))
                .foregroundStyle(Color(hex: 0x24384a))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xE7EDF3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) { Rectangle().fill(Theme.blue).frame(width: 3) }
    }

    private func bulletsBlock(_ labelKey: LocalizedStringKey, _ lines: [String],
                              accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(labelKey)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(accent)
                .textCase(.uppercase)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .top, spacing: 10) {
                    Text(verbatim: "•")
                        .font(.system(size: 15))
                        .foregroundStyle(accent)
                        .frame(width: 14, alignment: .center)
                    Text(line)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private func stepsBlock(_ labelKey: LocalizedStringKey, _ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(labelKey)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.green)
                .textCase(.uppercase)
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                HStack(alignment: .top, spacing: 10) {
                    Text(verbatim: "\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.green)
                        .frame(width: 14, alignment: .center)
                    Text(line)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    /// One titled chunk of long-form advice: a heading plus paragraphs on the
    /// same card surface as the bullet blocks, so a skimming owner sees where
    /// one chunk ends. No disclosure and no progress state — everything is
    /// readable without a tap, and nothing here can be "finished".
    private func readingSection(_ section: PuppyGuideSection) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(ContentLocale.value(section.title))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(Array(ContentLocale.value(section.paragraphs).enumerated()),
                    id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityIdentifier("puppy-section-\(section.id)")
    }

    private func practiceChips(_ practiceIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("problems.practices")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
                .textCase(.uppercase)
            ChipFlow {
                ForEach(practiceIds, id: \.self) { exerciseId in
                    if let entry = model.content.exercise(id: exerciseId) {
                        NavigationLink(value: Route.exercise(exerciseId: exerciseId)) {
                            Text(ContentLocale.value(entry.names).name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Capsule().fill(Theme.surface))
                                .overlay(Capsule().strokeBorder(Theme.line, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("puppy-practice-link-\(exerciseId)")
                    }
                }
            }
        }
    }
}
