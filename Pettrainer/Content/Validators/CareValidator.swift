import Foundation

/// Validation for one hygiene routine: `data/care/<care-id>.json` (port of
/// `src/content/schema/care.ts`). The two rules that carry the design are the
/// same in both runtimes: a routine must state its safety boundaries in both
/// locales, and it must be impossible to score it.
enum CareValidator {
    /// Every routine offers exactly three invitations.
    static let stageCount = 3
    /// `care-` keeps these ids from ever colliding with exercises or games.
    static let idPrefix = "care-"
    /// Provenance is capped so a card stays readable and reviewable.
    static let maxSources = 5
    static let maxTitleLength = 120

    /// Keys that would import scored-training semantics into a care routine.
    static let forbiddenKeys: [String] = [
        "criterion", "reps", "repetitions", "target", "score", "verdict",
        "pass", "passed", "completed", "completion", "mastered",
        "requires", "prerequisite", "prerequisites", "unlocked",
        "environment", "environmentId", "environment_id",
    ]

    private static func rejectScoringKeys(
        _ record: [String: JSONValue], source: String, path: String
    ) throws {
        for key in forbiddenKeys where record.keys.contains(key) {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, key),
                "is not allowed on a care routine: participation is never scored")
        }
    }

    private static func parseText(
        _ value: JSONValue?, source: String, path: String
    ) throws -> Localized<String> {
        try Checks.expectLocales(value, source: source, path: path) { part, partPath in
            try Checks.expectString(part, source: source, path: partPath)
        }
    }

    private static func parseSource(
        _ value: JSONValue, source: String, index: Int
    ) throws -> CareSource {
        let path = Checks.fieldPath("sources", index)
        let record = try Checks.expectRecord(value, source: source, path: path)
        let unexpected = record.keys.filter { $0 != "title" && $0 != "url" }.sorted()
        guard unexpected.isEmpty else {
            throw Checks.contentError(
                source: source, path: path,
                "may only carry title and url, found \(unexpected.joined(separator: ", "))")
        }
        let title = try Checks.expectString(
            record["title"], source: source, path: Checks.fieldPath(path, "title"))
        guard title.count <= maxTitleLength else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "title"),
                "must be at most \(maxTitleLength) characters")
        }
        // A citation label is one line: padding or a line break means the field
        // was pasted out of a page instead of written.
        guard title == title.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.contains(where: { $0 == "\n" || $0 == "\r" }) else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "title"),
                "must be a single trimmed line")
        }
        let raw = try Checks.expectString(
            record["url"], source: source, path: Checks.fieldPath(path, "url"))
        // Whitespace is checked before parsing: a URL parser percent-encodes a
        // space instead of failing, and "https://example.com/a b" is a typo.
        guard !raw.contains(where: { $0.isWhitespace }) else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "url"),
                "must not contain whitespace")
        }
        guard let url = URL(string: raw), url.scheme != nil, url.host != nil else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "url"), "must be an absolute URL")
        }
        guard url.scheme?.lowercased() == "https" else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "url"), "must be an https:// address")
        }
        guard let host = url.host, host.contains(".") else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "url"), "must name a host")
        }
        guard url.user == nil, url.password == nil else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "url"),
                "must not carry credentials")
        }
        return CareSource(title: title, url: raw)
    }

    private static func parseSources(
        _ value: JSONValue?, source: String
    ) throws -> [CareSource] {
        guard let items = value?.arrayValue else {
            throw Checks.contentError(source: source, path: "sources", "must be an array of sources")
        }
        guard !items.isEmpty else {
            throw Checks.contentError(
                source: source, path: "sources", "must cite at least one source")
        }
        guard items.count <= maxSources else {
            throw Checks.contentError(
                source: source, path: "sources", "must cite at most \(maxSources) sources")
        }
        let sources = try items.enumerated().map { index, item in
            try parseSource(item, source: source, index: index)
        }
        var seen = Set<String>()
        for item in sources where !seen.insert(item.url).inserted {
            throw Checks.contentError(
                source: source, path: "sources", "must not repeat \(item.url)")
        }
        return sources
    }

    private static func parseStageCopy(
        _ value: JSONValue?, source: String, path: String
    ) throws -> CareStageCopy {
        let record = try Checks.expectRecord(value, source: source, path: path)
        try rejectScoringKeys(record, source: source, path: path)
        return CareStageCopy(
            title: try Checks.expectString(
                record["title"], source: source, path: Checks.fieldPath(path, "title")),
            setup: try Checks.expectString(
                record["setup"], source: source, path: Checks.fieldPath(path, "setup")),
            how: try Checks.expectString(
                record["how"], source: source, path: Checks.fieldPath(path, "how")),
            watchFor: try Checks.expectString(
                record["watchFor"], source: source, path: Checks.fieldPath(path, "watchFor")),
            // The stage-level hazard is required: the routine's own stop-line
            // sits above it, but water, clippers and a muzzle each need their own.
            stop: try Checks.expectString(
                record["stop"], source: source, path: Checks.fieldPath(path, "stop"))
        )
    }

    private static let stageKeys: [String] = ["ordinal", "gear", "pl", "en"]

    private static func parseStage(
        _ value: JSONValue, source: String, index: Int
    ) throws -> CareStage {
        let path = Checks.fieldPath("stages", index)
        let record = try Checks.expectRecord(value, source: source, path: path)
        // Name the scoring mistake as the scoring mistake, before the generic
        // unknown-key message, so the error says why it can never belong here.
        try rejectScoringKeys(record, source: source, path: path)
        // Provenance belongs to the routine; an unknown stage key is a typo.
        let unexpected = record.keys.filter { !stageKeys.contains($0) }.sorted()
        guard unexpected.isEmpty else {
            throw Checks.contentError(
                source: source, path: path,
                "may only carry \(stageKeys.joined(separator: ", ")), found \(unexpected.joined(separator: ", "))")
        }
        return CareStage(
            ordinal: try Checks.expectOrdinal(
                record["ordinal"], source: source,
                path: Checks.fieldPath(path, "ordinal"), index: index),
            gear: try Checks.expectGearList(
                record["gear"], source: source, path: Checks.fieldPath(path, "gear")),
            pl: try parseStageCopy(
                record["pl"], source: source, path: Checks.fieldPath(path, "pl")),
            en: try parseStageCopy(
                record["en"], source: source, path: Checks.fieldPath(path, "en"))
        )
    }

    static func parseRoutine(_ value: JSONValue, source: String) throws -> CareRoutine {
        let record = try Checks.expectRecord(value, source: source, path: "")
        try rejectScoringKeys(record, source: source, path: "")

        let id = try Checks.expectString(record["id"], source: source, path: "id")
        guard id.hasPrefix(idPrefix) else {
            throw Checks.contentError(
                source: source, path: "id", "must start with \"\(idPrefix)\" so ids cannot collide")
        }
        guard let rawStages = record["stages"]?.arrayValue else {
            throw Checks.contentError(source: source, path: "stages", "must be an array of stages")
        }
        guard rawStages.count == stageCount else {
            throw Checks.contentError(
                source: source, path: "stages", "must offer exactly \(stageCount) stages")
        }
        let practices = try Checks.expectStringList(
            record["practices"], source: source, path: "practices")
        guard !practices.isEmpty else {
            throw Checks.contentError(
                source: source, path: "practices", "must point at at least one exercise")
        }
        let names: Localized<CueNames> = try Checks.expectLocales(
            record["names"], source: source, path: "names"
        ) { part, partPath in
            let entry = try Checks.expectRecord(part, source: source, path: partPath)
            return CueNames(
                name: try Checks.expectString(
                    entry["name"], source: source, path: Checks.fieldPath(partPath, "name")),
                description: try Checks.expectString(
                    entry["description"], source: source,
                    path: Checks.fieldPath(partPath, "description"))
            )
        }

        return CareRoutine(
            id: id,
            pose: try Checks.expectOneOf(record["pose"], Pose.self, source: source, path: "pose"),
            sortOrder: try Checks.expectInteger(
                record["sortOrder"], source: source, path: "sortOrder"),
            names: names,
            tagline: try parseText(record["tagline"], source: source, path: "tagline"),
            urgent: try parseText(record["urgent"], source: source, path: "urgent"),
            professional: try parseText(
                record["professional"], source: source, path: "professional"),
            practices: practices,
            sources: try parseSources(record["sources"], source: source),
            stages: try rawStages.enumerated().map { index, stage in
                try parseStage(stage, source: source, index: index)
            }
        )
    }
}
