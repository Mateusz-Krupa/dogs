import Foundation

/// Validation for one behaviour-problem file: `data/behaviour/<id>.json` (port
/// of `src/content/schema/behaviour.ts`). Every section is load-bearing: a
/// card without `avoid` sends the owner down the punishment route by default,
/// and a card without `professional` is the app pretending it can fix what it
/// cannot. Both locales must carry the same shape — the UI has no fallback.
enum BehaviourValidator {
    private static func parseText(
        _ value: JSONValue?, source: String, path: String
    ) throws -> Localized<String> {
        try Checks.expectLocales(value, source: source, path: path) { part, partPath in
            try Checks.expectString(part, source: source, path: partPath)
        }
    }

    private static func parseTextList(
        _ value: JSONValue?, source: String, path: String
    ) throws -> Localized<[String]> {
        try Checks.expectLocales(value, source: source, path: path) { part, partPath in
            let list = try Checks.expectStringList(part, source: source, path: partPath)
            guard !list.isEmpty else {
                throw Checks.contentError(source: source, path: partPath, "must list something")
            }
            return list
        }
    }

    /// Observation guidance is optional for compatibility, but a card that
    /// carries it must carry both locales non-empty — a half-translated
    /// "what to watch" section is the drift this project has been bitten by.
    private static func parseOptionalTextList(
        _ value: JSONValue?, source: String, path: String
    ) throws -> Localized<[String]>? {
        guard value != nil else { return nil }
        return try parseTextList(value, source: source, path: path)
    }

    static func parseIssue(
        _ value: JSONValue, source: String, today: String? = nil
    ) throws -> BehaviourIssue {
        let record = try Checks.expectRecord(value, source: source, path: "")
        let names: Localized<IssueNames> = try Checks.expectLocales(
            record["names"], source: source, path: "names"
        ) { part, partPath in
            let entry = try Checks.expectRecord(part, source: source, path: partPath)
            return IssueNames(
                name: try Checks.expectString(
                    entry["name"], source: source, path: Checks.fieldPath(partPath, "name")),
                tagline: try Checks.expectString(
                    entry["tagline"], source: source, path: Checks.fieldPath(partPath, "tagline"))
            )
        }
        let practices = try Checks.expectStringList(
            record["practices"], source: source, path: "practices")
        guard !practices.isEmpty else {
            throw Checks.contentError(
                source: source, path: "practices", "must point at at least one exercise")
        }

        return BehaviourIssue(
            id: try Checks.expectString(record["id"], source: source, path: "id"),
            sortOrder: try Checks.expectInteger(
                record["sortOrder"], source: source, path: "sortOrder"),
            names: names,
            recognizes: try parseText(
                record["recognizes"], source: source, path: "recognizes"),
            urgent: try parseText(record["urgent"], source: source, path: "urgent"),
            avoid: try parseTextList(record["avoid"], source: source, path: "avoid"),
            now: try parseTextList(record["now"], source: source, path: "now"),
            work: try parseTextList(record["work"], source: source, path: "work"),
            professional: try parseText(
                record["professional"], source: source, path: "professional"),
            practices: practices,
            observe: try parseOptionalTextList(
                record["observe"], source: source, path: "observe"),
            evidence: try GuidanceEvidenceValidator.parseOptionalEvidence(
                record["evidence"], source: source, today: today)
        )
    }
}
