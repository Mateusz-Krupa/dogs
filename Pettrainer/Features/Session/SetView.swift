import SwiftUI

/// The set screen: the one view used outdoors, one-handed, on a lead.
/// Everything the thumb needs sits at the bottom dock and never moves;
/// everything the eye needs scrolls above it. Port of `SetScreen.tsx`
/// (the dock lives in `SetDockView.swift`).
struct SetView: View {
    @EnvironmentObject private var model: AppModel
    let exerciseId: String
    @State private var session: SetModel?

    var body: some View {
        Group {
            if let session {
                SetContentView(session: session)
            } else {
                Color.clear
                    .task { session = model.makeSessionModel(exerciseId: exerciseId) }
            }
        }
        .background(Theme.ground)
    }
}

/// Owns the live set; split from `SetView` so `@ObservedObject` updates the
/// whole screen when the repository commits.
private struct SetContentView: View {
    @ObservedObject var session: SetModel

    private var copy: StepCopy { ContentLocale.stepCopy(session.currentStep) }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    StepRail(ordinal: session.position.stepOrdinal,
                             count: session.entry.steps.count)
                    if let placeChange = session.placeChange {
                        placeNote(placeChange)
                    }
                    card
                    if let setup = copy.setup, !setup.isEmpty {
                        bullets(listLabel("session.setup"), setup, numbered: false)
                    }
                    if let reps = copy.reps, !reps.isEmpty {
                        bullets(listLabel("session.oneRep"), reps, numbered: true)
                    }
                    if let note = copy.note { noteBlock(note) }
                    GearRowView(gear: session.entry.gear)
                    criterionBlock(copy.criterion)
                    disclosures
                }
                .frame(maxWidth: Theme.contentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.gutter)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            SetDockView(session: session)
                .background(Theme.ground)
                .overlay(alignment: .top) { Divider() }
        }
        .background(Theme.ground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(ContentLocale.value(session.entry.names).name)
                        .font(.system(size: 17, weight: .semibold))
                    Text(verbatim: fmt("session.barMeta",
                                        ContentLocale.value(session.environment.names),
                                        session.position.stepOrdinal,
                                        session.entry.steps.count))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.muted)
                }
            }
        }
    }

    // MARK: Blocks (styles ported from SetScreen.tsx StyleSheet)

    private var card: some View {
        VStack(spacing: 10) {
            StepDiagramView(pose: session.pose, motion: session.motion,
                            stage: session.stage, sound: session.currentStep.sound,
                            size: 150)
            Text(copy.instruction)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .cardSurface()
    }

    private func placeNote(_ change: SetModel.PlaceChange) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(change == .harder ? "session.newPlaceTitle" : "session.easierPlaceTitle")
                .font(.system(size: 13.5, weight: .bold))
                .foregroundStyle(Color(hex: 0x24384a))
            Text(change == .harder ? "session.newPlaceBody" : "session.easierPlaceBody")
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: 0x3b4f5f))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xE7EDF3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) { Rectangle().fill(Theme.blue).frame(width: 3) }
    }

    private func listLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.system(size: 10, weight: .bold))
            .tracking(1.1)
            .foregroundStyle(Theme.muted)
            .textCase(.uppercase)
    }

    private func bullets(_ label: some View, _ lines: [String], numbered: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            label
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                HStack(alignment: .top, spacing: 10) {
                    Text(verbatim: numbered ? "\(index + 1)" : "•")
                        .font(.system(size: numbered ? 12 : 15, weight: numbered ? .bold : .regular))
                        .foregroundStyle(Theme.green)
                        .frame(width: 14, alignment: .center)
                    Text(line)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private func noteBlock(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("session.note")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.amber)
                .textCase(.uppercase)
            Text(note)
                .font(.system(size: 13.5))
                .foregroundStyle(Color(hex: 0x4A3C1D))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF6F1E4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) { Rectangle().fill(Theme.amber).frame(width: 3) }
    }

    private func criterionBlock(_ criterion: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("session.criterionLabel")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.green)
                .textCase(.uppercase)
            Text(criterion)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: 0x294036))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xE8F0EA))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .leading) { Rectangle().fill(Theme.green).frame(width: 3) }
    }

    // MARK: Disclosures (F-4 inline copy from the JS screen)

    @State private var showAbout = false
    @State private var openMistake: Int?

    private var disclosures: some View {
        VStack(alignment: .leading, spacing: 8) {
            DisclosureRow(titleKey: "session.aboutTitle", expanded: $showAbout) {
                Text(ContentLocale.value(session.entry.names).description)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.muted)
            }
            if !mistakes.isEmpty {
                Text("session.whenNotWorking")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Theme.muted)
                    .textCase(.uppercase)
                    .padding(.top, 2)
                ForEach(Array(mistakes.enumerated()), id: \.offset) { index, mistake in
                    let entry = ContentLocale.value(mistake.pl, en: mistake.en)
                    DisclosureRow(title: entry.symptom, expanded: Binding(
                        get: { openMistake == index },
                        set: { openMistake = $0 ? index : nil }
                    )) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.why)
                                .font(.system(size: 13.5))
                                .foregroundStyle(Theme.muted)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("session.tryThis")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(Theme.green)
                                Text(entry.fix)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.ink)
                            }
                        }
                    }
                }
            }
        }
    }

    private var mistakes: [Mistake] { session.model.content.mistakes(for: session.entry.id) }
}

/// One +/− disclosure row (about-text and per-mistake).
private struct DisclosureRow<Content: View>: View {
    private let titleKey: LocalizedStringKey?
    private let title: String?
    @Binding private var expanded: Bool
    @ViewBuilder private var content: () -> Content

    init(titleKey: LocalizedStringKey, expanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.titleKey = titleKey; title = nil; _expanded = expanded; self.content = content
    }

    init(title: String, expanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        titleKey = nil; self.title = title; _expanded = expanded; self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                expanded.toggle()
            } label: {
                HStack {
                    Group {
                        if let titleKey { Text(titleKey) } else { Text(verbatim: title ?? "") }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.muted)
                    Spacer()
                    Text(verbatim: expanded ? "−" : "+")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.muted)
                        .padding(.horizontal, 6)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if expanded { content() }
        }
        .animation(.easeInOut(duration: 0.15), value: expanded)
    }
}

/// The installation-axis rail: one segment per step, filled up to the current
/// one. Matches `StepRail` in the JS screen.
struct StepRail: View {
    let ordinal: Int
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<max(1, count), id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(index < ordinal ? Theme.green : Color(hex: 0xCCD4CA))
                    .frame(height: 6)
            }
        }
        .accessibilityLabel(Text(verbatim: "\(ordinal)/\(count)"))
    }
}
