import XCTest

/// Scroll support for the UI suite.
///
/// `isHittable` is true for a row that is only a sliver inside the viewport, so
/// a tap on its centre lands below the screen and is swallowed — which is what
/// made the problem-card gesture fail once the care section lengthened the list.
///
/// Scrolling is done in small drags on purpose. A full `swipeUp` moves this list
/// by roughly two thirds of the screen (~510 pt) while a catalogue row is ~85 pt
/// tall, so a given row can jump straight over the tappable band and then
/// ping-pong between "above it" and "below it" forever. Short drags always pass
/// through the band, and direction is chosen from the row's actual position.
enum UITestScroll {
    /// Top edge a row must clear: below the navigation bar.
    static let topEdge: CGFloat = 120
    /// Clearance kept above the home indicator so the tap centre is on screen.
    static let bottomInset: CGFloat = 56

    @discardableResult
    static func fullyVisible(_ element: XCUIElement, in app: XCUIApplication,
                             maxNudges: Int = 40) -> Bool {
        let bottomEdge = app.frame.height - bottomInset
        for _ in 0..<maxNudges {
            let frame = element.frame
            if frame == .zero {
                nudge(app, up: true)
            } else if frame.midY > bottomEdge {
                nudge(app, up: true)
            } else if frame.minY < topEdge {
                nudge(app, up: false)
            } else {
                return true
            }
        }
        let frame = element.frame
        return frame != .zero && frame.minY >= topEdge && frame.midY <= bottomEdge
    }

    /// A ~22 % screen drag: far smaller than a row-stripping swipe, and
    /// reversible, so the search converges instead of oscillating.
    private static func nudge(_ app: XCUIApplication, up: Bool) {
        let from = up ? 0.62 : 0.38
        let to = up ? 0.40 : 0.62
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: from))
        let finish = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: to))
        start.press(forDuration: 0.05, thenDragTo: finish)
    }
}
