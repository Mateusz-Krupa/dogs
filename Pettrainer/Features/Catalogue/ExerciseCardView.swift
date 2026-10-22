import SwiftUI

/// One curriculum card. Progress facts and the mastered badges (F-2
/// corrected: earned by push sets, never by position) are computed from the
/// passed-in rows; names and taglines are localized domain data, not UI keys.
struct ExerciseCardView: View {
    let entry: CatalogueEntry
    let position: Position?
    /// environmentId → highest push-earned step for this dog and exercise.
    let masteryByEnvironment: [String: Int]
    let recommended: Bool
    let environmentNames: [String: String]
    let startedIds: Set<String>
    let prerequisiteNames: [String: String]
    let environmentLadder: [EnvironmentSeed]

    private var stepCount: Int { entry.steps.count }

    private func earned(_ environmentId: String) -> Int { masteryByEnvironment[environmentId] ?? 0 }

    private var masteredHere: Bool {
        guard let position else { return false }
        return earned(position.environmentId) >= stepCount
    }

    private var masteredEverywhere: Bool {
        position != nil && !environmentLadder.isEmpty
            && environmentLadder.allSatisfy { earned($0.id) >= stepCount }
    }

    private var cleared: Int {
        guard let position else { return 0 }
        return Progression.rungsCleared(
            position, stepCount: stepCount, ladder: environmentLadder.map(\.id))
    }

    private var missingPrerequisites: [String] {
        entry.requires.filter { !startedIds.contains($0) }.compactMap { prerequisiteNames[$0] }
    }

    private var names: CueNames { ContentLocale.value(entry.names) }
    private var tagline: String { ContentLocale.value(entry.tagline) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                DogPoseView(pose: entry.pose, size: 64)
                VStack(alignment: .leading, spacing: 3) {
                    Text(names.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(tagline)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                badges
            }

            HStack {
                metaText
                Spacer()
                GearRowView(gear: entry.gear, compact: true)
            }

            // The rung ladder: cleared rungs read as climbed route.
            HStack(spacing: 4) {
                ForEach(Array(environmentLadder.enumerated()), id: \.element.id) { index, rung in
                    Circle()
                        .fill(index < cleared ? Theme.green : Color(hex: 0xCCD4CA))
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                }
                Text(verbatim: fmt("session.rungs", cleared, environmentLadder.count))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.muted)
            }

            if !missingPrerequisites.isEmpty {
                Text(verbatim: fmt("catalogue.prereqHint", joinedPrerequisites))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(14)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var badges: some View {
        if masteredEverywhere {
            pill("session.fullyMastered", fill: Theme.green, text: .white, checkmark: true)
        } else if masteredHere {
            pill("session.masteredHere", fill: Theme.green, text: .white, checkmark: true)
        } else if recommended {
            pill("catalogue.nextUp", fill: Theme.ground, text: Theme.green, checkmark: false)
        }
    }

    @ViewBuilder private var metaText: some View {
        if let position {
            let envName = environmentNames[position.environmentId] ?? position.environmentId
            Text(verbatim: fmt("catalogue.stepMeta", position.stepOrdinal, stepCount, envName))
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)
        } else {
            Text(verbatim: fmt("catalogue.stepsCount", stepCount))
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)
        }
    }

    private var joinedPrerequisites: String {
        missingPrerequisites.joined(separator: ContentLocale.current == "en" ? " and " : " i ")
    }
}

private func pill(_ key: LocalizedStringKey, fill: Color, text: Color, checkmark: Bool) -> some View {
    HStack(spacing: 3) {
        if checkmark { Text(verbatim: "✓") }
        Text(key)
    }
    .font(.system(size: 11, weight: .semibold))
    .foregroundStyle(text)
    .padding(.horizontal, 8)
    .padding(.vertical, 3)
    .background(Capsule().fill(fill))
}
