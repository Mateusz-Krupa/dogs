import SwiftUI

/// The browsable curriculum — the native port of `ExerciseList.tsx`. Every
/// card opens; nothing is gated. Sections: exercises, nosework, problems.
struct CatalogueView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("catalogue.section")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Theme.muted)
                    .textCase(.uppercase)
                Text("dog.label")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("catalogue.sub")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.muted)

                exerciseSection
                careSection
                noseworkSection
                problemsSection
            }
            .frame(maxWidth: Theme.contentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Theme.gutter)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Theme.ground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker(selection: $model.language) {
                        ForEach(AppLanguage.allCases) { language in
                            if let key = language.labelKey {
                                Text(key).tag(language)
                            } else {
                                Text(verbatim: language.displayName).tag(language)
                            }
                        }
                    } label: {
                        Text("language.title")
                    }
                    // The menu is ONLY the language switch. The switch-off
                    // notice and the non-veterinary statement live on the
                    // content screens that need them (care section, puppy
                    // hub and every guide), not in the picker chrome.
                } label: {
                    Image(systemName: "globe")
                        .foregroundStyle(Theme.green)
                }
                .accessibilityLabel(Text("language.title"))
            }
        }
    }

    private var exerciseSection: some View {
        VStack(spacing: 10) {
            PuppyStartEntryRow()
            ForEach(model.content.catalogue, id: \.id) { entry in
                NavigationLink(value: Route.exercise(exerciseId: entry.id)) {
                    ExerciseCardView(
                        entry: entry,
                        position: model.positions[entry.id],
                        masteryByEnvironment: model.mastery[entry.id] ?? [:],
                        recommended: entry.id == model.recommendedExerciseId,
                        environmentNames: environmentNames,
                        startedIds: Set(model.positions.keys),
                        prerequisiteNames: prerequisiteNames(for: entry),
                        environmentLadder: model.content.environments
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("exercise-link-\(entry.id)")
            }
        }
    }

    private var noseworkSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("nosework.title", "nosework.subtitle")
            ForEach(model.content.nosework, id: \.id) { activity in
                NoseworkCardRow(activity: activity)
            }
        }
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("care.title", "care.subtitle")
            // The not-veterinary-advice statement is mandatory at the section
            // level, not only inside each routine, so it is never one tap away.
            Text("care.disclaimer")
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(model.content.care, id: \.id) { routine in
                CareCardRow(routine: routine)
            }
        }
    }

    private var problemsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("problems.title", "problems.subtitle")
            ForEach(model.content.behaviour, id: \.id) { issue in
                ProblemCardRow(issue: issue)
            }
        }
    }

    private var environmentNames: [String: String] {
        Dictionary(uniqueKeysWithValues: model.content.environments.map {
            ($0.id, ContentLocale.value($0.names))
        })
    }

    private func prerequisiteNames(for entry: CatalogueEntry) -> [String: String] {
        var names: [String: String] = [:]
        for id in entry.requires {
            if let required = model.content.exercise(id: id) {
                names[id] = ContentLocale.value(required.names).name
            }
        }
        return names
    }
}

private func sectionHeader(_ titleKey: LocalizedStringKey, _ subKey: LocalizedStringKey) -> some View {
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

/// A nosework row: pose, tagline, level count or "Level n of total".
struct NoseworkCardRow: View {
    @EnvironmentObject private var model: AppModel
    let activity: NoseworkActivity

    var body: some View {
        NavigationLink(value: Route.nosework(activityId: activity.id)) {
            HStack(spacing: 12) {
                DogPoseView(pose: activity.pose, size: 56, color: SVGColor(hex: 0x6f7a74),
                            accent: SVGColor.blue)
                VStack(alignment: .leading, spacing: 3) {
                    Text(ContentLocale.value(activity.names).name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(ContentLocale.value(activity.tagline))
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                    let done = model.noseworkLevels[activity.id] ?? 0
                    Text(verbatim: done > 0
                        ? fmt("nosework.level", done, activity.levels.count)
                        : fmt("catalogue.levelsCount", activity.levels.count))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.muted)
            }
            .padding(14)
            .cardSurface(stroke: SVGColor.blue.color.opacity(0.35))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("nosework-link-\(activity.id)")
        .accessibilityElement(children: .combine)
    }
}

/// A behaviour-problem row.
struct ProblemCardRow: View {
    let issue: BehaviourIssue

    var body: some View {
        NavigationLink(value: Route.problem(issueId: issue.id)) {
            HStack(spacing: 12) {
                if ProblemScene.exists(id: issue.id) {
                    // Every shipped problem has a scene; the guard keeps a
                    // future content-only row from rendering an empty frame.
                    ProblemSceneView(id: issue.id, size: 56)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(ContentLocale.value(issue.names).name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(ContentLocale.value(issue.names).tagline)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.muted)
            }
            .padding(14)
            .cardSurface()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("problem-link-\(issue.id)")
        .accessibilityElement(children: .combine)
    }
}

extension View {
    func cardSurface(stroke: Color? = nil) -> some View {
        background(
            RoundedRectangle(cornerRadius: 16).fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(stroke ?? Theme.line, lineWidth: 1)
                )
        )
    }
}
