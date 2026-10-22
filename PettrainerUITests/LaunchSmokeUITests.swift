import XCTest

/// Smoke flows for the feature areas. Each test launches against its own
/// fresh database (`PETTRAINER_DB_NAME`) so recorded reps never leak between
/// runs — a completed set would otherwise resume on the next launch and hide
/// the hit button (by design, F-1 recovery).
/// Kept locale-tolerant: the simulator may boot in PL or EN.
final class LaunchSmokeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = makeApp()
        app.launch()
        // `.textCase(.uppercase)` renders the eyebrow uppercased.
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "training plan")
        ).firstMatch.waitForExistence(timeout: 15))
    }

    override func tearDown() {
        app?.terminate()
        super.tearDown()
    }

    private func makeApp(arguments: [String] = []) -> XCUIApplication {
        let application = XCUIApplication()
        application.launchEnvironment = ["PETTRAINER_DB_NAME": "uitest-\(UUID().uuidString).sqlite"]
        // Force "system" language per launch via the NSUserDefaults argument
        // domain: one test switching the app to Polish must not relaunch all
        // others in Polish (persisted app.language would otherwise do that).
        // Pin chrome language per launch via the NSUserDefaults argument
        // domain; the in-app menu switch is in-process only, so nothing
        // leaks between tests anymore.
        var args = ["-app.language", "system"]
        if !arguments.contains("-AppleLanguages") { args += ["-AppleLanguages", "(en)"] }
        application.launchArguments = args + arguments
        return application
    }

    func testCatalogueShowsAllContentFamilies() {
        // Sampled cards exist regardless of language (all twelve ship).
        for id in ["name", "sit", "look", "handling"] {
            XCTAssertTrue(app.buttons["exercise-link-\(id)"].waitForExistence(timeout: 3),
                          "missing exercise card \(id)")
        }
    }

    func testOpenExerciseShowsTheSetDock() {
        app.buttons["exercise-link-sit"].tap()
        let hit = app.buttons.matching(
            NSPredicate(format: "label == %@ OR label == %@", "Got it", "Zaliczone")
        ).firstMatch
        XCTAssertTrue(hit.waitForExistence(timeout: 4))
        hit.tap()
        let counter = app.staticTexts.matching(NSPredicate(
            format: "label BEGINSWITH %@ OR label BEGINSWITH %@", "Rep ", "Powtórzenie "
        )).firstMatch
        XCTAssertTrue(counter.waitForExistence(timeout: 3))
    }

    func testPolishLabelsAreLocalized() throws {
        let pl = makeApp(arguments: ["-AppleLanguages", "(pl)"])
        pl.launch()
        addTeardownBlock { pl.terminate() }

        XCTAssertTrue(pl.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "plan treningu")
        ).firstMatch.waitForExistence(timeout: 15))
        pl.buttons["exercise-link-sit"].tap()
        let hit = pl.buttons.matching(NSPredicate(format: "label == %@", "Zaliczone")).firstMatch
        XCTAssertTrue(hit.waitForExistence(timeout: 4), "hit button not localized to PL")
        hit.tap()
        XCTAssertTrue(pl.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "Powtórzenie")
        ).firstMatch.waitForExistence(timeout: 3))
    }

    func testNoseworkFlowRecordsCompletion() {
        app.buttons["exercise-link-name"].waitForExistence(timeout: 3)
        let cups = app.buttons["nosework-link-cups"]
        XCTAssertTrue(cups.waitForExistence(timeout: 3), "cups card missing")
        cups.tap()
        let done = app.buttons.matching(
            NSPredicate(format: "label == %@ OR label == %@", "Done", "Gotowe")
        ).firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 4), "done button missing on nosework screen")
        done.tap()
        // Returning keeps the game open with the completion acknowledged.
        XCTAssertTrue(done.waitForExistence(timeout: 2))
    }

    func testProblemFlowShowsSectionsAndOpensExercise() {
        app.buttons["exercise-link-name"].waitForExistence(timeout: 3)
        let alone = app.buttons["problem-link-alone"]
        XCTAssertTrue(alone.waitForExistence(timeout: 3), "alone card missing")
        // Visual proof of the problem-row thumbnails (task 6.6); attached
        // to the xcresult, not asserted: a11y-hidden Canvas is invisible to
        // queries by design.
        for _ in 0..<12 where !alone.isHittable {
            app.swipeUp()
        }
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(alone.isHittable, "problem row never scrolled into view")
        alone.tap()
        // Welfare stop-line leads the actionable sections in both languages.
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(
            format: "label CONTAINS[cd] %@", "stop")
        ).firstMatch.waitForExistence(timeout: 4), "stop section missing")
    }

    func testLanguageSwitchAppliesWithoutRestart() throws {
        // Device/launch language: English. Switch via the globe menu, and
        // the same running session must go Polish — no relaunch.
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "training plan")
        ).firstMatch.waitForExistence(timeout: 15))
        let globe = app.buttons.matching(NSPredicate(
            format: "label CONTAINS[cd] %@", "language")
        ).firstMatch
        XCTAssertTrue(globe.waitForExistence(timeout: 3), "language menu missing")
        globe.tap()
        let polish = app.buttons.matching(NSPredicate(
            format: "label CONTAINS[cd] %@", "polski")
        ).firstMatch
        XCTAssertTrue(polish.waitForExistence(timeout: 3), "Polski option missing")
        polish.tap()
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "plan treningu")
        ).firstMatch.waitForExistence(timeout: 5), "UI did not switch to Polish in-session")
        app.buttons["exercise-link-sit"].tap()
        XCTAssertTrue(app.buttons.matching(NSPredicate(
            format: "label == %@", "Zaliczone")
        ).firstMatch.waitForExistence(timeout: 4), "dock did not follow the language switch")
    }

    func testAppLaunches() {
        // Covered by setUp; kept as an explicit named check.
        XCTAssertTrue(app.navigationBars.firstMatch.exists
                        || app.staticTexts.count > 0)
    }
}
