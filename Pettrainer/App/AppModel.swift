import Foundation
import Combine

/// Composition root for the runtime: content, storage, repositories and the
/// published progress the catalogue reads. Built once by `PettrainerApp`.
///
/// Storage failures never delete or reset anything: the model surfaces a
/// recoverable state and the UI offers retry (`common.retry`), matching the
/// local-training-storage spec.
@MainActor
final class AppModel: ObservableObject {
    enum LoadState: Equatable {
        case ready
        /// The database could not be opened or migrated. The payload is for
        /// developers; the UI shows only the localized recovery line.
        case storageUnavailable(String)
    }

    let content: TrainingContent

    @Published private(set) var state: LoadState = .storageUnavailable("initialising")
    @Published var language: AppLanguage {
        didSet {
            guard language != oldValue else { return }
            LanguageStore.save(language)
            ContentLocale.override = language.contentOverride
        }
    }
    @Published private(set) var positions: [String: Position] = [:]
    @Published private(set) var mastery: [String: [String: Int]] = [:]
    @Published private(set) var noseworkLevels: [String: Int] = [:]

    private var database: SQLiteDatabase?
    private var progress: ProgressRepository?
    private var sessions: SessionRepository?
    private var nosework: NoseworkRepository?
    private(set) var dogId: String = ProgressRepository.defaultDogId

    init(bundle: Bundle = .main) {
        let storedLanguage = LanguageStore.load()
        language = storedLanguage
        ContentLocale.override = storedLanguage.contentOverride
        // A selection made in a previous session must not outlive a later
        // "system" choice: didSet never fires for the init assignment, so
        // reconcile the persisted AppleLanguages override here instead.
        LanguageStore.reconcileOnLaunch()
        do {
            content = try ContentLoader.load(bundle: bundle)
        } catch {
            // Content is build input; a broken bundle is a developer error and
            // the loader message already names the file and field.
            fatalError("pettrainer content failed to load: \(error)")
        }
        openStorage()
    }

    /// The locale the whole SwiftUI tree should render in (nil = the
    /// device's own). Drives `.environment(\.locale)` and forces a rebuild.
    var environmentLocale: Locale? {
        language.contentOverride.map(Locale.init(identifier:))
    }

    var ladder: [String] { content.environments.map(\.id) }
    var startingEnvironmentId: String { content.startingEnvironmentId }

    /// The first never-touched exercise; the first one otherwise. The owner
    /// may open anything regardless — this only marks a suggestion.
    var recommendedExerciseId: String {
        content.catalogue.first { positions[$0.id] == nil }?.id ?? content.catalogue[0].id
    }

    func retryStorage() {
        guard case .storageUnavailable = state else { return }
        openStorage()
    }

    private func openStorage() {
        do {
            let db = try AppDatabase.open(url: try AppDatabase.defaultURL(), content: content)
            let progress = ProgressRepository(db: db)
            database = db
            self.progress = progress
            sessions = SessionRepository(db: db, progress: progress)
            nosework = NoseworkRepository(db: db)
            dogId = try progress.ensureDefaultDog()
            try reload()
            state = .ready
        } catch {
            database = nil
            progress = nil
            sessions = nil
            nosework = nil
            state = .storageUnavailable(String(describing: error))
        }
    }

    func reload() throws {
        guard let progress, let nosework else { return }
        positions = try progress.allPositions(dogId: dogId)
        mastery = try progress.mastery(dogId: dogId)
        var levels: [String: Int] = [:]
        for activity in content.nosework {
            let highest = try nosework.highestLevel(dogId: dogId, activityId: activity.id)
            if highest > 0 { levels[activity.id] = highest }
        }
        noseworkLevels = levels
    }

    // MARK: Session flows

    func makeSessionModel(exerciseId: String) -> SetModel? {
        guard let progress, let sessions,
              let entry = content.exercise(id: exerciseId) else { return nil }
        let position = (try? progress.position(dogId: dogId, exerciseId: exerciseId,
                                               startingEnvironmentId: startingEnvironmentId))
            ?? Position(stepOrdinal: 1, environmentId: startingEnvironmentId)
        let stepId = ContentSeeder.stepId(exerciseId: exerciseId, ordinal: position.stepOrdinal)
        guard let stored = try? sessions.resumableSet(
            dogId: dogId, exerciseId: exerciseId,
            environmentId: position.environmentId, stepId: stepId) else { return nil }
        return SetModel(entry: entry, position: position, stored: stored,
                        dogId: dogId, model: self, progress: progress, sessions: sessions)
    }

    func recordNoseworkCompletion(activityId: String, levelOrdinal: Int) {
        guard let nosework else { return }
        try? nosework.recordLevelCompletion(dogId: dogId, activityId: activityId,
                                            levelOrdinal: levelOrdinal)
        noseworkLevels[activityId] = max(noseworkLevels[activityId] ?? 0, levelOrdinal)
    }

    func recordChoiceApplied() {
        try? reload()
    }
}
