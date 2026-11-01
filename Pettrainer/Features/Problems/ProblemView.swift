import SwiftUI

/// The section model of a behaviour card (port of `problemSections.ts`):
/// the welfare ordering is a tested value, not an accident of layout.
/// `urgent` must lead the actionable sections — an owner whose dog has bitten
/// or is panicking must see the stop sign before any protocol.
enum ProblemSections {
    static let order: [Kind] = [.urgent, .avoid, .now, .work]

    enum Kind: String, CaseIterable {
        case urgent, avoid, now, work

        var labelKey: LocalizedStringKey {
            switch self {
            case .urgent: return "problems.stop"
            case .avoid: return "problems.dont"
            case .now: return "problems.now"
            case .work: return "problems.work"
            }
        }

        var accent: Color {
            switch self {
            case .urgent, .avoid: return Theme.brick
            case .now: return Theme.green
            case .work: return Theme.muted
            }
        }

        enum Style { case stop, bullets, steps }

        var style: Style {
            switch self {
            case .urgent: return .stop
            case .avoid, .now: return .bullets
            case .work: return .steps
            }
        }
    }

    static func lines(_ issue: BehaviourIssue, _ kind: Kind) -> [String] {
        switch kind {
        case .urgent: return [ContentLocale.value(issue.urgent)]
        case .avoid: return ContentLocale.value(issue.avoid)
        case .now: return ContentLocale.value(issue.now)
        case .work: return ContentLocale.value(issue.work)
        }
    }
}

/// One behaviour problem, written for the moment of panic, not for study.
/// Card order: scene, name, recognises, [stop → warn → start → steps],
/// practice chips, professional box, sudden-change reminder — exactly the JS
/// screen; the chips open exercises and never gate the card.
struct ProblemView: View {
    @EnvironmentObject private var model: AppModel
    let issueId: String

    private var issue: BehaviourIssue? { model.content.behaviourIssue(id: issueId) }

    var body: some View {
        if let issue {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if ProblemScene.exists(id: issue.id) {
                        ProblemSceneView(id: issue.id, size: 160)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: .infinity)
                            .cardSurface()
                    }
                    Text(ContentLocale.value(issue.names).name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text(ContentLocale.value(issue.names).tagline)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.muted)
                    Text(ContentLocale.value(issue.recognizes))
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.ink)

                    ForEach(ProblemSections.order, id: \.self) { kind in
                        sectionBlock(issue, kind)
                    }

                    // Observation guidance is an extension: cards that carry
                    // it show it after the protocol sections and before the
                    // chips, so the stop-first order cannot regress.
                    if let observe = issue.observe {
                        observeBlock(ContentLocale.value(observe))
                    }

                    practiceChips(issue)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("problems.professional")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.1)
                            .foregroundStyle(Theme.blue)
                            .textCase(.uppercase)
                        Text(ContentLocale.value(issue.professional))
                            .font(.system(size: 13.5))
                            .foregroundStyle(Color(hex: 0x24384a))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0xE7EDF3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .leading) { Rectangle().fill(Theme.blue).frame(width: 3) }

                    Text("problems.sudden")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Theme.muted)

                    if let evidence = issue.evidence {
                        GuidanceEvidenceView(evidence: evidence)
                    }
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

    @ViewBuilder
    private func observeBlock(_ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("problems.observe")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
                .textCase(.uppercase)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .top, spacing: 10) {
                    Text(verbatim: "•")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.muted)
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

    @ViewBuilder
    private func sectionBlock(_ issue: BehaviourIssue, _ kind: ProblemSections.Kind) -> some View {
        let lines = ProblemSections.lines(issue, kind)
        switch kind.style {
        case .stop:
            VStack(alignment: .leading, spacing: 3) {
                Text(kind.labelKey)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(Theme.brick)
                    .textCase(.uppercase)
                Text(verbatim: lines.first ?? "")
                    .font(.system(size: 13.5))
                    .foregroundStyle(Color(hex: 0x5A2417))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0xF7E8E2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .leading) { Rectangle().fill(Theme.brick).frame(width: 3) }

        case .bullets, .steps:
            VStack(alignment: .leading, spacing: 7) {
                Text(kind.labelKey)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(kind.accent)
                    .textCase(.uppercase)
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    HStack(alignment: .top, spacing: 10) {
                        Text(verbatim: kind.style == .steps ? "\(index + 1)" : "•")
                            .font(.system(size: kind.style == .steps ? 12 : 15,
                                          weight: kind.style == .steps ? .bold : .regular))
                            .foregroundStyle(kind.accent)
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
    }

    private func practiceChips(_ issue: BehaviourIssue) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("problems.practices")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Theme.muted)
                .textCase(.uppercase)
            ChipFlow {
                ForEach(issue.practices, id: \.self) { exerciseId in
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
                    }
                }
            }
        }
    }
}

/// Wrapping chip row using the native Layout protocol (iOS 16).
struct ChipFlow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        return layout(width: width, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        for (index, position) in layout(width: bounds.width, subviews: subviews).positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func layout(width: CGFloat, subviews: Subviews)
        -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x - spacing)
        }
        return (CGSize(width: min(width, maxWidth), height: y + rowHeight), positions)
    }
}
