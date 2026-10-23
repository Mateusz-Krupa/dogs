import Foundation

/// One bundled content file: its logical source path (as the JS loader named
/// it, kept verbatim in validation errors) and the resource name it ships
/// under in the app bundle.
struct ContentResource: Hashable {
    /// e.g. `exercises/sit.json` — the name validation errors print.
    let source: String
    /// e.g. `exercises-sit` — file in `Resources/Content/`. The JS originals
    /// collide across families (exercises/sit.json vs mistakes/sit.json), so
    /// the bundle stores them under a dash-joined, family-prefixed name. The
    /// bytes are identical; only the filename differs.
    let resourceName: String
}

/// The typed, ordered registration of bundled content. Order lives here
/// rather than in the files because it is a property of the catalogue:
/// "renaming a file should never silently reorder the app" (load.ts).
/// Adding an exercise that uses existing primitives = JSON + one line here.
enum CatalogueManifest {
    /// Every exercise file, in teaching order (mirrors EXERCISE_FILES).
    static let exercises: [ContentResource] = names(
        ["name", "sit", "look", "down", "stay", "come", "leave", "mat", "wait", "leash", "drop", "handling"],
        folder: "exercises"
    )

    /// Scent games, in browse order (mirrors NOSEWORK_FILES; order verified
    /// against baseline/parity-data.json → order.nosework).
    static let nosework: [ContentResource] = names(
        ["scatter", "snuffle", "cups", "find-toy", "find-person", "track"],
        folder: "nosework"
    )

    /// Troubleshooting files, keyed by exercise id (mirrors MISTAKE_FILES).
    static let mistakes: [(exerciseId: String, resource: ContentResource)] = [
        "name", "sit", "look", "down", "stay", "come", "leave", "mat", "wait", "leash", "drop", "handling",
    ].map { id in
        (id, ContentResource(source: "mistakes/\(id).json", resourceName: "mistakes-\(id)"))
    }

    /// Behaviour problems, in browse order: "the loud things first, the quiet
    /// suffering of being alone last" (load.ts).
    static let behaviour: [ContentResource] = names(
        ["bark-door", "bark-window", "jumping", "nipping", "stealing", "bolting",
         "reactivity", "traffic", "noise", "mounting", "bed", "alone"],
        folder: "behaviour"
    )

    /// Hygiene routines, in browse order: the wet walk first, the rare bath
    /// last. A separate family — these never join `catalogue`, because care is
    /// participation and carries no verdict (spec: freely accessible care).
    static let care: [ContentResource] = names(
        ["care-paw-rinse", "care-nails", "care-coat", "care-checks",
         "care-teeth", "care-towel", "care-bath"],
        folder: "care"
    )

    static let environments = ContentResource(source: "environments.json", resourceName: "environments")

    private static func names(_ ids: [String], folder: String) -> [ContentResource] {
        ids.map { ContentResource(source: "\(folder)/\($0).json", resourceName: "\(folder)-\($0)") }
    }
}
