import Foundation

/// The content loader: JSON in, typed content out (port of `src/content/load.ts`).
///
/// Every bundled file is parsed once, here, at load. Validation runs at
/// startup rather than lazily because a malformed exercise should stop the
/// app in development with a message naming the file and the field, not
/// render a blank screen in front of someone with a puppy waiting.
struct TrainingContent {
    let catalogue: [CatalogueEntry]
    let nosework: [NoseworkActivity]
    let behaviour: [BehaviourIssue]
    /// Hygiene routines. Deliberately NOT part of `catalogue`.
    let care: [CareRoutine]
    /// Puppy-start guides. Same exclusion as care: education, not scored work.
    let puppyGuides: [PuppyGuide]
    let mistakesByExerciseId: [String: [Mistake]]
    let environmentSet: EnvironmentSet

    private let exercisesById: [String: CatalogueEntry]
    private let noseworkById: [String: NoseworkActivity]
    private let behaviourById: [String: BehaviourIssue]
    private let careById: [String: CareRoutine]
    private let puppyGuidesById: [String: PuppyGuide]

    init(environmentSet: EnvironmentSet, catalogue: [CatalogueEntry], nosework: [NoseworkActivity],
         mistakesByExerciseId: [String: [Mistake]], behaviour: [BehaviourIssue],
         care: [CareRoutine], puppyGuides: [PuppyGuide] = []) {
        self.environmentSet = environmentSet
        self.catalogue = catalogue
        self.nosework = nosework
        self.mistakesByExerciseId = mistakesByExerciseId
        self.behaviour = behaviour
        self.care = care
        self.puppyGuides = puppyGuides
        self.exercisesById = Self.index(catalogue, by: \.id)
        self.noseworkById = Self.index(nosework, by: \.id)
        self.behaviourById = Self.index(behaviour, by: \.id)
        self.careById = Self.index(care, by: \.id)
        self.puppyGuidesById = Self.index(puppyGuides, by: \.id)

        // Care ids are namespaced, and that namespace is the only thing
        // keeping a care file from shadowing an exercise or a scent game.
        // Assert it instead of trusting the prefix convention.
        var collisions = Self.idCollisions(
            exercises: catalogue.map(\.id), nosework: nosework.map(\.id),
            behaviour: behaviour.map(\.id), care: care.map(\.id), puppy: puppyGuides.map(\.id))
        // Same rule for care as for behaviour cards: an advisory chip must
        // name a real exercise, or it is a broken promise rather than a link.
        collisions += Self.careProblems(care: care, knownExerciseIds: Set(exercisesById.keys))
        collisions += Self.puppyProblems(
            puppy: puppyGuides, knownExerciseIds: Set(exercisesById.keys))

        // Fail at load, naming both sides of the broken reference: every
        // `practices` id on a behaviour card must name a real exercise — a
        // broken chip is a broken promise, not a soft link.
        let problems = Self.practicesProblems(
            behaviour: behaviour, knownExerciseIds: Set(catalogue.map(\.id))
        ) + Self.guidanceRequirementsProblems(behaviour: behaviour) + collisions
        if !problems.isEmpty {
            fatalError("content: \(problems.joined(separator: "; "))")
        }
    }

    /// The ladder, easiest first.
    var environments: [EnvironmentSeed] { environmentSet.environments }
    /// Rungs a puppy under six months should not be asked to work at yet.
    var beyondPuppyScope: [String] { environmentSet.beyondPuppyScope }
    /// The rung every exercise starts on.
    var startingEnvironmentId: String { environmentSet.startingEnvironmentId }
    /// Categories in the order a puppy curriculum introduces them.
    var categoryOrder: [ExerciseCategory] { environmentSet.categoryOrder }

    func exercise(id: String) -> CatalogueEntry? { exercisesById[id] }
    func noseworkActivity(id: String) -> NoseworkActivity? { noseworkById[id] }
    func behaviourIssue(id: String) -> BehaviourIssue? { behaviourById[id] }
    func careRoutine(id: String) -> CareRoutine? { careById[id] }
    func puppyGuide(id: String) -> PuppyGuide? { puppyGuidesById[id] }
    /// Mistakes for one exercise, or an empty list. No entry means no section.
    func mistakes(for exerciseId: String) -> [Mistake] { mistakesByExerciseId[exerciseId] ?? [] }

    /// Environment ids as an ordered ladder for the domain's `Progression`.
    var environmentLadder: [String] { environments.map(\.id) }

    private static func index<Value>(
        _ values: [Value], by keyPath: KeyPath<Value, String>
    ) -> [String: Value] {
        Dictionary(values.map { ($0[keyPath: keyPath], $0) }) { first, _ in first }
    }

    /// Cross-family id uniqueness. Two families sharing an id would let a care
    /// row be read as exercise progress, which is exactly the confusion this
    /// feature must never allow.
    static func idCollisions(exercises: [String], nosework: [String], behaviour: [String],
                             care: [String], puppy: [String] = []) -> [String] {
        let families: [(String, [String])] = [
            ("exercise", exercises), ("nosework", nosework), ("behaviour", behaviour),
            ("care", care), ("puppy", puppy),
        ]
        var seen: [String: String] = [:]
        var problems: [String] = []
        for (family, ids) in families {
            for id in ids {
                if let owner = seen[id], owner != family {
                    problems.append("id '\(id)' claimed by \(owner) and \(family)")
                } else if seen[id] != nil, seen[id] == family {
                    problems.append("duplicate \(family) id '\(id)'")
                }
                seen[id] = family
            }
        }
        return problems
    }

    static func careProblems(care: [CareRoutine], knownExerciseIds: Set<String>) -> [String] {
        care.flatMap { routine in
            routine.practices.compactMap { practice in
                knownExerciseIds.contains(practice) ? nil
                    : "care/\(routine.id) points at unknown exercise '\(practice)'"
            }
        }
    }

        /// A puppy guide's optional practice chips must name real exercises —
    /// a broken chip is a broken promise, not a soft link. (The hub's
    /// behaviour cross-links live in the view, pinned by UI tests.)
    static func puppyProblems(puppy: [PuppyGuide],
                              knownExerciseIds: Set<String>) -> [String] {
        puppy.flatMap { guide in
            guide.practices.compactMap { practice in
                knownExerciseIds.contains(practice) ? nil
                    : "puppy/\(guide.id) points at unknown exercise '\(practice)'"
            }
        }
    }

    /// Two behaviour cards are canonical for the puppy hub and a reviewed pair
    /// gained evidence; the spec requires those fields to actually be present
    /// so the hub never links to a card missing the section it promised.
    static func guidanceRequirementsProblems(behaviour: [BehaviourIssue]) -> [String] {
        let requireObserveAndEvidence: Set<String> = ["overarousal", "fear-withdrawal"]
        let requireEvidence: Set<String> = ["nipping", "mounting"]
        return behaviour.flatMap { issue in
            var problems: [String] = []
            if requireObserveAndEvidence.contains(issue.id), issue.observe == nil {
                problems.append("behaviour/\(issue.id) must carry observation guidance")
            }
            if (requireObserveAndEvidence.union(requireEvidence).contains(issue.id)),
               issue.evidence == nil {
                problems.append("behaviour/\(issue.id) must carry evidence")
            }
            return problems
        }
    }

    static func practicesProblems(
        behaviour: [BehaviourIssue], knownExerciseIds: Set<String>
    ) -> [String] {
        behaviour.flatMap { issue in
            issue.practices.compactMap { practice in
                knownExerciseIds.contains(practice) ? nil
                    : "behaviour/\(issue.id) points at unknown exercise '\(practice)'"
            }
        }
    }
}

enum ContentLoader {
    /// Parse every bundled file and cross-check the references. Throwing (not
    /// fatal) variant, used by tests and by the composition root, which turns
    /// a failure into a developer-facing crash with the file and field named.
    static func load(bundle: Bundle = .main) throws -> TrainingContent {
        let catalogue = try CatalogueManifest.exercises.map {
            try ExerciseValidator.parseCatalogueEntry(json($0, bundle: bundle), source: $0.source)
        }
        let nosework = try CatalogueManifest.nosework.map {
            try NoseworkValidator.parseActivity(json($0, bundle: bundle), source: $0.source)
        }
        var mistakesByExerciseId: [String: [Mistake]] = [:]
        for (exerciseId, resource) in CatalogueManifest.mistakes {
            mistakesByExerciseId[exerciseId] = try MistakeValidator.parseMistakes(
                json(resource, bundle: bundle), source: resource.source)
        }
        let behaviour = try CatalogueManifest.behaviour.map {
            try BehaviourValidator.parseIssue(json($0, bundle: bundle), source: $0.source)
        }
        let care = try CatalogueManifest.care.map {
            try CareValidator.parseRoutine(json($0, bundle: bundle), source: $0.source)
        }
        let puppyGuides = try CatalogueManifest.puppy.map {
            try PuppyGuideValidator.parseGuide(json($0, bundle: bundle), source: $0.source)
        }
        let environments = try EnvironmentValidator.parseEnvironmentSet(
            json(CatalogueManifest.environments, bundle: bundle),
            source: CatalogueManifest.environments.source
        )
        return TrainingContent(
            environmentSet: environments,
            catalogue: catalogue,
            nosework: nosework,
            mistakesByExerciseId: mistakesByExerciseId,
            behaviour: behaviour,
            care: care,
            puppyGuides: puppyGuides
        )
    }

    /// Read one bundled content file. A missing manifest entry is a build
    /// error, not runtime data, so it traps loudly with the name.
    private static func json(_ resource: ContentResource, bundle: Bundle) throws -> JSONValue {
        guard let url = bundle.url(forResource: resource.resourceName, withExtension: "json", subdirectory: "Content")
            ?? bundle.url(forResource: resource.resourceName, withExtension: "json") else {
            fatalError("content: missing bundled file \(resource.source) (\(resource.resourceName).json)")
        }
        return try JSONValue(data: Data(contentsOf: url))
    }
}
