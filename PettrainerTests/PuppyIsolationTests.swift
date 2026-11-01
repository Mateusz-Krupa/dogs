import XCTest
@testable import Pettrainer

/// Reviewer P-1 and FR-2, proven against raw storage (the same bar
/// CareIsolationTests set): educational browsing is write-free; a guidance
/// exercise link to a never-opened exercise produces exactly the lazy
/// initialization the catalogue route produces; and links to an exercise with
/// a partial set or a completed set awaiting the owner's choice change no byte
/// of existing history. The real view hierarchy is driven in PuppyFlowUITests;
/// this class owns the database evidence.
@MainActor
final class PuppyIsolationTests: XCTestCase {
    private var directory: URL!
    private var url: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("pettrainer-puppy-iso-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("puppy.sqlite")
        try seedScoredHistory()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    /// The FR-2 matrix: dog one holds a partial set (two reps), a completed
    /// five-rep set whose owner choice was applied, and a completed five-rep
    /// set still awaiting its choice; dog two holds a mastery earned on a
    /// non-starting environment plus its own lazy position.
    private func seedScoredHistory() throws {
        let content = try ContentLoader.load(bundle: .main)
        let db = try AppDatabase.open(url: url, content: content)
        let progress = ProgressRepository(db: db)
        let dogId = try progress.ensureDefaultDog()
        let sessions = SessionRepository(db: db, progress: progress)
        func step(_ exerciseId: String) -> String {
            ContentSeeder.stepId(exerciseId: exerciseId, ordinal: 1)
        }
        func set(_ dog: String, _ exerciseId: String, env: String = "quiet-room") throws -> StoredSet {
            try sessions.resumableSet(dogId: dog, exerciseId: exerciseId,
                                      environmentId: env, stepId: step(exerciseId))
        }

        // Dog 1 — partial set with real reps.
        var sit = try set(dogId, "sit")
        sit = try sessions.recordRep(.hit, sessionId: sit.sessionId)
        _ = try sessions.recordRep(.miss, sessionId: sit.sessionId)

        // Dog 1 — completed set with the choice applied (moves position,
        // mastery, context and session_choice rows).
        var look = try set(dogId, "look")
        for _ in 0..<TrainingRules.setSize {
            look = try sessions.recordRep(.hit, sessionId: look.sessionId)
        }
        let applied = try progress.applyOwnerChoice(
            sessionId: look.sessionId, dogId: dogId, exerciseId: "look", delta: 1,
            stepCount: content.exercise(id: "look")?.steps.count ?? 1,
            ladder: content.environmentLadder, startingEnvironmentId: "quiet-room")
        XCTAssertTrue(applied, "fixture choice was unexpectedly rejected")

        // Dog 1 — completed five-rep set with NO owner choice yet: the F-1
        // "awaiting choice" state a guidance link must not disturb.
        var leave = try set(dogId, "leave")
        for _ in 0..<TrainingRules.setSize {
            leave = try sessions.recordRep(.hit, sessionId: leave.sessionId)
        }

        // Dog 2 — isolated progress on a different dog and environment.
        try db.run("INSERT INTO dog VALUES ('dog-b','B',NULL,'2026-01-01T00:00:00Z');")
        try progress.earnMasteryPush(dogId: "dog-b", exerciseId: "sit",
                                     environmentId: "own-garden-quiet", stepOrdinal: 1)
        _ = try progress.position(dogId: "dog-b", exerciseId: "come",
                                  startingEnvironmentId: "quiet-room")

        try NoseworkRepository(db: db).recordLevelCompletion(dogId: dogId, activityId: "cups",
                                                             levelOrdinal: 2)
        try CareRepository(db: db, knownRoutineIds: Set(content.care.map(\.id)))
            .recordStageTried(dogId: dogId, routineId: "care-coat", stageOrdinal: 1)
    }

    // MARK: raw dump

    private enum DumpError: Error { case closed }

    /// Every scored row, rendered exactly, ordered by rowid — a delta anywhere
    /// in scored storage shows up as a diff, not as a lucky count match.
    private func rawDump() throws -> [String: [String]] {
        guard let db = try? AppDatabase.open(url: url,
                                             content: ContentLoader.load(bundle: .main))
        else { throw DumpError.closed }
        var out: [String: [String]] = [:]
        for table in ["dog", "session", "rep", "session_choice", "position",
                      "context_progress", "mastery", "nosework_progress",
                      "exercise", "step"] {
            let rows = try db.query("SELECT * FROM \(table) ORDER BY rowid")
            out[table] = rows.map { row in
                row.keys.sorted().map { key in
                    let value: String
                    switch row[key] {
                    case .text(let text)?: value = text
                    case .integer(let number)?: value = String(number)
                    case .real(let double)?: value = String(double)
                    case .null?: value = "<null>"
                    case .none: value = "<absent>"
                    }
                    return "\(key)=\(value)"
                }.joined(separator: "|")
            }
        }
        out["schema"] = try db.query("PRAGMA user_version").flatMap { row in
            row.keys.map { "\($0)=\(String(describing: row[$0]))" }
        }
        return out
    }

    /// Reading every hub destination: guide content in both languages, help
    /// cards, citations — the reads the views perform, with no repo calls.
    /// View-driving itself is PuppyFlowUITests' job; this guards that the
    /// data path browsing uses stays free of side effects.
    private func browseEverything(_ model: AppModel) {
        for guide in model.content.puppyGuides {
            XCTAssertNotNil(model.content.puppyGuide(id: guide.id))
            _ = [guide.names.pl.name, guide.names.en.name,
                 guide.urgent.pl, guide.urgent.en,
                 guide.avoid.pl.count, guide.avoid.en.count,
                 guide.actions.pl.count, guide.actions.en.count,
                 guide.observe.pl.count, guide.observe.en.count,
                 guide.professional.pl, guide.professional.en,
                 guide.evidence.verifiedOn, guide.evidence.sources.count].count
            // The toilet guide's long-form prose is part of the read too (C-1
            // for puppy-toilet): browsing must touch sections in both locales.
            for section in guide.sections {
                _ = [section.id, section.title.pl, section.title.en,
                     section.paragraphs.pl.joined(), section.paragraphs.en.joined()]
            }
        }
        for issueId in PuppyStartView.helpIssueIds {
            let issue = model.content.behaviourIssue(id: issueId)
            XCTAssertNotNil(issue)
            _ = issue?.observe?.pl.count
            _ = issue?.observe?.en.count
            _ = issue?.evidence?.sources.map(\.url)
        }
    }

    func testEducationalBrowsingWritesNothing() throws {
        let model = AppModel(bundle: .main, databaseURL: url)
        XCTAssertEqual(model.state, .ready)
        let before = try rawDump()
        XCTAssertFalse(before["session"]?.isEmpty ?? true, "fixture must exist")
        XCTAssertEqual(before["dog"]?.count, 2, "FR-2: fixture must hold two dogs")
        XCTAssertGreaterThanOrEqual(before["context_progress"]?.count ?? 0, 1,
                                    "FR-2: fixture must hold a non-starting environment")

        browseEverything(model)
        try model.reload()

        XCTAssertEqual(try rawDump(), before, "educational browsing moved scored storage")
    }

    func testPuppyIdsNeverReachScoredSeedingOrRecommendation() throws {
        let content = try ContentLoader.load(bundle: .main)
        let guideIds = Set(content.puppyGuides.map(\.id))
        let db = try AppDatabase.open(url: url, content: content)
        let seeded = try db.query("SELECT id FROM exercise")
        let seededIds = Set(seeded.compactMap { row -> String? in
            if case .text(let value)? = row["id"] { return value }
            return nil
        })
        XCTAssertTrue(seededIds.isDisjoint(with: guideIds))
        let model = AppModel(bundle: .main, databaseURL: url)
        XCTAssertFalse(guideIds.contains(model.recommendedExerciseId))
        let positions = try db.query("SELECT exercise_id FROM position")
        let positionIds = Set(positions.compactMap { row -> String? in
            if case .text(let value)? = row["exercise_id"] { return value }
            return nil
        })
        XCTAssertTrue(positionIds.isDisjoint(with: guideIds))
    }

    /// A never-opened exercise reached from guidance gains exactly the ordinary
    /// lazy initialization — for the CURRENT dog only — and nothing else.
    func testExerciseLinkFromGuidanceInitializesLikeTheCatalogue() throws {
        let model = AppModel(bundle: .main, databaseURL: url)
        let before = try rawDump()
        XCTAssertNil(model.positions["wait"], "fixture must leave `wait` untouched")

        XCTAssertNotNil(model.makeSessionModel(exerciseId: "wait"))
        try model.reload()
        XCTAssertEqual(model.positions["wait"],
                       Position(stepOrdinal: 1, environmentId: "quiet-room"))
        let afterFirst = try rawDump()
        XCTAssertEqual(afterFirst["session"]?.count, (before["session"]?.count ?? 0) + 1,
                       "opening a fresh exercise must create exactly one empty set")
        XCTAssertEqual(afterFirst["rep"], before["rep"], "opening an exercise recorded a rep")
        for table in ["mastery", "context_progress", "nosework_progress", "session_choice",
                      "dog", "schema"] {
            XCTAssertEqual(afterFirst[table], before[table], "opening an exercise moved \(table)")
        }
        XCTAssertEqual((afterFirst["position"]?.count ?? 0), (before["position"]?.count ?? 0) + 1,
                       "exactly one position row may appear, for the current dog")

        // A second visit reuses the row: no phantom duplicate.
        _ = model.makeSessionModel(exerciseId: "wait")
        try model.reload()
        XCTAssertEqual(try rawDump(), afterFirst, "a second visit duplicated the pending set")
    }

    /// An exercise with a resumable partial set is byte-identical after the
    /// guidance link: history, reps and positions all stay where they are.
    func testExerciseLinkToPartialSetChangesNothing() throws {
        let model = AppModel(bundle: .main, databaseURL: url)
        _ = model.makeSessionModel(exerciseId: "sit") // first visit: lazy rows
        try model.reload()
        let before = try rawDump()

        XCTAssertNotNil(model.makeSessionModel(exerciseId: "sit"))
        try model.reload()
        XCTAssertEqual(try rawDump(), before, "reopening a partial set rewrote history")
    }

    /// FR-2's missing state: a completed five-rep set awaiting the owner's
    /// choice survives opening and returning from guidance — no choice is
    /// applied, no successor set materializes, the raw rows are identical.
    func testExerciseLinkToSetAwaitingChoiceChangesNothing() throws {
        let model = AppModel(bundle: .main, databaseURL: url)
        _ = model.makeSessionModel(exerciseId: "leave") // the awaiting-choice set
        try model.reload()
        let before = try rawDump()

        XCTAssertNotNil(model.makeSessionModel(exerciseId: "leave"))
        try model.reload()
        let after = try rawDump()
        XCTAssertEqual(after, before, "visiting an awaiting-choice set applied or replaced it")
        XCTAssertEqual(after["session_choice"], before["session_choice"],
                       "a guidance visit must never apply the owner's choice")
    }
}
