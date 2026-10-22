import SwiftUI

/// The bottom dock: five pips, the hit/miss controls, and — once the set is
/// complete — the verdict card with the owner's three live choices. Controls
/// keep their space always: a button that appears after the first tap would
/// shift the targets under a thumb that is not looking. Port of the `dock`
/// block in `SetScreen.tsx`.
struct SetDockView: View {
    @ObservedObject var session: SetModel
    @State private var writeFailed = false

    var body: some View {
        VStack(spacing: 10) {
            pips
            if let verdict = session.verdict {
                verdictCard(verdict)
            } else {
                recordButtons
                abandonButton
            }
            undoButton
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .frame(maxWidth: Theme.contentWidth)
        .frame(maxWidth: .infinity)
    }

    private var pips: some View {
        HStack(spacing: 8) {
            ForEach(0..<TrainingRules.setSize, id: \.self) { index in
                let outcome: RepOutcome? = index < session.reps.count ? session.reps[index] : nil
                RoundedRectangle(cornerRadius: 4)
                    .fill(pipColor(outcome))
                    .frame(width: 26, height: 10)
            }
            Text(verbatim: fmt("session.repCounter", session.reps.count, TrainingRules.setSize))
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)
        }
        .accessibilityElement(children: .combine)
    }

    private func pipColor(_ outcome: RepOutcome?) -> Color {
        switch outcome {
        case .hit: return Theme.green
        case .miss, .cancelled: return Theme.brick.opacity(0.75)
        case .none: return Color(hex: 0xCCD4CA)
        }
    }

    private var recordButtons: some View {
        HStack(spacing: 10) {
            bigButton(key: "session.hit", fill: Theme.green.opacity(0.14),
                      stroke: Theme.green, text: Theme.green,
                      disabled: session.isComplete) {
                commit { session.record(.hit) }
            }
            bigButton(key: "session.miss", fill: Color(hex: 0xF3E4DF),
                      stroke: Theme.brick.opacity(0.6), text: Theme.brick,
                      disabled: session.isComplete) {
                commit { session.record(.miss) }
            }
        }
    }

    private func verdictCard(_ verdict: Verdict) -> some View {
        let color = Theme.verdictColor[verdict] ?? Theme.green
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(verbatim: "✓")
                    .foregroundStyle(color)
                Text(verbatim: fmt("verdict.\(verdict.rawValue).label"))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(verbatim: fmt("verdict.\(verdict.rawValue).explanation"))
                .font(.system(size: 13))
                .foregroundStyle(Theme.ink)
            Text("session.yourCall")
                .font(.system(size: 11))
                .foregroundStyle(Theme.muted)
                .padding(.top, 2)
            HStack(spacing: 8) {
                choiceButton(delta: -1, color: color)
                choiceButton(delta: 0, color: color)
                choiceButton(delta: 1, color: color)
            }
            if writeFailed {
                Text("errors.generic")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.brick)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(color, lineWidth: 1))
    }

    @ViewBuilder
    private func choiceButton(delta: Int, color: Color) -> some View {
        if choiceInfo(delta).available {
            let info = choiceInfo(delta)
            Button {
                commit { session.choose(delta) }
            } label: {
                Text(info.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(info.marked ? .white : Theme.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .padding(.horizontal, 8)
                    .background(info.marked ? color : Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(info.marked ? color : Theme.line, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                Text(info.label)
                    + Text(verbatim: info.marked
                        ? " — \(NSLocalizedString("session.suggested", bundle: .main, comment: ""))"
                        : ""))
        }
    }

    private struct ChoiceInfo {
        let available: Bool
        let marked: Bool
        let label: LocalizedStringKey
    }

    private func choiceInfo(_ delta: Int) -> ChoiceInfo {
        let crossesEnvironment = (delta == 1 && session.position.stepOrdinal >= session.entry.steps.count)
            || (delta == -1 && session.position.stepOrdinal <= 1)
        let available: Bool
        switch delta {
        case -1: available = session.canGoEasier
        case 1: available = session.canGoHarder
        default: available = true
        }
        let label: LocalizedStringKey = delta == 0 ? "session.sameAgain"
            : delta == 1 ? (crossesEnvironment ? "session.harderPlace" : "session.nextStep")
            : (crossesEnvironment ? "session.easierPlace" : "session.easierStep")
        return ChoiceInfo(available: available, marked: delta == session.suggestedDelta, label: label)
    }

    /// F-1 recovery offer: an in-progress partial set can be abandoned; the
    /// raw reps stay in history and the set never gains a verdict.
    @ViewBuilder private var abandonButton: some View {
        if session.stored.lifecycle == .active && !session.reps.isEmpty {
            Button {
                session.abandon()
            } label: {
                Text("session.abandon")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.plain)
        }
    }

    private var undoButton: some View {
        Button {
            commit { session.undo() }
        } label: {
            HStack(spacing: 6) {
                Text(verbatim: "↺")
                Text("common.back")
            }
            .font(.system(size: 13))
            .foregroundStyle(Theme.muted)
            .frame(maxWidth: .infinity, minHeight: 40)
        }
        .buttonStyle(.plain)
        .disabled(!session.canUndo)
        .opacity(session.canUndo ? 1 : 0.001) // keeps its space; invisible until needed
        .accessibilityHidden(!session.canUndo)
    }

    private func bigButton(key: LocalizedStringKey, fill: Color, stroke: Color,
                           text: Color, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(key)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(text)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(fill)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(stroke.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }

    /// Every dock action surfaces a failed commit instead of pretending the
    /// state advanced (the repository already kept the last committed truth).
    private func commit(_ action: () -> Bool) {
        writeFailed = !action()
    }
}
