import Foundation

/// A minimal representation of a JSON-compatible value.
///
/// `JSONValue` preserves arbitrary JSON payloads with a small recursive enum that
/// can represent primitives, arrays, objects, and null.
public enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
            return
        }

        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
            return
        }

        if let number = try? container.decode(Double.self) {
            self = .number(number)
            return
        }

        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }

        if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
            return
        }

        if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
            return
        }

        throw DecodingError.unsupportedObject(in: container)
    }
}

public extension DecodingError {
    static func unsupportedObject(in container: any SingleValueDecodingContainer) -> DecodingError {
        .dataCorruptedError(in: container, debugDescription: "Unsupported JSON object")
    }
}
