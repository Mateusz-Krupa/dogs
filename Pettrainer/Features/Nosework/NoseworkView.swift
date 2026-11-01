import SwiftUI

/// A scent game, with no hit/miss anywhere — port of `NoseworkScreen.tsx`.
/// The whole screen is built around that absence: one button, labelled
/// "done", which records that the game happened. Nothing judges the dog.
struct NoseworkView: View {
    @EnvironmentObject private var model: AppModel
    let activityId: String
    @State private var selected: Int = 0
    /// True after a failed write: the last committed level stays shown and the
    /// button turns brick with the localized retry line (same contract as
    /// care; reviewer MG-2).
    @State private var saveFailed = false

    private var activity: NoseworkActivity? { model.content.noseworkActivity(id: activityId) }

    var body: some View {
        if let activity {
            let level = activity.levels[min(selected, activity.levels.count - 1)]
            let copy = ContentLocale.value(level.pl, en: level.en)
            let done = model.noseworkLevels[activity.id] ?? 0

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(spacing: 6) {
                            DogPoseView(pose: activity.pose, size: 120,
                                        color: SVGColor(hex: 0x2f3a35), accent: SVGColor.blue)
                            Text(ContentLocale.value(activity.names).name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Theme.ink)
                            Text(ContentLocale.value(activity.names).description)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        Text("nosework.notScored")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color(hex: 0xE7EDF3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        levelPicker(activity: activity, done: done)
                        levelCard(copy: copy, level: level)
                    }
                    .frame(maxWidth: Theme.contentWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Theme.gutter)
                    .padding(.bottom, 20)
                }

                VStack(spacing: 8) {
                    if saveFailed {
                        Text("care.saveFailed")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.brick)
                    }
                    Button {
                        saveFailed = !model.recordNoseworkCompletion(activityId: activity.id,
                                                                     levelOrdinal: level.ordinal)
                    } label: {
                        Text("nosework.done")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(saveFailed ? Theme.brick : Theme.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.vertical, 12)
                .background(Theme.ground)
                .overlay(alignment: .top) { Divider() }
            }
            .background(Theme.ground)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selected = min(max(done - 1, 0), activity.levels.count - 1)
            }
        }
    }

    private func levelPicker(activity: NoseworkActivity, done: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("nosework.title", selection: $selected) {
                ForEach(Array(activity.levels.indices), id: \.self) { index in
                    Text(verbatim: fmt("nosework.level", index + 1, activity.levels.count))
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            if done > 0 && done - 1 == selected {
                HStack(spacing: 4) {
                    Text(verbatim: "✓")
                    Text(verbatim: fmt("nosework.level", done, activity.levels.count))
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.green)
            }
        }
    }

    private func levelCard(copy: LevelCopy, level: NoseworkLevel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(copy.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.ink)

            SetupSceneView(activity: activityId, level: level.ordinal, width: 260)
                .frame(maxWidth: .infinity, alignment: .center)

            labeledText("nosework.setup", copy.setup)
            labeledText("nosework.how", copy.how)
            labeledText("nosework.watchFor", copy.watchFor)

            HStack(spacing: 10) {
                Text(verbatim: fmt("nosework.minutes", Int(level.minutes)))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.muted)
                Spacer()
                GearRowView(gear: level.gear, compact: true, color: SVGColor.blue)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(stroke: Theme.blue.opacity(0.35))
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
        }
    }
}
