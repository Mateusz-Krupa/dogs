import Foundation

/// Hand-written checks shared by the content validators — a port of
/// `src/content/schema/checks.ts`. The messages are the point: every failure
/// names the file and the exact field path, e.g.
/// `exercises/sit.json: steps[3].pl.criterion must be a non-empty string`.

struct ContentError: Error, Equatable, CustomStringConvertible {
    let message: String
    var description: String { message }
}

enum Checks {
    /// A validation failure: `sit.json: steps[3].pl.criterion must be …`.
    static func contentError(source: String, path: String, _ rule: String) -> ContentError {
        ContentError(message: path.isEmpty
            ? "\(source) \(rule)"
            : "\(source): \(path) \(rule)")
    }

    /// Path of a child key or a list element, without a leading dot at the root.
    static func fieldPath(_ parent: String, _ key: String) -> String {
        parent.isEmpty ? key : "\(parent).\(key)"
    }

    static func fieldPath(_ parent: String, _ index: Int) -> String {
        parent.isEmpty ? "\(index)" : "\(parent)[\(index)]"
    }

    static func expectRecord(_ value: JSONValue?, source: String, path: String) throws
        -> [String: JSONValue]
    {
        guard let value, case .object(let fields) = value else {
            throw contentError(source: source, path: path, "must be an object")
        }
        return fields
    }

    /// Text the owner is meant to read. Blank counts as missing.
    static func expectString(_ value: JSONValue?, source: String, path: String) throws -> String {
        guard let value, case .string(let text) = value else {
            throw contentError(source: source, path: path, "must be a string")
        }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw contentError(source: source, path: path, "must be a non-empty string")
        }
        return text
    }

    /// Text a human has not written yet — `title` on a step. A non-string is
    /// still a mistake; an empty string comes back as nil so the app never
    /// renders a blank heading. Only an absent key or an empty string passes;
    /// a JSON `null` fails the string check, exactly like the TS original.
    static func expectUnwritten(_ value: JSONValue?, source: String, path: String) throws -> String? {
        guard let value else { return nil }
        if case .string(let text) = value {
            return text.isEmpty ? nil : text
        }
        throw contentError(source: source, path: path, "must be a string")
    }

    /// A list of prose lines. Each element must be non-empty; emptiness is the
    /// caller's decision.
    static func expectStringList(_ value: JSONValue?, source: String, path: String) throws -> [String] {
        guard let value, let items = value.arrayValue else {
            throw contentError(source: source, path: path, "must be an array of strings")
        }
        return try items.enumerated().map { index, item in
            try expectString(item, source: source, path: fieldPath(path, index))
        }
    }

    /// Optional prose bullets: absent is fine, an empty or blank list is a
    /// half-edit.
    static func expectOptionalList(
        _ value: JSONValue?, source: String, path: String
    ) throws -> [String]? {
        guard let value else { return nil }
        let list = try expectStringList(value, source: source, path: path)
        guard !list.isEmpty else {
            throw contentError(source: source, path: path, "must list something or be left out")
        }
        return list
    }

    static func expectNumber(_ value: JSONValue?, source: String, path: String) throws -> Double {
        guard let value, case .number(let number) = value, number.isFinite else {
            throw contentError(source: source, path: path, "must be a number")
        }
        return number
    }

    /// Optional flag: absent means "let the defaults decide", anything else
    /// is a typo.
    static func expectOptionalBoolean(
        _ value: JSONValue?, source: String, path: String
    ) throws -> Bool? {
        guard let value else { return nil }
        guard case .boolean(let flag) = value else {
            throw contentError(source: source, path: path, "must be true or false")
        }
        return flag
    }

    static func expectInteger(_ value: JSONValue?, source: String, path: String) throws -> Int {
        let number = try expectNumber(value, source: source, path: path)
        guard number == number.rounded(), abs(number) < 9_007_199_254_740_991 else {
            throw contentError(source: source, path: path, "must be a whole number")
        }
        return Int(number)
    }

    static func expectOneOf<V: RawRepresentable & CaseIterable>(
        _ value: JSONValue?, _: V.Type, source: String, path: String
    ) throws -> V where V.RawValue == String {
        guard let value, case .string(let text) = value, let matched = V(rawValue: text) else {
            let allowed = V.allCases.map(\.rawValue).joined(separator: ", ")
            throw contentError(source: source, path: path, "must be one of: \(allowed)")
        }
        return matched
    }

    /// A `{ pl, en }` pair; both halves are mandatory.
    static func expectLocales<Value>(
        _ value: JSONValue?, source: String, path: String,
        parse: (JSONValue?, String) throws -> Value
    ) throws -> Localized<Value> {
        let record = try expectRecord(value, source: source, path: path)
        return Localized(
            pl: try parse(record["pl"], fieldPath(path, "pl")),
            en: try parse(record["en"], fieldPath(path, "en"))
        )
    }

    /// 1-based position on a ladder, checked against the array index it sits at.
    static func expectOrdinal(
        _ value: JSONValue?, source: String, path: String, index: Int
    ) throws -> Int {
        let ordinal = try expectInteger(value, source: source, path: path)
        guard ordinal == index + 1 else {
            throw contentError(
                source: source, path: path,
                "must be \(index + 1); ordinals run contiguously from 1"
            )
        }
        return ordinal
    }

    static func expectGearList(_ value: JSONValue?, source: String, path: String) throws -> [GearId] {
        // Same order as the TS original: string checks first, then emptiness,
        // then the vocabulary — so `[""]` reports "non-empty", not "one of".
        let list = try expectStringList(value, source: source, path: path)
        guard !list.isEmpty else {
            throw contentError(source: source, path: path, "must list at least one item")
        }
        return try list.enumerated().map { index, item in
            guard let gear = GearId(rawValue: item) else {
                let allowed = GearId.allCases.map(\.rawValue).joined(separator: ", ")
                throw contentError(
                    source: source, path: fieldPath(path, index), "must be one of: \(allowed)"
                )
            }
            return gear
        }
    }
}
