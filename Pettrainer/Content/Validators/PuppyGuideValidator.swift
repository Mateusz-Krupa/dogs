import Foundation

/// Validation for the provenance shipped on puppy guides and the guidance
/// cards that gained evidence. The URL discipline is deliberately the same
/// one `CareValidator` enforces (same messages, same checks): a citation that
/// cannot be opened is not a citation. The date is injected in tests so a
/// fixture pinned to "today" never goes stale — and so "verified in the
/// future" always fails, no matter when the suite runs.
enum GuidanceEvidenceValidator {
    static let maxSources = 5
    static let maxTitleLength = 120

    /// The calendar day, always counted in the Gregorian system but taken in
    /// the owner's own time zone. `verifiedOn` is the day a person read the
    /// sources on their device, so "not in the future" must be judged against
    /// the local civil day (a UTC clock would reject a source verified "today"
    /// on any device ahead of UTC, e.g. at local 00:xx with +02:00) — and it
    /// must ignore the device's *calendar style*: a phone set to the Japanese
    /// or Islamic calendar would otherwise report a smaller year and
    /// false-future every bundled 2026 date, refusing the app to launch.
    static func today(_ now: Date = Date(), timeZone: TimeZone = .current) -> String {
        // A fresh Gregorian calendar is deliberate: reading `Calendar.current`
        // would inherit the device's calendar *style* (Japanese/Reiwa, Islamic)
        // and report a non-Gregorian year, false-futuring every 2026 file.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day], from: now)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }

    private static func parseSource(
        _ value: JSONValue, source: String, index: Int
    ) throws -> CareSource {
        let path = Checks.fieldPath("evidence.sources", index)
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
        guard title == title.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.contains(where: { $0 == "\n" || $0 == "\r" }) else {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, "title"),
                "must be a single trimmed line")
        }
        let raw = try Checks.expectString(
            record["url"], source: source, path: Checks.fieldPath(path, "url"))
        // Whitespace before parsing: URL(string:) percent-encodes a space
        // instead of failing, and a URL with a space in it is a typo.
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

    /// `verifiedOn` is trusted only as a real calendar date that is not after
    /// the day of validation: "verified tomorrow" is a fabrication, and a
    /// made-up month is a typo.
    static func parseEvidence(
        _ value: JSONValue?, source: String, today todayOverride: String? = nil
    ) throws -> GuidanceEvidence {
        let todayValue = todayOverride ?? today()
        let record = try Checks.expectRecord(value, source: source, path: "evidence")
        let unexpected = record.keys.filter { $0 != "sources" && $0 != "verifiedOn" }.sorted()
        guard unexpected.isEmpty else {
            throw Checks.contentError(
                source: source, path: "evidence",
                "may only carry sources and verifiedOn, found \(unexpected.joined(separator: ", "))")
        }
        guard let items = record["sources"]?.arrayValue else {
            throw Checks.contentError(
                source: source, path: "evidence.sources", "must be an array of sources")
        }
        guard !items.isEmpty else {
            throw Checks.contentError(
                source: source, path: "evidence.sources", "must cite at least one source")
        }
        guard items.count <= maxSources else {
            throw Checks.contentError(
                source: source, path: "evidence.sources",
                "must cite at most \(maxSources) sources")
        }
        let sources = try items.enumerated().map { index, item in
            try parseSource(item, source: source, index: index)
        }
        var seen = Set<String>()
        for item in sources where !seen.insert(item.url).inserted {
            throw Checks.contentError(
                source: source, path: "evidence.sources", "must not repeat \(item.url)")
        }
        let date = try Checks.expectString(
            record["verifiedOn"], source: source, path: "evidence.verifiedOn")
        let pieces = date.split(separator: "-", omittingEmptySubsequences: false)
        guard pieces.count == 3, pieces[0].count == 4, pieces[1].count == 2, pieces[2].count == 2,
              let year = Int(pieces[0]), let month = Int(pieces[1]), let day = Int(pieces[2])
        else {
            throw Checks.contentError(
                source: source, path: "evidence.verifiedOn", "must be a YYYY-MM-DD date")
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        // Lenient resolution would turn 2026-02-30 into 2026-03-02, so all
        // three components must survive the round-trip, not just the year.
        guard let parsed = calendar.date(
            from: DateComponents(year: year, month: month, day: day)
        ), calendar.dateComponents([.year, .month, .day], from: parsed)
            == DateComponents(year: year, month: month, day: day) else {
            throw Checks.contentError(
                source: source, path: "evidence.verifiedOn", "must be a real calendar date")
        }
        guard date <= todayValue else {
            throw Checks.contentError(
                source: source, path: "evidence.verifiedOn",
                "must not be after today (\(todayValue))")
        }
        return GuidanceEvidence(sources: sources, verifiedOn: date)
    }

    /// The optional form used on behaviour cards: absent is fine (old cards
    /// predate provenance), present-but-malformed is not.
    static func parseOptionalEvidence(
        _ value: JSONValue?, source: String, today todayOverride: String? = nil
    ) throws -> GuidanceEvidence? {
        guard value != nil else { return nil }
        return try parseEvidence(value, source: source, today: todayOverride)
    }
}

/// Validation for one puppy-start guide: `data/puppy/<puppy-id>.json`.
///
/// The design rule the validator enforces is that these files are education,
/// not training: a scoring key that slipped in here would turn "rest" into a
/// thing the dog passes or fails, which is exactly the confusion this feature
/// must never allow (spec: foundations are educational rather than scored).
enum PuppyGuideValidator {
    /// `puppy-` keeps guide ids out of the exercise/nosework/care namespaces.
    static let idPrefix = "puppy-"

    /// Keys that would import scored-training semantics into a guide.
    static let forbiddenKeys: [String] = [
        "criterion", "reps", "repetitions", "target", "score", "verdict",
        "pass", "passed", "completed", "completion", "mastered", "stage", "stages",
        "level", "levels", "timer", "minutes", "requires", "prerequisite",
        "prerequisites", "unlocked", "environment", "environmentId", "environment_id",
    ]

    private static func rejectScoringKeys(
        _ record: [String: JSONValue], source: String, path: String
    ) throws {
        for key in forbiddenKeys where record.keys.contains(key) {
            throw Checks.contentError(
                source: source, path: Checks.fieldPath(path, key),
                "is not allowed on a puppy guide: reading is never scored")
        }
    }

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

    /// Optional `sections`: absence is a guide written before sections existed,
    /// which must keep parsing untouched. Presence is held to the same bar as
    /// everything a reader is promised — a half-edited section, a duplicated
    /// heading id or a scoring key smuggled into a reading block fails here,
    /// because a section must never become a stage (spec: optional foundation
    /// sections are validated without breaking older guides).
    private static func parseSections(
        _ value: JSONValue?, source: String, path: String
    ) throws -> [PuppyGuideSection] {
        // Absent key = the old shape, still valid. An explicit `null` is not
        // absence: JSONValue hands nulls through as .null, so the optional
        // binding alone would wave it past (`isJSONNull`).
        guard let value else { return [] }
        guard !value.isJSONNull, let items = value.arrayValue else {
            throw Checks.contentError(source: source, path: path, "must be an array of sections")
        }
        guard !items.isEmpty else {
            throw Checks.contentError(
                source: source, path: path, "must list sections or be left out")
        }
        var seen: Set<String> = []
        return try items.enumerated().map { index, item in
            let sectionPath = Checks.fieldPath(path, index)
            let record = try Checks.expectRecord(item, source: source, path: sectionPath)
            try rejectScoringKeys(record, source: source, path: sectionPath)
            let unexpected = record.keys.filter {
                $0 != "id" && $0 != "title" && $0 != "paragraphs"
            }.sorted()
            guard unexpected.isEmpty else {
                throw Checks.contentError(
                    source: source, path: sectionPath,
                    "may only carry id, title and paragraphs, found \(unexpected.joined(separator: ", "))")
            }
            let id = try Checks.expectString(
                record["id"], source: source, path: Checks.fieldPath(sectionPath, "id"))
            guard seen.insert(id).inserted else {
                throw Checks.contentError(
                    source: source, path: Checks.fieldPath(sectionPath, "id"),
                    "must be unique; section \"\(id)\" appears twice")
            }
            return PuppyGuideSection(
                id: id,
                title: try parseText(
                    record["title"], source: source,
                    path: Checks.fieldPath(sectionPath, "title")),
                paragraphs: try parseTextList(
                    record["paragraphs"], source: source,
                    path: Checks.fieldPath(sectionPath, "paragraphs"))
            )
        }
    }

    static func parseGuide(
        _ value: JSONValue, source: String, today: String? = nil
    ) throws -> PuppyGuide {
        let record = try Checks.expectRecord(value, source: source, path: "")
        try rejectScoringKeys(record, source: source, path: "")

        let id = try Checks.expectString(record["id"], source: source, path: "id")
        guard id.hasPrefix(idPrefix) else {
            throw Checks.contentError(
                source: source, path: "id", "must start with \"\(idPrefix)\" so ids cannot collide")
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
        // Practices may be empty: a guide with nothing to drill is honest.
        let practices = try Checks.expectStringList(
            record["practices"], source: source, path: "practices")

        return PuppyGuide(
            id: id,
            pose: try Checks.expectOneOf(record["pose"], Pose.self, source: source, path: "pose"),
            sortOrder: try Checks.expectInteger(
                record["sortOrder"], source: source, path: "sortOrder"),
            names: names,
            urgent: try parseText(record["urgent"], source: source, path: "urgent"),
            avoid: try parseTextList(record["avoid"], source: source, path: "avoid"),
            actions: try parseTextList(record["actions"], source: source, path: "actions"),
            observe: try parseTextList(record["observe"], source: source, path: "observe"),
            professional: try parseText(
                record["professional"], source: source, path: "professional"),
            practices: practices,
            evidence: try GuidanceEvidenceValidator.parseEvidence(
                record["evidence"], source: source, today: today),
            sections: try parseSections(record["sections"], source: source, path: "sections")
        )
    }
}
