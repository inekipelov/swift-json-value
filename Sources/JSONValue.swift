import Foundation

/// A minimal representation of a JSON-compatible value.
///
/// `JSONValue` preserves arbitrary JSON payloads with a small recursive enum that
/// can represent primitives, arrays, objects, and null.
public enum JSONValue: Sendable, Codable {
    case string(String)
    case integer(Int)
    case double(Double)
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

        if let integer = try? container.decode(Int.self) {
            self = .integer(integer)
            return
        }

        if let double = try? container.decode(Double.self) {
            self = .double(double)
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .integer(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

public extension DecodingError {
    static func unsupportedObject(in container: any SingleValueDecodingContainer) -> DecodingError {
        .dataCorruptedError(in: container, debugDescription: "Unsupported JSON object")
    }
}
