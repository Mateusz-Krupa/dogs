import XCTest

/// Task 8.2 — recorded visual audit of the native app. Every required state,
/// diagram family and welfare card is attached as a screenshot to the
/// .xcresult so the images themselves (not just green checks) are the
/// evidence, inspected afterwards at phone size and in PL/EN.
///
/// A screenshot cannot be asserted for layout, so each attachment is titled
/// in sequence; the test still fails when a state cannot be reached, because
/// an unreachable state is a bug, not a missing picture.
final class VisualAuditUITests: XCTestCase {
    private let timeout: TimeInterval = 15
    /// A set is five repetitions by product rule; hardcoded on purpose because
    /// UI tests run out of process and must not import app types.
    private let setSize = 5

    // MARK: helpers

    private func makeApp(lang: String, dbName: String) -> XCUIApplication {
        let application = XCUIApplication()
        application.launchEnvironment = ["PETTRAINER_DB_NAME": dbName]
        application.launchArguments = ["-app.language", "system", "-AppleLanguages", "(\(lang))"]
        return application
    }

    private func attach(_ label: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.lifetime = .keepAlways
        attachment.name = label
        add(attachment)
    }

    private func button(matching keys: [String], in app: XCUIApplication) -> XCUIElement {
        let predicate = NSPredicate(format: keys.map { _ in "label == %@" }.joined(separator: " OR "),
                                   argumentArray: keys)
        return app.buttons.matching(predicate).firstMatch
    }

    private func button(containing keys: [String], in app: XCUIApplication) -> XCUIElement {
        let predicate = NSPredicate(format: keys.map { _ in "label CONTAINS[cd] %@" }.joined(separator: " OR "),
                                   argumentArray: keys)
        return app.buttons.matching(predicate).firstMatch
    }

    @discardableResult
    private func tap(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        guard element.waitForExistence(timeout: timeout), element.isHittable else { return false }
        element.tap()
        return true
    }

    private func expectText(_ keys: [String], in app: XCUIApplication, _ message: String,
                            timeout: TimeInterval = 6) {
        let predicate = NSPredicate(format: keys.map { _ in "label CONTAINS[cd] %@" }.joined(separator: " OR "),
                                   argumentArray: keys)
        XCTAssertTrue(app.staticTexts.matching(predicate).firstMatch.waitForExistence(timeout: timeout),
                      message)
    }

    private func openExercise(_ id: String, in app: XCUIApplication) {
        let card = app.buttons["exercise-link-\(id)"]
        XCTAssertTrue(card.waitForExistence(timeout: timeout), "exercise card \(id) missing")
        for _ in 0..<10 where !card.isHittable { app.swipeUp() }
        card.tap()
    }

    private func leaveToPrevious(_ app: XCUIApplication) {
        let back = app.navigationBars.buttons.firstMatch
        if back.waitForExistence(timeout: 2), back.isHittable {
            back.tap()
            return
        }
        // Edge swipe from the left, the standard interactive-pop gesture.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        let finish = app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: finish)
    }

    /// Five hits, then the "+1" choice ("Następny krok"). False when the
    /// ladder cannot advance further.
    private func advanceOneStep(in app: XCUIApplication) -> Bool {
        for _ in 0..<setSize { _ = tap(button(matching: ["Got it", "Zaliczone"], in: app)) }
        expectText(["Seria zakończona", "Set complete"], in: app, "verdict card did not appear")
        return tap(button(matching: ["Następny krok", "Next step"], in: app))
    }

    /// The dock's undo control reuses "Wstecz" and is marked by the ↺ glyph,
    /// which distinguishes it from the navigation bar's back button.
    private func tapUndo(_ app: XCUIApplication) -> Bool {
        tap(button(containing: ["↺"], in: app))
    }

    // MARK: 1. interaction states, both languages

    private func auditStates(lang: String) {
        let db = "uitest-audit-states-\(lang)-\(UUID().uuidString).sqlite"
        var app = makeApp(lang: lang, dbName: db)
        app.launch()
        expectText(["plan treningu", "training plan"], in: app, "catalogue did not load", timeout: timeout)
        attach("01-catalogue-zero-progress")

        for _ in 0..<12 { app.swipeUp() }
        attach("02-catalogue-bottom-thumbnails")
        app.terminate()

        app = makeApp(lang: lang, dbName: db)
        app.launch()
        openExercise("sit", in: app)
        attach("03-set-step1-dock-idle")

        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)), "hit button not tappable")
        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)))
        attach("04-set-partial-two-reps")

        XCTAssertTrue(tapUndo(app), "undo control missing")
        attach("05-set-after-undo-one-rep")

        // Finish the set: 5/5 shows the push verdict, then advance a step.
        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)))
        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)))
        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)))
        expectText(["Seria zakończona", "Set complete"], in: app, "completed set header missing")
        attach("06-set-complete-verdict-push")
        XCTAssertTrue(tap(button(matching: ["Następny krok", "Next step"], in: app)),
                      "push choice missing after 5/5")
        attach("07-after-push-next-step")

        // The drop branch: a set of misses offers the easier choice.
        for _ in 0..<setSize { XCTAssertTrue(tap(button(matching: ["Nie zaliczone", "Missed"], in: app))) }
        attach("08-verdict-drop-choices")
        XCTAssertTrue(tap(button(matching: ["Łatwiejszy krok", "Easier step"], in: app))
                        || tap(button(matching: ["Łatwiejsze miejsce", "Easier place"], in: app)),
                      "no easier choice offered after a drop verdict")
        attach("09-easier-choice-applied")

        // Interrupt/re-entry: a partial set must come back on relaunch (F-1).
        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)))
        XCTAssertTrue(tap(button(matching: ["Got it", "Zaliczone"], in: app)))
        app.terminate()

        app = makeApp(lang: lang, dbName: db)
        app.launch()
        openExercise("sit", in: app)
        expectText(["Powtórzenie", "Rep "], in: app, "resumed set did not show its rep counter")
        attach("10-resume-partial-after-kill")
        XCTAssertTrue(tap(button(matching: ["Porzuć serię", "Abandon set"], in: app)),
                      "abandon control missing on a resumed partial set")
        attach("11-after-abandon-fresh-set")

        // Language menu copy in its own language (it is the switching surface).
        XCTAssertTrue(tap(button(containing: ["język", "language"], in: app), timeout: 4),
                      "language menu not reachable for the audit")
        attach("12-language-menu")
        app.terminate()
    }

    func testVisualAuditStatesEnglish() { auditStates(lang: "en") }
    func testVisualAuditStatesPolish() { auditStates(lang: "pl") }

    // MARK: 2. every step-diagram family

    /// One picture per diagram family. Families live on different ladder
    /// positions, so the pass walks each owning exercise step by step with
    /// real five-hit sets. Motion artwork is language-independent, so this
    /// pass runs once; the PL text states are covered by the state pass.
    private func auditDiagrams() {
        let app = makeApp(lang: "en", dbName: "uitest-audit-diagrams-\(UUID().uuidString).sqlite")
        app.launch()

        // exercise: how many ladder positions to photograph, one per family.
        let plan: [(id: String, positions: Int)] = [
            ("come", 3),      // away, collar
            ("down", 2),      // down, draw
            ("drop", 1),      // swap
            ("handling", 4),  // contact, touchPaw, lift, face
            ("leash", 1),     // leg
            ("leave", 4),     // deny, refuse
            ("look", 3),      // up, hold
            ("mat", 3),       // toss, return
            ("wait", 4),      // door, bowl
            ("sit", 1), ("name", 1), ("stay", 1),
        ]
        for entry in plan {
            openExercise(entry.id, in: app)
            attach("diag-\(entry.id)-step1")
            var step = 2
            while step <= entry.positions {
                guard advanceOneStep(in: app) else { break }
                attach("diag-\(entry.id)-step\(step)")
                step += 1
            }
            leaveToPrevious(app)
        }
        app.terminate()
    }

    func testVisualAuditDiagramFamilies() { auditDiagrams() }

    // MARK: 3. all welfare cards, both languages

    private func auditWelfareCards(lang: String) {
        let app = makeApp(lang: lang, dbName: "uitest-audit-problems-\(lang)-\(UUID().uuidString).sqlite")
        app.launch()
        let ids = ["bark-door", "bark-window", "jumping", "nipping", "stealing", "bolting",
                   "reactivity", "traffic", "noise", "mounting", "bed", "alone"]
        for id in ids {
            let card = app.buttons["problem-link-\(id)"]
            XCTAssertTrue(card.waitForExistence(timeout: timeout), "problem card \(id) missing")
            for _ in 0..<14 where !card.isHittable { app.swipeUp() }
            XCTAssertTrue(card.isHittable, "problem card \(id) never became hittable")
            card.tap()
            expectText(["stop"], in: app, "stop section missing on \(id)")
            attach("welfare-\(id)-top")
            for _ in 0..<4 { app.swipeUp() }
            attach("welfare-\(id)-scrolled")
            XCTAssertTrue(tap(app.navigationBars.buttons.firstMatch, timeout: 3), "cannot leave \(id)")
        }
        app.terminate()
    }

    func testVisualAuditWelfareCardsEnglish() { auditWelfareCards(lang: "en") }
    func testVisualAuditWelfareCardsPolish() { auditWelfareCards(lang: "pl") }

    // MARK: 4. storage failure screen

    func testVisualAuditStorageRecovery() {
        // A name whose parent folder does not exist cannot be opened, which
        // exercises the real boot-failure branch. Nothing is at stake under
        // this name: the file has never existed.
        let app = makeApp(lang: "pl", dbName: "audit-missing-folder/x.sqlite")
        app.launch()
        expectText(["Coś poszło nie tak", "Something went wrong"], in: app,
                   "storage recovery screen did not appear", timeout: timeout)
        attach("13-storage-recovery-pl")
        XCTAssertTrue(tap(button(matching: ["Spróbuj ponownie", "Try again"], in: app)),
                      "retry control missing")
        attach("14-storage-recovery-after-retry")
        app.terminate()
    }
}
