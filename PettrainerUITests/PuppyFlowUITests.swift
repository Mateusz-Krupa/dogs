import XCTest

/// Puppy-start flows (task 7.2 and the P-1 carve-out at the UI seam): the hub
/// lists its fixed order, the stop block is readable before anything
/// actionable, guides carry no completion affordance, the two routes to a
/// canonical card resolve the same card, and a guidance exercise link opens
/// the ordinary untouched set — the behaviour the care advisory chip proved.
/// Text is matched by accessibility LABEL (`label(_:)`): a bare
/// `staticTexts["Sources"]` queries identifiers, which plain Text has none of.
final class PuppyFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchEnvironment = ["PETTRAINER_DB_NAME": "uitest-puppy-\(UUID().uuidString).sqlite"]
        app.launchArguments = ["-app.language", "system", "-AppleLanguages", "(en)"]
        app.launch()
    }

    override func tearDown() {
        app?.terminate()
        super.tearDown()
    }

    private func expect(_ keys: [String], _ message: String, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: keys.map { _ in "label CONTAINS[cd] %@" }
            .joined(separator: " OR "), argumentArray: keys)
        XCTAssertTrue(app.staticTexts.matching(predicate).firstMatch
                        .waitForExistence(timeout: timeout), message)
    }

    /// Case-insensitive label match: section headers render uppercased via
    /// `.textCase(.uppercase)`, so the accessibility label is "SOURCES"/"ŹRÓDŁA"
    /// even though the copy is written "Sources"/"Źródła".
    private func label(_ text: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS[cd] %@", text)).firstMatch
    }

    private func openHub() {
        // Generous first window: this is the very first UI assertion after a
        // cold install on the test simulator, and the cold launch alone can
        // eat most of a 15 s budget.
        expect(["training plan"], "catalogue did not load", timeout: 30)
        let entry = app.buttons["puppy-link"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5), "puppy entry missing from the catalogue")
        XCTAssertTrue(UITestScroll.fullyVisible(entry, in: app), "puppy entry never scrolled into view")
        entry.tap()
    }

    func testHubListsHelpNowAndFoundationsInOrder() {
        openHub()
        expect(["Help right now"], "help section header missing")
        expect(["not veterinary advice"], "disclaimer missing on the hub")
        for id in ["overarousal", "fear-withdrawal", "nipping", "mounting"] {
            let row = app.buttons["puppy-help-link-\(id)"]
            XCTAssertTrue(row.waitForExistence(timeout: 5), "help row \(id) missing")
            XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "help row \(id) unreachable")
        }
        expect(["Everyday foundations"], "foundations header missing")
        for id in ["puppy-rest", "puppy-world", "puppy-play", "puppy-first-exercises",
                   "puppy-toilet"] {
            let row = app.buttons["puppy-guide-link-\(id)"]
            XCTAssertTrue(row.waitForExistence(timeout: 5), "guide row \(id) missing")
            XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "guide row \(id) unreachable")
        }
    }

    func testToiletGuideHasQuickResponseThenReadableSections() {
        openHub()
        let row = app.buttons["puppy-guide-link-puppy-toilet"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "toilet guide row missing")
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "toilet guide row unreachable")
        row.tap()
        expect(["Toilet training"], "toilet guide did not open")
        // Safety first: the stop box precedes the quick response and the sections.
        expect(["Stop — before you start"], "toilet guide missing its stop block")
        expect(["emergency"], "urgent straining triage missing", timeout: 10)
        // The approved during-accident rule is on-screen in the quick list.
        expect(["let it finish"], "the let-it-finish rule is missing from the quick response")

        // Reading material: no attempt or completion controls anywhere.
        XCTAssertEqual(app.buttons.matching(NSPredicate(
            format: "label CONTAINS[cd] %@", "tried")).count, 0,
            "the toilet guide exposed a completion control")

        // A titled section from the middle of the long copy scrolls into view,
        // and the citations close the page.
        let routine = app.descendants(matching: .any)["puppy-section-outdoor-routine"].firstMatch
        XCTAssertTrue(routine.waitForExistence(timeout: 5), "outdoor-routine section missing")
        XCTAssertTrue(UITestScroll.fullyVisible(routine, in: app),
                      "the outdoor routine section never scrolls into view")
        let sources = label("Sources")
        XCTAssertTrue(UITestScroll.fullyVisible(sources, in: app),
                      "the citations block never scrolls into view")
        expect(["2026-10-31"], "toilet guide verification date missing")

        // Back and re-entry: still reading, nothing marked as done.
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "hub did not come back")
        row.tap()
        expect(["Toilet training"], "the guide state changed after leaving it")
    }

    func testOverarousalCardFromHubHasStopFirstAndSources() {
        openHub()
        let card = app.buttons["puppy-help-link-overarousal"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        XCTAssertTrue(UITestScroll.fullyVisible(card, in: app), "overarousal row unreachable")
        card.tap()
        expect(["Revved up"], "canonical card did not open from the hub")
        // The stop box is the first actionable section; its label is present
        // with no scrolling, so nothing actionable precedes it.
        expect(["Stop — before you start"], "stop section missing on overarousal")
        let sources = label("Sources")
        XCTAssertTrue(UITestScroll.fullyVisible(sources, in: app),
                      "the citations block never scrolls into view")
        XCTAssertTrue(sources.exists)
        expect(["2026-10-24"], "verification date missing")

        // The problems list reaches the same card by its own route.
        app.navigationBars.buttons.firstMatch.tap()   // hub
        app.navigationBars.buttons.firstMatch.tap()   // catalogue
        let problemRow = app.buttons["problem-link-overarousal"]
        XCTAssertTrue(problemRow.waitForExistence(timeout: 5), "card missing from the problems list")
        XCTAssertTrue(UITestScroll.fullyVisible(problemRow, in: app), "problem row unreachable")
        problemRow.tap()
        expect(["Revved up"], "the two routes do not resolve the same card")
    }

    func testGuideHasNoCompletionAndItsExerciseLinkOpensAnUntouchedSet() {
        openHub()
        let row = app.buttons["puppy-guide-link-puppy-first-exercises"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "guide row unreachable")
        row.tap()
        expect(["First short exercises"], "guide did not open")
        expect(["Stop — before you start"], "guide missing its stop block")

        // Reading material: no attempt buttons anywhere on any guide screen.
        XCTAssertEqual(app.buttons.matching(NSPredicate(
            format: "label CONTAINS[cd] %@", "tried")).count, 0,
            "a guide exposed a completion control")

        let chip = app.buttons["puppy-practice-link-name"]
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "practice chip missing")
        XCTAssertTrue(UITestScroll.fullyVisible(chip, in: app), "practice chip unreachable")
        chip.tap()
        expect(["Rep 0 of 5"], "the guidance link did not open an untouched set", timeout: 8)
        app.navigationBars.buttons.firstMatch.tap()

        // Back in the guide: nothing marked it read, the content is unchanged.
        expect(["First short exercises"], "guide state changed after visiting an exercise")
    }

    func testPolishHubAndGuideCopy() {
        app.terminate()
        app.launchArguments = ["-app.language", "system", "-AppleLanguages", "(pl)"]
        app.launchEnvironment = ["PETTRAINER_DB_NAME": "uitest-puppy-pl-\(UUID().uuidString).sqlite"]
        app.launch()
        expect(["plan treningu"], "polish catalogue did not load", timeout: 15)
        let entry = app.buttons["puppy-link"]
        XCTAssertTrue(entry.waitForExistence(timeout: 5), "polish puppy entry missing")
        XCTAssertTrue(UITestScroll.fullyVisible(entry, in: app))
        entry.tap()
        expect(["Pomoc teraz"], "polish help header missing")
        expect(["nie jest porada weterynaryjna"], "polish disclaimer missing")
        let rest = app.buttons["puppy-guide-link-puppy-rest"]
        XCTAssertTrue(rest.waitForExistence(timeout: 5), "polish guide row missing")
        XCTAssertTrue(UITestScroll.fullyVisible(rest, in: app))
        rest.tap()
        expect(["Odpoczynek i spokojne miejsce"], "polish guide did not open")
        expect(["Stop — zanim zaczniesz"], "polish stop label missing")
        let sources = label("Źródła")
        XCTAssertTrue(UITestScroll.fullyVisible(sources, in: app),
                      "polish citations block never scrolls into view")
        expect(["PDSA"], "polish guide lost its citations")

        // The toilet guide in Polish (task 5.5 parity): the during-accident
        // rule and one titled section must render in the selected language,
        // not fall back to the EN strings.
        app.navigationBars.buttons.firstMatch.tap()
        let toilet = app.buttons["puppy-guide-link-puppy-toilet"]
        XCTAssertTrue(toilet.waitForExistence(timeout: 5), "polish toilet guide row missing")
        XCTAssertTrue(UITestScroll.fullyVisible(toilet, in: app), "polish toilet row unreachable")
        toilet.tap()
        expect(["Nauka czystości"], "polish toilet guide did not open")
        expect(["pozwól skończyć"], "polish let-it-finish rule missing")
        let routine = app.descendants(matching: .any)["puppy-section-outdoor-routine"].firstMatch
        XCTAssertTrue(routine.waitForExistence(timeout: 5), "polish section missing")
        XCTAssertTrue(UITestScroll.fullyVisible(routine, in: app),
                      "polish section never scrolls into view")
        expect(["Spokojna rutyna wyjść"], "polish section title missing")
    }
}
