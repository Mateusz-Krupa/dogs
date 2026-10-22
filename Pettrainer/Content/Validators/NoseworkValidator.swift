import Foundation

/// Validation for one scent-game file: `data/nosework/<id>.json` (port of
/// `src/content/schema/nosework.ts`). Scent games carry no verdict fields on
/// purpose — nothing here may grow a `target` or a `score`, because the whole
/// point is that the owner judges nothing.
enum NoseworkValidator {
    private static func parseLevelCopy(
        _ value: JSONValue?, source: String, path: String
    ) throws -> LevelCopy {
        let record = try Checks.expectRecord(value, source: source, path: path)
        return LevelCopy(
            title: try Checks.expectString(
                record["title"], source: source, path: Checks.fieldPath(path, "title")),
            setup: try Checks.expectString(
                record["setup"], source: source, path: Checks.fieldPath(path, "setup")),
            how: try Checks.expectString(
                record["how"], source: source, path: Checks.fieldPath(path, "how")),
            watchFor: try Checks.expectString(
                record["watchFor"], source: source, path: Checks.fieldPath(path, "watchFor"))
        )
    }

    private static func parseLevel(
        _ value: JSONValue, source: String, index: Int
    ) throws -> NoseworkLevel {
        let path = Checks.fieldPath("levels", index)
        let record = try Checks.expectRecord(value, source: source, path: path)
        let minutes = try Checks.expectNumber(
            record["minutes"], source: source, path: Checks.fieldPath(path, "minutes"))
        guard minutes > 0 else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "minutes"), "must be more than 0")
        }
        return NoseworkLevel(
            ordinal: try Checks.expectOrdinal(
                record["ordinal"], source: source,
                path: Checks.fieldPath(path, "ordinal"), index: index),
            minutes: minutes,
            gear: try Checks.expectGearList(
                record["gear"], source: source, path: Checks.fieldPath(path, "gear")),
            pl: try parseLevelCopy(
                record["pl"], source: source, path: Checks.fieldPath(path, "pl")),
            en: try parseLevelCopy(
                record["en"], source: source, path: Checks.fieldPath(path, "en"))
        )
    }

    static func parseActivity(_ value: JSONValue, source: String) throws -> NoseworkActivity {
        let record = try Checks.expectRecord(value, source: source, path: "")
        guard let rawLevels = record["levels"]?.arrayValue else {
            throw Checks.contentError(source: source, path: "levels", "must be an array of levels")
        }
        guard !rawLevels.isEmpty else {
            throw Checks.contentError(source: source, path: "levels", "must have at least one level")
        }
        return NoseworkActivity(
            id: try Checks.expectString(record["id"], source: source, path: "id"),
            pose: try Checks.expectOneOf(record["pose"], Pose.self, source: source, path: "pose"),
            sortOrder: try Checks.expectInteger(
                record["sortOrder"], source: source, path: "sortOrder"),
            names: try ExerciseValidator.parseNames(
                record["names"], source: source, path: "names"),
            tagline: try ExerciseValidator.parseTagline(
                record["tagline"], source: source, path: "tagline"),
            levels: try rawLevels.enumerated().map { index, item in
                try parseLevel(item, source: source, index: index)
            }
        )
    }
}

/// Validation for one troubleshooting file: `data/mistakes/<id>.json` (port of
/// `src/content/schema/mistakes.ts`). All three parts are required, in both
/// locales: an entry missing one reads as a bullet point.
enum MistakeValidator {
    private static func parseEntry(
        _ value: JSONValue?, source: String, path: String
    ) throws -> MistakeEntry {
        let record = try Checks.expectRecord(value, source: source, path: path)
        return MistakeEntry(
            symptom: try Checks.expectString(
                record["symptom"], source: source, path: Checks.fieldPath(path, "symptom")),
            why: try Checks.expectString(
                record["why"], source: source, path: Checks.fieldPath(path, "why")),
            fix: try Checks.expectString(
                record["fix"], source: source, path: Checks.fieldPath(path, "fix"))
        )
    }

    static func parseMistakes(_ value: JSONValue, source: String) throws -> [Mistake] {
        guard let items = value.arrayValue else {
            throw Checks.contentError(source: source, path: "", "must be an array of entries")
        }
        guard !items.isEmpty else {
            throw Checks.contentError(source: source, path: "", "must have at least one entry")
        }
        return try items.enumerated().map { index, item in
            try Checks.expectLocales(
                item, source: source, path: "[\(index)]"
            ) { part, partPath in
                try parseEntry(part, source: source, path: partPath)
            }
        }
    }
}
