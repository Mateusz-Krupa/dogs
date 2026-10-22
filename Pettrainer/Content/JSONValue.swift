import Foundation

/// Minimal JSON tree the content validators walk.
///
/// Deliberately not `Codable`: the JS original validated by hand so every
/// failure names the file and the exact field path
/// (`exercises/sit.json: steps[3].pl.criterion must be a non-empty string`).
/// Decoding libraries report their own internal paths, which is useless to the
/// person editing a JSON file, so the hand-written checks are ported as-is.
///
/// `field(_:)` returns `nil` only when the key is absent — JSON `null` comes
/// back as `.null`. This mirrors JS exactly: `record.note === undefined` is
/// false for an explicit `null`, so a null where a check expects absence (or a
/// value) fails with a named-field error rather than passing silently.
indirect enum JSONValue {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null

    init(data: Data) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        self = JSONValue(from: object)
    }

    private init(from object: Any) {
        switch object {
        case let dictionary as [String: Any]:
            var fields: [String: JSONValue] = [:]
            for (key, value) in dictionary { fields[key] = JSONValue(from: value) }
            self = .object(fields)
        case let items as [Any]:
            self = .array(items.map(JSONValue.init(from:)))
        case is NSNull:
            self = .null
        case let string as String:
            self = .string(string)
        case let number as NSNumber:
            // JSONSerialization bridges true/false to NSNumber too; identity
            // with the singletons keeps `true` from ever reading as `1`.
            if number === kCFBooleanTrue || number === kCFBooleanFalse {
                self = .boolean(number.boolValue)
            } else {
                self = .number(number.doubleValue)
            }
        default:
            self = .null
        }
    }

    /// Value under `key`, or `nil` when the key is absent (or self is not an object).
    func field(_ key: String) -> JSONValue? {
        guard case .object(let fields) = self else { return nil }
        return fields[key]
    }

    /// True for an explicit JSON `null` (as opposed to a missing key).
    var isJSONNull: Bool {
        if case .null = self { return true }
        return false
    }

    var arrayValue: [JSONValue]? {
        if case .array(let items) = self { return items }
        return nil
    }

    var stringValue: String? {
        if case .string(let text) = self { return text }
        return nil
    }

    var doubleValue: Double? {
        if case .number(let value) = self { return value }
        return nil
    }

    var swiftBoolValue: Bool? {
        if case .boolean(let value) = self { return value }
        return nil
    }
}
