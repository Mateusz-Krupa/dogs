import XCTest
@testable import Pettrainer

/// Skeleton sanity test; replaced by real domain tests in tasks 3.x.
final class AppSmokeTests: XCTestCase {
    func testRouteIsHashable() {
        let routes: Set<Route> = [.exercise(exerciseId: "sit"), .nosework(activityId: "cups")]
        XCTAssertEqual(routes.count, 2)
    }
}
