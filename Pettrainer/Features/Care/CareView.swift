import SwiftUI

/// A hygiene routine: cooperation, not restraint — the care counterpart of
/// `NoseworkView`, and just as deliberately un-scored. The differences that
/// matter are safety-first ordering (spec: required visible safety stop-lines)
/// and honest participation wording (reviewer C-1): the record says which stage
/// an owner tried, never that the dog accepted anything.
struct CareView: View {
    @EnvironmentObject private var model: AppModel
    let routineId: String
    @State private var selected: Int = 0
    @State private var saveFailed = false

    private var routine: CareRoutine? { model.content.careRoutine(id: routineId) }

    var body: some View {
        if let routine {
            let stage = routine.stages[min(selected, routine.stages.count - 1)]
            let copy = ContentLocale.value(stage.pl, en: stage.en)
            let tried = model.careStages[routine.id] ?? 0

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header(routine)
                        Text("care.disclaimer")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Theme.line, lineWidth: 1))
                        safetyCard("problems.stop", ContentLocale.value(routine.urgent),
                                   stroke: Theme.brick.opacity(0.45))
                        safetyCard("problems.professional", ContentLocale.value(routine.professional),
                                   stroke: Theme.line)
                        stagePicker(routine: routine, tried: tried)
                        stageCard(copy: copy, stage: stage)
                        practices(routine)
                    }
                    .frame(maxWidth: Theme.contentWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Theme.gutter)
                    .padding(.bottom, 20)
                }

                VStack(spacing: 6) {
                    if saveFailed {
                        Text("care.saveFailed")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.brick)
                    }
                    Button {
                        // Published only after the write commits; a failure
                        // keeps the last committed maximum on screen.
                        saveFailed = !model.recordCareStageTried(routineId: routine.id,
                                                                stageOrdinal: stage.ordinal)
                    } label: {
                        Text("care.markTried")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(saveFailed ? Theme.brick : Theme.green)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("care-mark-tried")
                    Text("care.triedNote")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.top, 10)
                .padding(.bottom, 14)
                .background(Theme.ground)
                .overlay(alignment: .top) { Divider() }
            }
            .background(Theme.ground)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Start at the furthest point already tried, but never past the
                // last stage: stage 3 is an invitation, not a target.
                selected = min(max(tried - 1, 0), routine.stages.count - 1)
            }
        }
    }

    private func header(_ routine: CareRoutine) -> some View {
        VStack(spacing: 6) {
            DogPoseView(pose: routine.pose, size: 120, color: SVGColor.ink,
                        accent: SVGColor(hex: 0xa8402c))
            Text(ContentLocale.value(routine.names).name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.ink)
            Text(ContentLocale.value(routine.names).description)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    /// Safety blocks lead the screen — never behind a disclosure (C-2).
    private func safetyCard(_ titleKey: LocalizedStringKey, _ text: String,
                           stroke: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titleKey)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.brick)
                .textCase(.uppercase)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(stroke: stroke)
    }

    private func stagePicker(routine: CareRoutine, tried: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("care.title", selection: $selected) {
                ForEach(Array(routine.stages.indices), id: \.self) { index in
                    Text(verbatim: fmt("care.stage", index + 1, routine.stages.count)).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            // Participation wording: tried, not mastered, not completed.
            Text(verbatim: tried > 0
                 ? fmt("care.furthestTried", tried, routine.stages.count)
                 : fmt("care.untried"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.green)
        }
        .accessibilityIdentifier("care-stage-picker")
    }

    private func stageCard(copy: CareStageCopy, stage: CareStage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(copy.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.ink)

            // The stage's own hazard line comes before any instruction.
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.brick)
                Text(copy.stop)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.brick.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            labeledText("session.setup", copy.setup)
            labeledText("nosework.how", copy.how)
            labeledText("nosework.watchFor", copy.watchFor)

            GearRowView(gear: stage.gear, compact: true, color: SVGColor(hex: 0xa8402c))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(stroke: Theme.line)
        .accessibilityIdentifier("care-stage-\(stage.ordinal)")
    }

    /// Advisory practice links. Opening one is the normal exercise route and
    /// starts nothing here (the invariant reviewer A-1 made checkable).
    private func practices(_ routine: CareRoutine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("problems.practices")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
                .textCase(.uppercase)
            ForEach(routine.practices, id: \.self) { exerciseId in
                if let entry = model.content.exercise(id: exerciseId) {
                    NavigationLink(value: Route.exercise(exerciseId: exerciseId)) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.green)
                            Text(ContentLocale.value(entry.names).name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .cardSurface()
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("care-practice-\(exerciseId)")
                }
            }
        }
    }

    private func labeledText(_ key: LocalizedStringKey, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(key)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
                .textCase(.uppercase)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// A hygiene-routine row in the catalogue. Progress reads as an attempt
/// ("furthest stage tried") and never as a badge of completion.
struct CareCardRow: View {
    @EnvironmentObject private var model: AppModel
    let routine: CareRoutine

    var body: some View {
        NavigationLink(value: Route.care(routineId: routine.id)) {
            HStack(spacing: 12) {
                DogPoseView(pose: routine.pose, size: 56, color: SVGColor(hex: 0x6f7a74),
                            accent: SVGColor(hex: 0xa8402c))
                VStack(alignment: .leading, spacing: 3) {
                    Text(ContentLocale.value(routine.names).name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(ContentLocale.value(routine.tagline))
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                    let tried = model.careStages[routine.id] ?? 0
                    Text(verbatim: tried > 0
                        ? fmt("care.furthestTried", tried, routine.stages.count)
                        : fmt("care.untried"))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.muted)
            }
            .padding(14)
            .cardSurface(stroke: Theme.brick.opacity(0.28))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("care-link-\(routine.id)")
        .accessibilityElement(children: .combine)
    }
}
