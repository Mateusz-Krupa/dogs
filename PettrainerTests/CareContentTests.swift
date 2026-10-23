import XCTest
@testable import Pettrainer

/// Welfare and structure contract for the shipped care routines.
///
/// The checksum test proves the bytes shipped are the bytes reviewed; this
/// file pins what those bytes must mean: participation-only, safety first, and
/// care kept out of the scored system entirely (spec requirements 1–4 and 10,
/// reviewer findings C-2 and A-2).
final class CareContentTests: XCTestCase {
    private static let content = try! ContentLoader.load(bundle: .main)

    private var care: [CareRoutine] { Self.content.care }

    func testSevenRoutinesLoadInBrowseOrder() {
        XCTAssertEqual(care.map(\.id), [
            "care-paw-rinse", "care-nails", "care-coat", "care-checks",
            "care-teeth", "care-towel", "care-bath",
        ])
        for routine in care {
            XCTAssertNotNil(Self.content.careRoutine(id: routine.id), routine.id)
        }
    }

    /// The isolation rule: a care id must never be reachable as scored content.
    func testCareNeverEntersTheScoredCatalogue() {
        for routine in care {
            XCTAssertNil(Self.content.exercise(id: routine.id),
                         "care routine \(routine.id) leaks into the scored catalogue")
            XCTAssertFalse(Self.content.catalogue.contains { $0.id == routine.id })
        }
        XCTAssertEqual(Set(care.map(\.id)).count, care.count, "duplicate care ids")
    }

    /// C-2: safety text is required, bilingual, and cannot be blank-filled.
    func testSafetyBoundariesExistInBothLocales() {
        for routine in care {
            for field in [routine.urgent, routine.professional] {
                XCTAssertGreaterThan(field.pl.trimmingCharacters(in: .whitespaces).count, 40,
                                     "\(routine.id): thin urgent/professional copy (PL)")
                XCTAssertGreaterThan(field.en.trimmingCharacters(in: .whitespaces).count, 40,
                                     "\(routine.id): thin urgent/professional copy (EN)")
            }
            for stage in routine.stages {
                XCTAssertFalse(stage.pl.stop.isEmpty, "\(routine.id) stage \(stage.ordinal) PL stop")
                XCTAssertFalse(stage.en.stop.isEmpty, "\(routine.id) stage \(stage.ordinal) EN stop")
            }
        }
    }

    /// Referral routing must name a real professional, in both languages.
    func testStopLinesRouteToProfessionals() {
        for routine in care {
            XCTAssertTrue(routine.urgent.pl.contains("weterynarz")
                           || routine.professional.pl.contains("weterynarz"),
                          "\(routine.id): no veterinarian route (PL)")
            XCTAssertTrue(routine.urgent.en.lowercased().contains("veterinarian")
                           || routine.professional.en.lowercased().contains("veterinarian"),
                          "\(routine.id): no veterinarian route (EN)")
        }
        // The two routines where force is the classic mistake must say so.
        let nails = Self.content.careRoutine(id: "care-nails")!
        XCTAssertTrue(nails.urgent.pl.contains("nie prosimy nikogo"),
                      "nails must not send an unfinished dog to a groomer (PL)")
        XCTAssertTrue(nails.urgent.en.lowercased().contains("do not ask anyone"),
                      "nails: same guard in EN")
        let teeth = Self.content.careRoutine(id: "care-teeth")!
        XCTAssertTrue(teeth.urgent.pl.contains("Nigdy pasta dla ludzi"),
                      "human toothpaste must be ruled out explicitly (PL)")
        XCTAssertTrue(teeth.urgent.en.lowercased().contains("never human toothpaste")
                       || teeth.urgent.en.lowercased().contains("human toothpaste"),
                      "human toothpaste must be ruled out explicitly (EN)")
        let checks = Self.content.careRoutine(id: "care-checks")!
        XCTAssertTrue(checks.urgent.pl.contains("patyczk"), "no cotton buds in the canal (PL)")
        XCTAssertTrue(checks.urgent.en.lowercased().contains("cotton bud"),
                      "no cotton buds in the canal (EN)")
    }

    /// Three freely selectable stages; nothing that reads as a target.
    func testStagesAreThreeAndUnscored() {
        for routine in care {
            XCTAssertEqual(routine.stages.map(\.ordinal), [1, 2, 3], routine.id)
            for stage in routine.stages {
                for copy in [stage.pl, stage.en] {
                    XCTAssertFalse(copy.title.isEmpty)
                    XCTAssertFalse(copy.setup.isEmpty)
                    XCTAssertFalse(copy.how.isEmpty)
                    XCTAssertFalse(copy.watchFor.isEmpty)
                }
            }
        }
    }

    func testAdvisoryPracticeLinksResolveToRealExercises() {
        for routine in care {
            XCTAssertFalse(routine.practices.isEmpty, "\(routine.id) has no practice link")
            for practice in routine.practices {
                XCTAssertNotNil(Self.content.exercise(id: practice),
                                "\(routine.id) points at unknown exercise \(practice)")
            }
        }
    }

    /// Offline provenance: every citation is a real https address, and the two
    /// gated topics cite the sources that were actually read in full.
    func testSourcesAreCitableAndHonest() {
        for routine in care {
            XCTAssertFalse(routine.sources.isEmpty, "\(routine.id) cites nothing")
            for source in routine.sources {
                XCTAssertTrue(source.url.hasPrefix("https://"), source.url)
                XCTAssertFalse(source.title.isEmpty)
            }
        }
        XCTAssertTrue(Self.content.careRoutine(id: "care-teeth")!.sources.contains {
            $0.url.contains("xylitol")
        }, "the toothpaste hazard must cite the xylitol source")
        XCTAssertTrue(Self.content.careRoutine(id: "care-nails")!.sources.contains {
            $0.url.contains("nail-trimming")
        }, "nail stages must cite the veterinary nail-trimming protocol")
    }

    /// The wording rule from C-1: participation, never achievement.
    func testCopyNeverClaimsMastery() {
        let forbidden = ["opanowane", "mastered", "zaliczone", "passed", "ukończone", "completed"]
        for routine in care {
            let haystack = [
                routine.names.pl.description, routine.names.en.description,
                routine.tagline.pl, routine.tagline.en,
                routine.urgent.pl, routine.urgent.en,
                routine.professional.pl, routine.professional.en,
            ] + routine.stages.flatMap { stage in
                [stage.pl.title, stage.pl.setup, stage.pl.how, stage.pl.watchFor, stage.pl.stop,
                 stage.en.title, stage.en.setup, stage.en.how, stage.en.watchFor, stage.en.stop]
            }
            for text in haystack {
                for word in forbidden {
                    XCTAssertFalse(text.lowercased().contains(word),
                                   "\(routine.id): claims \(word) — care is participation only")
                }
            }
        }
    }
}
