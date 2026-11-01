import XCTest

/// Change-local visual inspection (task 4.2 of add-puppy-toilet-guidance):
/// the toilet guide at phone size in PL and EN, and under a large Dynamic
/// Type category. Screenshots are attached to the xcresult and reviewed by a
/// person; assertions only pin the readable structure, not pixels.
final class PuppyToiletVisualTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
    }

    override func tearDown() {
        app?.terminate()
        super.tearDown()
    }

    private func launch(language: String, sizeCategory: String?, db: String) {
        var args = ["-app.language", "system", "-AppleLanguages", "(\(language))"]
        if let sizeCategory {
            args += ["-UIPreferredContentSizeCategoryName", sizeCategory]
        }
        app.launchArguments = args
        app.launchEnvironment = ["PETTRAINER_DB_NAME": "uitest-toilet-visual-\(db).sqlite"]
        app.launch()
    }

    private func expect(_ text: String, _ message: String, timeout: TimeInterval = 30) {
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", text)).firstMatch
            .waitForExistence(timeout: timeout), message)
    }

    private func openToiletGuide() {
        let entry = app.buttons["puppy-link"]
        XCTAssertTrue(entry.waitForExistence(timeout: 30), "puppy entry missing")
        XCTAssertTrue(UITestScroll.fullyVisible(entry, in: app))
        entry.tap()
        let row = app.buttons["puppy-guide-link-puppy-toilet"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "toilet row missing")
        XCTAssertTrue(UITestScroll.fullyVisible(row, in: app))
        row.tap()
    }

    private func attach(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testToiletGuidePhoneSizeEnglish() {
        launch(language: "en", sizeCategory: nil, db: "en")
        openToiletGuide()
        expect("Toilet training", "guide did not open")
        attach("toilet-en-top")
        let sources = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "Sources")).firstMatch
        XCTAssertTrue(UITestScroll.fullyVisible(sources, in: app), "sources unreachable")
        attach("toilet-en-sources")
    }

    func testToiletGuidePhoneSizePolish() {
        launch(language: "pl", sizeCategory: nil, db: "pl")
        openToiletGuide()
        expect("Nauka czystości", "guide did not open (PL)")
        attach("toilet-pl-top")
        let zrodla = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "Źródła")).firstMatch
        XCTAssertTrue(UITestScroll.fullyVisible(zrodla, in: app), "źródła unreachable (PL)")
        attach("toilet-pl-sources")
    }

    /// The app ships one deliberate typography pattern: fixed `.system(size:)`
    /// text on every screen (see the other guides and cards), so a Dynamic
    /// Type category does NOT enlarge these fonts. What the spec scenario
    /// promises — and what this test proves at a genuinely enlarged category —
    /// is that the layout does not clip or trap the long-form guide at
    /// `accessibilityL`, in both locales, all the way to the citations.
    private func expectReachableAtAccessibilitySize(language: String) {
        launch(language: language, sizeCategory: "UICTContentSizeCategoryAccessibilityL",
               db: "a11y-\(language)")
        openToiletGuide()
        let heading = language == "pl" ? "Nauka czystości" : "Toilet training"
        expect(heading, "guide did not open (\(language), accessibilityL)")
        attach("toilet-\(language)-accessibilityL-top")
        // Reach the final block of the page, not just a middle section.
        let verified = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[cd] %@", "2026-10-31")).firstMatch
        XCTAssertTrue(UITestScroll.fullyVisible(verified, in: app),
                      "the citations block never scrolls into view (\(language), accessibilityL)")
        attach("toilet-\(language)-accessibilityL-sources")
    }

    func testToiletGuideReachableAtAccessibilityLargeBothLocales() {
        expectReachableAtAccessibilitySize(language: "en")
        app.terminate()
        expectReachableAtAccessibilitySize(language: "pl")
    }
}
