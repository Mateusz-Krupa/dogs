import Foundation
import Combine

/// Drives one set screen: the five reps, undo, and the owner's explicit
/// next-step choice. The verdict rules live in the domain; this only moves
/// data through the repositories and republishes the catalogue state.
@MainActor
final class SetModel: ObservableObject {
    let entry: CatalogueEntry
    let dogId: String

    @Published private(set) var position: Position
    @Published private(set) var stored: StoredSet
    /// Why the step number jumped when the screen opened (F-1 explanation
    /// banner): set right after a choice moved across the environment axis.
    @Published var placeChange: PlaceChange?

    enum PlaceChange: String { case harder, easier }

    let model: AppModel
    private let progress: ProgressRepository
    private let sessions: SessionRepository

    init(entry: CatalogueEntry, position: Position, stored: StoredSet, dogId: String,
         model: AppModel, progress: ProgressRepository, sessions: SessionRepository) {
        self.entry = entry
        self.position = position
        self.stored = stored
        self.dogId = dogId
        self.model = model
        self.progress = progress
        self.sessions = sessions
    }

    // MARK: Derived (never stored) view of the set

    var reps: [RepOutcome] { stored.reps }
    var verdict: Verdict? { stored.verdict }
    var isComplete: Bool { stored.reps.count == TrainingRules.setSize }
    /// Fifth-rep undo stays available while the choice is pending (F-1).
    var canUndo: Bool {
        if stored.lifecycle == .active { return !stored.reps.isEmpty }
        return stored.awaitingChoice && !stored.reps.isEmpty
    }
    var awaitingChoice: Bool { stored.awaitingChoice }

    var currentStep: StepSeed {
        let index = min(max(position.stepOrdinal, 1), entry.steps.count) - 1
        return entry.steps[index]
    }

    var environment: EnvironmentSeed {
        model.content.environments.first { $0.id == position.environmentId }
            ?? model.content.environments[0]
    }

    var stepId: String {
        ContentSeeder.stepId(exerciseId: entry.id, ordinal: position.stepOrdinal)
    }

    var stage: DiagramStage {
        LureStages.stage(exerciseId: entry.id, stepOrdinal: position.stepOrdinal)
    }

    var motion: StepMotion {
        currentStep.motion ?? MotionByExercise.motion(forExerciseId: entry.id) ?? .up
    }

    var pose: Pose { currentStep.pose ?? entry.pose }

    // Availability of the easier/harder ends (JS: step bounds or an adjacent
    // environment rung).
    var canGoEasier: Bool {
        position.stepOrdinal > 1
            || (try? Progression.previousEnvironment(position.environmentId, ladder: model.ladder)) != nil
    }

    var canGoHarder: Bool {
        position.stepOrdinal < entry.steps.count
            || (try? Progression.nextEnvironment(position.environmentId, ladder: model.ladder)) != nil
    }

    /// The recommendation marking: push→harder, drop→easier, stick→same. It
    /// only decorates a button; every choice stays live.
    var suggestedDelta: Int {
        switch verdict {
        case .push: return 1
        case .drop: return -1
        case .stick, .none: return 0
        }
    }

    // MARK: Actions (each commits before returning)

    @discardableResult
    func record(_ outcome: RepOutcome) -> Bool {
        guard let updated = try? sessions.recordRep(outcome, sessionId: stored.sessionId) else { return false }
        stored = updated
        return true
    }

    @discardableResult
    func undo() -> Bool {
        guard canUndo, let updated = try? sessions.undoLastRep(sessionId: stored.sessionId) else { return false }
        stored = updated
        return true
    }

    func abandon() {
        guard let updated = try? sessions.abandon(sessionId: stored.sessionId) else { return }
        stored = updated
    }

    /// The owner's call. Returns false when the write failed or a duplicate
    /// choice was already applied — the UI keeps the pending choice visible.
    @discardableResult
    func choose(_ delta: Int) -> Bool {
        let before = position
        let appliedChoice = progress.applyOwnerChoiceResult(
            sessionId: stored.sessionId, dogId: dogId, exerciseId: entry.id,
            delta: delta, stepCount: entry.steps.count,
            ladder: model.ladder, startingEnvironmentId: model.startingEnvironmentId)
        guard case .success(true) = appliedChoice else { return false }
        if let after = try? progress.position(dogId: dogId, exerciseId: entry.id,
                                              startingEnvironmentId: model.startingEnvironmentId) {
            position = after
            if after.environmentId != before.environmentId,
               let oldIndex = model.ladder.firstIndex(of: before.environmentId),
               let newIndex = model.ladder.firstIndex(of: after.environmentId) {
                placeChange = newIndex > oldIndex ? .harder : .easier
            }
        }
        // Fresh set for the new position (F-1: materialised on open/first rep).
        if let fresh = try? sessions.resumableSet(dogId: dogId, exerciseId: entry.id,
                                                  environmentId: position.environmentId, stepId: stepId) {
            stored = fresh
        }
        model.recordChoiceApplied()
        return true
    }

    private func applied(_ result: Result<Bool, Error>) -> Bool {
        switch result {
        case .success(let ok): return ok
        case .failure: return false
        }
    }
}

private extension ProgressRepository {
    /// Wraps the throwing call so SetModel can keep one Result-based seam.
    func applyOwnerChoiceResult(sessionId: String, dogId: String, exerciseId: String,
                                delta: Int, stepCount: Int, ladder: [String],
                                startingEnvironmentId: String) -> Result<Bool, Error> {
        .init { try applyOwnerChoice(sessionId: sessionId, dogId: dogId, exerciseId: exerciseId,
                                     delta: delta, stepCount: stepCount, ladder: ladder,
                                     startingEnvironmentId: startingEnvironmentId) }
    }
}
