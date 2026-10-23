import CryptoKit
import XCTest
@testable import Pettrainer

/// Loads the real bundled content and pins it to the captured JS baseline
/// (openspec/changes/migrate-to-native-swift/baseline/parity-data.json).
final class ContentLoaderTests: XCTestCase {

    private static var content: TrainingContent!

    override class func setUp() {
        super.setUp()
        do {
            content = try ContentLoader.load(bundle: .main)
        } catch {
            XCTFail("bundled content must load: \(error)")
        }
    }

    // MARK: inventory + order (parity contract)

    func testCatalogueCountsAndTeachingOrder() {
        XCTAssertEqual(Self.content.catalogue.map(\.id), [
            "name", "sit", "look", "down", "stay", "come", "leave", "mat",
            "wait", "leash", "drop", "handling",
        ])
    }

    func testNoseworkOrderAndCounts() {
        XCTAssertEqual(Self.content.nosework.map(\.id), [
            "scatter", "snuffle", "cups", "find-toy", "find-person", "track",
        ])
    }

    func testBehaviourOrderAndCounts() {
        XCTAssertEqual(Self.content.behaviour.map(\.id), [
            "bark-door", "bark-window", "jumping", "nipping", "stealing",
            "bolting", "reactivity", "traffic", "noise", "mounting", "bed", "alone",
        ])
    }

    func testEnvironmentLadder() {
        let environments = Self.content.environments
        XCTAssertEqual(environments.count, 23)
        XCTAssertEqual(Self.content.startingEnvironmentId, "quiet-room")
        XCTAssertEqual(Self.content.beyondPuppyScope,
                       ["dogs-close", "toy-in-motion", "dogs-playing", "wildlife-fleeing"])
        XCTAssertEqual(Self.content.categoryOrder, [.foundation, .impulseControl, .advanced])
        // Difficulty is ordinal: never goes down as the ladder goes up.
        zip(environments, environments.dropFirst()).forEach { previous, next in
            XCTAssertGreaterThanOrEqual(next.difficulty, previous.difficulty)
        }
    }

    func testMistakesExistForEveryExercise() {
        for entry in Self.content.catalogue {
            XCTAssertFalse(Self.content.mistakes(for: entry.id).isEmpty,
                           "mistakes missing for \(entry.id)")
        }
        XCTAssertEqual(Self.content.mistakes(for: "sit").count, 3)
        XCTAssertTrue(Self.content.mistakes(for: "no-such-exercise").isEmpty)
    }

    // MARK: spot checks against the JSON originals

    func testSitEntryMatchesBaseline() throws {
        let sit = try XCTUnwrap(Self.content.exercise(id: "sit"))
        XCTAssertEqual(sit.category, .foundation)
        XCTAssertEqual(sit.sortOrder, 1)
        XCTAssertEqual(sit.requires, [])
        XCTAssertEqual(sit.gear, [.treats])
        XCTAssertEqual(sit.pose, .sit)
        XCTAssertEqual(sit.names.pl.name, "siad")
        XCTAssertEqual(sit.steps.count, 10)
        XCTAssertEqual(sit.steps[0].ordinal, 1)
        XCTAssertEqual(sit.steps[0].motion, .up)
        XCTAssertEqual(sit.steps[7].sound, true) // ordinal 8 is the spoken step
        XCTAssertNil(sit.steps[8].sound)
        XCTAssertNotNil(sit.steps[0].pl.setup)
        XCTAssertEqual(sit.steps[0].pl.title, nil) // "" means unwritten → nil
    }

    func testLookAndCupsDetails() throws {
        let look = try XCTUnwrap(Self.content.exercise(id: "look"))
        XCTAssertEqual(look.names.pl.name, "patrz")
        let cups = try XCTUnwrap(Self.content.noseworkActivity(id: "cups"))
        XCTAssertEqual(cups.levels.count, 3)
        XCTAssertGreaterThan(cups.levels[0].minutes, 0)
    }

    // MARK: byte-for-byte resources

    func testBundledBytesMatchBaselineChecksums() throws {
        // SHA-256 of every bundled resource must equal the captured JS
        // baseline. Files are byte-identical; only their bundle names carry a
        // family prefix (exercises-sit.json) to dodge the sit/sit collision.
        let all = CatalogueManifest.exercises + CatalogueManifest.nosework
            + CatalogueManifest.behaviour + CatalogueManifest.care
            + CatalogueManifest.mistakes.map(\.resource)
            + [CatalogueManifest.environments]
        var expected: [String: String] = [:]
        for resource in all { expected[resource.source] = ContentChecksums.sha256[resource.source] }
        for resource in all {
            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resource.resourceName, withExtension: "json", subdirectory: "Content")
                    ?? Bundle.main.url(forResource: resource.resourceName, withExtension: "json"),
                "missing bundled resource \(resource.source)")
            let digest = try SHA256.hash(data: Data(contentsOf: url))
            let hex = digest.map { String(format: "%02x", $0) }.joined()
            XCTAssertEqual(hex, expected[resource.source], "checksum drift for \(resource.source)")
        }
    }
}
