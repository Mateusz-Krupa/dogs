import XCTest

/// Care flows (tasks 5.5 and 5.6): the safety block must be readable before any
/// instruction, stages must be freely selectable, nothing may be written just by
/// reading, and the advisory link must behave like the ordinary exercise route —
/// including the pre-existing pending-set row it creates (reviewer A-1).
final class CareFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchEnvironment = ["PETTRAINER_DB_NAME": "uitest-care-\(UUID().uuidString).sqlite"]
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

    private func button(_ keys: [String]) -> XCUIElement {
        let predicate = NSPredicate(format: keys.map { _ in "label == %@" }.joined(separator: " OR "),
                                   argumentArray: keys)
        return app.buttons.matching(predicate).firstMatch
    }

    func testAllSevenRoutinesAreListedAndOpenable() {
        expect(["training plan"], "catalogue did not load", timeout: 15)
        for id in ["care-paw-rinse", "care-nails", "care-coat", "care-checks",
                   "care-teeth", "care-towel", "care-bath"] {
            let row = app.buttons["care-link-\(id)"]
            XCTAssertTrue(row.waitForExistence(timeout: 3), "care row \(id) missing")
            XCTAssertTrue(UITestScroll.fullyVisible(row, in: app),
                            "care row \(id) never scrolled fully into view")
            row.tap()
            // Safety before instructions, and the veterinary statement in full.
            expect(["not veterinary advice"], "disclaimer missing on \(id)")
            expect(["stop"], "stop section missing on \(id)")
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    func testNothingIsWrittenByReadingAndStageThreeIsFreelySelectable() {
        let row = app.buttons["care-link-care-nails"]
        XCTAssertTrue(row.waitForExistence(timeout: 15), "care row missing")
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "nails row not reachable")
        row.tap()
        expect(["Not tried yet"], "a fresh routine must read as untried")

        // Jumping to the last stage is allowed; it is an invitation, not a gate.
        let segment = app.buttons.matching(NSPredicate(
            format: "label CONTAINS[cd] %@", "Stage 3")).firstMatch
        XCTAssertTrue(segment.waitForExistence(timeout: 5), "stage 3 segment missing")
        segment.tap()
        expect(["One paper-thin shaving"], "stage 3 content did not open")

        // Reading alone must not create a record: leave and come back.
        app.terminate()
        app.launch()
        let backIn = app.buttons["care-link-care-nails"]
        XCTAssertTrue(backIn.waitForExistence(timeout: 15))
        XCTAssertTrue(UITestScroll.fullyVisible(backIn, in: app), "nails row not reachable after relaunch")
        backIn.tap()
        expect(["Not tried yet"], "reading a stage wrote participation")
    }

    func testMarkingTriedIsHonestParticipationWording() {
        let row = app.buttons["care-link-care-coat"]
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "coat row not reachable")
        row.tap()
        XCTAssertTrue(button(["We tried this stage"]).waitForExistence(timeout: 5))
        button(["We tried this stage"]).tap()
        expect(["Furthest stage tried: 1/3"], "the record must read as an attempt")

        // And it survives a relaunch, because it is stored, not remembered.
        app.terminate()
        app.launch()
        let again = app.buttons["care-link-care-coat"]
        XCTAssertTrue(again.waitForExistence(timeout: 15))
        XCTAssertTrue(UITestScroll.fullyVisible(again, in: app), "coat row not reachable after relaunch")
        expect(["Furthest stage tried: 1/3"], "participation did not survive relaunch")
    }

    /// Reviewer A-1: the advisory chip uses the ordinary exercise route. Opening
    /// it may create that exercise's own empty pending set — exactly as opening
    /// it from the catalogue does — but care itself records no rep and no verdict.
    func testAdvisoryLinkBehavesLikeTheNormalExerciseRoute() {
        let row = app.buttons["care-link-care-nails"]
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "nails row not reachable")
        row.tap()
        expect(["Nail care"], "routine did not open")

        let chip = app.buttons["care-practice-handling"]
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "advisory practice chip missing")
        chip.tap()
        // The exercise opened normally: a dock with zero reps recorded.
        // Exact zero: "Rep " alone would also pass on a set with reps recorded.
        expect(["Rep 0 of 5"], "the advisory route did not open an untouched set", timeout: 8)
        app.navigationBars.buttons.firstMatch.tap()

        // Back in care, the record is still untouched — the visit wrote no
        // participation and no rep of its own.
        expect(["Not tried yet"], "advisory visit changed care participation")
    }

    func testPolishSafetyCopyAndParticipationWording() {
        app.terminate()
        app.launchArguments = ["-app.language", "system", "-AppleLanguages", "(pl)"]
        app.launchEnvironment = ["PETTRAINER_DB_NAME": "uitest-care-pl-\(UUID().uuidString).sqlite"]
        app.launch()
        expect(["plan treningu"], "polish catalogue did not load", timeout: 15)

        let row = app.buttons["care-link-care-teeth"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "polish care row missing")
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app), "polish teeth row not reachable")
        row.tap()
        expect(["nie jest porada weterynaryjna"], "polish disclaimer missing")
        expect(["Nigdy pasta dla ludzi"], "polish toothpaste hazard missing")
        XCTAssertTrue(button(["Próbowaliśmy tego etapu"]).waitForExistence(timeout: 5),
                      "polish mark-tried control missing")
        button(["Próbowaliśmy tego etapu"]).tap()
        expect(["Najwyższy wypróbowany etap: 1/3"], "polish participation wording wrong")
    }
}
