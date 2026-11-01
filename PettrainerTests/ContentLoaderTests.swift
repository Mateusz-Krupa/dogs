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
            "bolting", "reactivity", "traffic", "noise", "mounting", "bed",
            "overarousal", "fear-withdrawal", "alone",
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

    // MARK: loose-lead guidance (expand-loose-lead-guidance)

    /// Decoded shipped copy for the loose-lead exercise. These pin the reviewed
    /// wording and the welfare boundaries; whether the advice is *right* is the
    /// editorial review's job (source mapping in the change's content-review.md).
    func testLeashGuidanceCarriesEquipmentAndSniffingCopy() throws {
        let leash = try XCTUnwrap(Self.content.exercise(id: "leash"))
        XCTAssertEqual(leash.steps.count, 4)
        XCTAssertEqual(leash.steps.map(\.ordinal), [1, 2, 3, 4])
        // Criteria are the same four the exercise always trained against.
        XCTAssertEqual(leash.steps.map(\.pl.criterion), [
            "Trzy kroki z luźną smyczą.",
            "Pies sam rozluźnia smycz i ruszacie dalej.",
            "Dziesięć kroków bez napięcia smyczy.",
            "Dwadzieścia kroków na ulicy z luźną smyczą.",
        ])
        XCTAssertEqual(leash.steps.map(\.en.criterion), [
            "Three steps with a loose lead.",
            "The dog releases the tension themselves and you move on.",
            "Ten steps with no tension on the lead.",
            "Twenty steps on the street with a loose lead.",
        ])

        // The reviewed clauses are quoted in full per locale: a partial word can
        // never satisfy them ("locked" also lives inside "unlocked", which would
        // let the locked-with-slack nuance disappear and the test stay green).
        XCTAssertTrue(leash.names.pl.description
                        .contains("zwykłą smycz o stałej długości, około 2 m"),
                      leash.names.pl.description)
        XCTAssertTrue(leash.names.en.description
                        .contains("a regular fixed-length lead, around 2 m"),
                      leash.names.en.description)
        XCTAssertTrue(leash.names.pl.description
                        .contains("Smycz automatyczna utrudnia to ćwiczenie"),
                      leash.names.pl.description)
        XCTAssertTrue(leash.names.en.description
                        .contains("A retractable lead makes this exercise harder"),
                      leash.names.en.description)
        XCTAssertTrue(leash.names.pl.description
                        .contains("Zablokowana smycz automatyczna może zwisać luźno"),
                      leash.names.pl.description)
        XCTAssertTrue(leash.names.en.description
                        .contains("A locked retractable lead can hang slack"),
                      leash.names.en.description)
        // The retired categorical claims must not survive in either language.
        XCTAssertFalse(leash.names.en.description.contains("teaches it for good"))
        XCTAssertFalse(leash.names.pl.description.contains("na całe życie"))

        // Step 1 names the gear in both locales.
        XCTAssertEqual(leash.steps[0].pl.setup?.count, 4)
        XCTAssertEqual(leash.steps[0].en.setup?.count, 4)
        // Step 2: the calm stop is for goal-pulling only. A dog trying to escape a
        // fear is told to gain distance instead of being made to stand with it —
        // that retreat clause, not the word "frightening", is the safeguard.
        XCTAssertTrue(leash.steps[1].pl.note?.contains("nie każ mu przy tym stać") == true,
                      leash.steps[1].pl.note ?? "step 2 PL note missing")
        XCTAssertTrue(leash.steps[1].pl.note?.contains("zwiększ dystans") == true,
                      leash.steps[1].pl.note ?? "step 2 PL note missing")
        XCTAssertTrue(leash.steps[1].en.note?.contains("do not make them stand beside it") == true,
                      leash.steps[1].en.note ?? "step 2 EN note missing")
        XCTAssertTrue(leash.steps[1].en.note?.contains("create distance") == true,
                      leash.steps[1].en.note ?? "step 2 EN note missing")
        // Step 4: sniffing stays available outside the drilled stretch in both
        // languages, and the "sniff-free walk is a punishment" line is gone.
        XCTAssertTrue(leash.steps[3].pl.note?.contains("Poza ćwiczonym odcinkiem pies może wąchać") == true,
                      leash.steps[3].pl.note ?? "step 4 PL note missing")
        XCTAssertTrue(leash.steps[3].en.note?.contains("Outside the drilled stretch the dog may sniff freely") == true,
                      leash.steps[3].en.note ?? "step 4 EN note missing")
        XCTAssertFalse(leash.steps[3].pl.note?.contains("to dla psa kara") == true)
        XCTAssertFalse(leash.steps[3].en.note?.contains("is a punishment") == true)
    }

    func testLeashTroubleshootingCoversSniffingMovingOnAndRefusal() throws {
        let cards = Self.content.mistakes(for: "leash")
        XCTAssertEqual(cards.count, 5)
        // Each locale is checked on its own: an && pair would pass on one
        // complete language with the other empty (CONV-001).
        for card in cards {
            XCTAssertFalse(card.pl.symptom.isEmpty, "empty PL symptom")
            XCTAssertFalse(card.pl.why.isEmpty, "empty PL why")
            XCTAssertFalse(card.pl.fix.isEmpty, "empty PL fix")
            XCTAssertFalse(card.en.symptom.isEmpty, "empty EN symptom")
            XCTAssertFalse(card.en.why.isEmpty, "empty EN why")
            XCTAssertFalse(card.en.fix.isEmpty, "empty EN fix")
        }
        let pl = cards.map(\.pl), en = cards.map(\.en)
        XCTAssertTrue(pl.contains { $0.symptom.contains("węszy") })
        XCTAssertTrue(en.contains { $0.symptom.contains("sniffs") })
        XCTAssertTrue(pl.contains { $0.symptom.contains("nie chce ruszyć") })
        XCTAssertTrue(en.contains { $0.symptom.contains("will not move on") })

        let refusalPl = try XCTUnwrap(pl.first { $0.symptom.contains("odmawia") })
        let refusalEn = try XCTUnwrap(en.first { $0.symptom.contains("refuses to walk") })
        XCTAssertTrue(refusalPl.fix.contains("weterynarzem"), refusalPl.fix)
        XCTAssertTrue(refusalEn.fix.contains("veterinarian"), refusalEn.fix)
        // Fear is met with distance, never with dragging or luring toward it.
        XCTAssertTrue(refusalPl.fix.contains("nie przeciągaj psa"), refusalPl.fix)
        XCTAssertTrue(refusalEn.fix.contains("do not drag the dog"), refusalEn.fix)
        // Fear is never answered by food-luring toward the thing itself.
        XCTAssertTrue(refusalPl.fix.contains("nie wab go jedzeniem w stronę"), refusalPl.fix)
        XCTAssertTrue(refusalEn.fix.contains("bait them with food toward"), refusalEn.fix)
        // The old "stop every time" rule no longer traps a frightened dog.
        let firstPl = pl[0], firstEn = en[0]
        XCTAssertTrue(firstPl.fix.contains("zwiększ dystans i odejdźcie"), firstPl.fix)
        XCTAssertTrue(firstEn.fix.contains("make distance and leave instead"), firstEn.fix)
        // Sniffing: permitted, with no eye-contact demand; moving on: one cue,
        // paid on voluntary movement, difficulty dropped instead of lead pressure.
        let sniffPl = try XCTUnwrap(pl.first { $0.symptom.contains("węszy") })
        let sniffEn = try XCTUnwrap(en.first { $0.symptom.contains("sniffs") })
        XCTAssertTrue(sniffPl.fix.contains("Pozwól powąchać"), sniffPl.fix)
        XCTAssertTrue(sniffPl.fix.contains("nie wymagaj ciągłego patrzenia"), sniffPl.fix)
        XCTAssertTrue(sniffEn.fix.contains("Let the dog sniff"), sniffEn.fix)
        XCTAssertTrue(sniffEn.fix.contains("do not demand constant eye contact"), sniffEn.fix)
        let goPl = try XCTUnwrap(pl.first { $0.symptom.contains("nie chce ruszyć") })
        let goEn = try XCTUnwrap(en.first { $0.symptom.contains("will not move on") })
        XCTAssertTrue(goPl.fix.contains("nie ciągnij smyczą i nie powtarzaj komendy"), goPl.fix)
        XCTAssertTrue(goEn.fix.contains("do not haul on the lead or repeat the cue"), goEn.fix)
    }

    // MARK: byte-for-byte resources

    func testBundledBytesMatchBaselineChecksums() throws {
        // SHA-256 of every bundled resource must equal the captured JS
        // baseline. Files are byte-identical; only their bundle names carry a
        // family prefix (exercises-sit.json) to dodge the sit/sit collision.
        let all = CatalogueManifest.exercises + CatalogueManifest.nosework
            + CatalogueManifest.behaviour + CatalogueManifest.care
            + CatalogueManifest.puppy
            + CatalogueManifest.mistakes.map(\.resource)
            + [CatalogueManifest.environments]
        // Every registered resource is checksummed and every checksum names a
        // registered resource, so a new family cannot be added to one list and
        // silently skipped by the other.
        XCTAssertEqual(Set(ContentChecksums.sha256.keys),
                       Set(all.map(\.source)),
                       "checksum ledger and registered resources drifted apart")
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
