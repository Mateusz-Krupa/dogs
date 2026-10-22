import Foundation

/// Validation for one exercise file: `data/exercises/<id>.json` — a port of
/// `src/content/schema/exercise.ts`. `parseCatalogueEntry` is what the loader
/// actually calls: one file carries both the teaching content and the display
/// fields (pose, tagline, gear).
enum ExerciseValidator {
    private static func optionalEnum<V: RawRepresentable & CaseIterable>(
        _ fields: [String: JSONValue], key: String, _: V.Type,
        source: String, path: String
    ) throws -> V? where V.RawValue == String {
        // TS: `record[key] === undefined ? undefined : expectOneOf(...)` —
        // an absent key is fine, an explicit null or typo is a mistake.
        guard let value = fields[key] else { return nil }
        return try Checks.expectOneOf(value, V.self, source: source, path: Checks.fieldPath(path, key))
    }

    private static func optionalString(
        _ fields: [String: JSONValue], key: String, source: String, path: String
    ) throws -> String? {
        guard fields[key] != nil else { return nil }
        return try Checks.expectString(
            fields[key], source: source, path: Checks.fieldPath(path, key))
    }

    static func parseStepCopy(_ value: JSONValue?, source: String, path: String) throws -> StepCopy {
        let record = try Checks.expectRecord(value, source: source, path: path)
        return StepCopy(
            instruction: try Checks.expectString(
                record["instruction"], source: source, path: Checks.fieldPath(path, "instruction")),
            criterion: try Checks.expectString(
                record["criterion"], source: source, path: Checks.fieldPath(path, "criterion")),
            setup: try Checks.expectOptionalList(
                record["setup"], source: source, path: Checks.fieldPath(path, "setup")),
            reps: try Checks.expectOptionalList(
                record["reps"], source: source, path: Checks.fieldPath(path, "reps")),
            note: try optionalString(record, key: "note", source: source, path: path),
            title: try Checks.expectUnwritten(
                record["title"], source: source, path: Checks.fieldPath(path, "title"))
        )
    }

    static func parseStep(
        _ value: JSONValue?, source: String, index: Int
    ) throws -> StepSeed {
        let path = Checks.fieldPath("steps", index)
        let record = try Checks.expectRecord(value, source: source, path: path)
        return StepSeed(
            ordinal: try Checks.expectOrdinal(
                record["ordinal"], source: source,
                path: Checks.fieldPath(path, "ordinal"), index: index),
            motion: try optionalEnum(
                record, key: "motion", StepMotion.self, source: source, path: path),
            pose: try optionalEnum(
                record, key: "pose", Pose.self, source: source, path: path),
            sound: try Checks.expectOptionalBoolean(
                record["sound"], source: source, path: Checks.fieldPath(path, "sound")),
            pl: try parseStepCopy(
                record["pl"], source: source, path: Checks.fieldPath(path, "pl")),
            en: try parseStepCopy(
                record["en"], source: source, path: Checks.fieldPath(path, "en"))
        )
    }

    private static func parseSteps(_ value: JSONValue?, source: String) throws -> [StepSeed] {
        guard let items = value?.arrayValue else {
            throw Checks.contentError(source: source, path: "steps", "must be an array of steps")
        }
        guard !items.isEmpty else {
            throw Checks.contentError(source: source, path: "steps", "must have at least one step")
        }
        return try items.enumerated().map { index, item in
            try parseStep(item, source: source, index: index)
        }
    }

    static func parseNames(_ value: JSONValue?, source: String, path: String) throws -> Localized<CueNames> {
        try Checks.expectLocales(value, source: source, path: path) { part, partPath in
            let record = try Checks.expectRecord(part, source: source, path: partPath)
            return CueNames(
                name: try Checks.expectString(
                    record["name"], source: source, path: Checks.fieldPath(partPath, "name")),
                description: try Checks.expectString(
                    record["description"], source: source,
                    path: Checks.fieldPath(partPath, "description"))
            )
        }
    }

    static func parseTagline(_ value: JSONValue?, source: String, path: String) throws -> Localized<String> {
        try Checks.expectLocales(value, source: source, path: path) { part, partPath in
            try Checks.expectString(part, source: source, path: partPath)
        }
    }

    /// The full catalogue entry (teaching content + display fields).
    static func parseCatalogueEntry(_ value: JSONValue, source: String) throws -> CatalogueEntry {
        let record = try Checks.expectRecord(value, source: source, path: "")
        return CatalogueEntry(
            id: try Checks.expectString(record["id"], source: source, path: "id"),
            category: try Checks.expectOneOf(
                record["category"], ExerciseCategory.self, source: source, path: "category"),
            sortOrder: try Checks.expectInteger(
                record["sortOrder"], source: source, path: "sortOrder"),
            requires: try Checks.expectStringList(
                record["requires"], source: source, path: "requires"),
            names: try parseNames(record["names"], source: source, path: "names"),
            steps: try parseSteps(record["steps"], source: source),
            pose: try Checks.expectOneOf(record["pose"], Pose.self, source: source, path: "pose"),
            tagline: try parseTagline(record["tagline"], source: source, path: "tagline"),
            gear: try Checks.expectGearList(record["gear"], source: source, path: "gear")
        )
    }
}
