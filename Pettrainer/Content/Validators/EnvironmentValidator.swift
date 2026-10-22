import Foundation

/// Validation for `data/environments.json` — the distraction ladder (port of
/// `src/content/schema/environments.ts`). The file is one unit; the ladder is
/// reused on its own by the domain.
enum EnvironmentValidator {
    /// The `environment` table has CHECK (difficulty >= 1 AND difficulty <= 10).
    private static let minDifficulty = 1.0
    private static let maxDifficulty = 10.0

    private static func parseEnvironment(
        _ value: JSONValue, source: String, index: Int
    ) throws -> EnvironmentSeed {
        let path = Checks.fieldPath("environments", index)
        let record = try Checks.expectRecord(value, source: source, path: path)
        let difficulty = try Checks.expectNumber(
            record["difficulty"], source: source, path: Checks.fieldPath(path, "difficulty"))
        guard difficulty >= minDifficulty, difficulty <= maxDifficulty else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "difficulty"),
                "must be between \(Int(minDifficulty)) and \(Int(maxDifficulty))"
            )
        }
        // thresholdMetres must be present; null is a real value ("distance is
        // not the relevant variable here").
        let threshold = try Checks.expectOptionalMetres(
            record["thresholdMetres"], source: source, path: Checks.fieldPath(path, "thresholdMetres"))
        return EnvironmentSeed(
            id: try Checks.expectString(
                record["id"], source: source, path: Checks.fieldPath(path, "id")),
            difficulty: difficulty,
            distractionKind: try Checks.expectOneOf(
                record["distractionKind"], DistractionKind.self, source: source,
                path: Checks.fieldPath(path, "distractionKind")),
            sortOrder: try Checks.expectOrdinal(
                record["sortOrder"], source: source,
                path: Checks.fieldPath(path, "sortOrder"), index: index),
            thresholdMetres: threshold,
            names: try ExerciseValidator.parseTagline(
                record["names"], source: source, path: Checks.fieldPath(path, "names"))
        )
    }

    static func parseEnvironments(_ value: JSONValue?, source: String) throws -> [EnvironmentSeed] {
        guard let raw = value?.arrayValue else {
            throw Checks.contentError(source: source, path: "environments", "must be an array of rungs")
        }
        guard !raw.isEmpty else {
            throw Checks.contentError(source: source, path: "environments", "must have at least one rung")
        }
        let environments = try raw.enumerated().map { index, item in
            try parseEnvironment(item, source: source, index: index)
        }

        var seen = Set<String>()
        for (index, environment) in environments.enumerated() {
            // Ids are keys everywhere the ladder is used, so a repeat is never
            // harmless.
            guard !seen.contains(environment.id) else {
                throw Checks.contentError(
                    source: source, path: Checks.fieldPath("environments", index),
                    "id '\(environment.id)' is already used"
                )
            }
            seen.insert(environment.id)

            if index > 0 {
                let previous = environments[index - 1]
                // Ties are allowed; going backwards is not, or "move up a
                // rung" would sometimes mean "make it easier".
                guard environment.difficulty >= previous.difficulty else {
                    throw Checks.contentError(
                        source: source,
                        path: "\(Checks.fieldPath("environments", index)).difficulty",
                        "must not be below '\(previous.id)' at \(previous.difficulty)"
                    )
                }
            }
        }
        return environments
    }

    static func parseEnvironmentSet(_ value: JSONValue, source: String) throws -> EnvironmentSet {
        let record = try Checks.expectRecord(value, source: source, path: "")
        let environments = try parseEnvironments(record["environments"], source: source)
        let ids = Set(environments.map(\.id))

        func requireRung(_ id: String, path: String) throws {
            guard ids.contains(id) else {
                throw Checks.contentError(
                    source: source, path: path, "names '\(id)', which is not a rung on the ladder")
            }
        }

        let startingEnvironmentId = try Checks.expectString(
            record["startingEnvironmentId"], source: source, path: "startingEnvironmentId")
        try requireRung(startingEnvironmentId, path: "startingEnvironmentId")

        let beyondPuppyScope = try Checks.expectStringList(
            record["beyondPuppyScope"], source: source, path: "beyondPuppyScope")
        for (index, id) in beyondPuppyScope.enumerated() {
            try requireRung(id, path: Checks.fieldPath("beyondPuppyScope", index))
        }

        guard let rawCategories = record["categoryOrder"]?.arrayValue else {
            throw Checks.contentError(source: source, path: "categoryOrder", "must be an array of categories")
        }
        let categoryOrder = try rawCategories.enumerated().map { index, item in
            try Checks.expectOneOf(
                item, ExerciseCategory.self, source: source,
                path: Checks.fieldPath("categoryOrder", index))
        }

        return EnvironmentSet(
            startingEnvironmentId: startingEnvironmentId,
            beyondPuppyScope: beyondPuppyScope,
            categoryOrder: categoryOrder,
            environments: environments
        )
    }
}

extension Checks {
    /// `number | null` where the key must exist: null reads as "not applicable".
    /// A missing key hits the number check, throwing "must be a number" —
    /// exactly like `expectNumber(undefined)` in the TS original.
    static func expectOptionalMetres(
        _ value: JSONValue?, source: String, path: String
    ) throws -> Double? {
        if let value, value.isJSONNull { return nil }
        return try expectNumber(value, source: source, path: path)
    }
}
