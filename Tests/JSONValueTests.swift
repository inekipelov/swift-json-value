import Foundation
import Testing
@testable import JSONValue

struct JSONValueTests {
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
    }

    @Test(arguments: [
        (#""hello""#, JSONValue.string("hello")),
        ("42", JSONValue.integer(42)),
        ("3.14", JSONValue.double(3.14)),
        ("true", JSONValue.bool(true)),
        ("null", JSONValue.null),
    ])
    func decodesPrimitive(_ json: String, expected: JSONValue) throws {
        let value = try decode(json)

        #expect(matches(value, expected))
    }

    @Test
    func decodesArray() throws {
        let value = try decode(#"[1, "two", false, 2.5, null]"#)

        let array = try #require(arrayValue(from: value))
        #expect(matches(.array(array), .array([.integer(1), .string("two"), .bool(false), .double(2.5), .null])))
    }

    @Test
    func decodesObject() throws {
        let value = try decode(#"{"name":"Ada","active":true,"score":12}"#)

        let object = try #require(objectValue(from: value))
        #expect(matches(object["name"], .string("Ada")))
        #expect(matches(object["active"], .bool(true)))
        #expect(matches(object["score"], .integer(12)))
    }

    @Test
    func decodesNestedPayload() throws {
        let value = try decode(#"{"user":{"name":"Ada"},"items":[1,null,{"ok":false},{"weight":1.5}]}"#)

        let object = try #require(objectValue(from: value))
        let user = try #require(object["user"])
        let userObject = try #require(objectValue(from: user))
        #expect(matches(userObject["name"], .string("Ada")))

        let items = try #require(object["items"])
        let itemsArray = try #require(arrayValue(from: items))
        #expect(itemsArray.count == 4)
        #expect(matches(itemsArray[0], .integer(1)))
        #expect(matches(itemsArray[1], .null))
        #expect(matches(itemsArray[2], .object(["ok": .bool(false)])))
        #expect(matches(itemsArray[3], .object(["weight": .double(1.5)])))
    }

    @Test(arguments: [
        (JSONValue.string("hello"), #""hello""#),
        (JSONValue.integer(42), "42"),
        (JSONValue.double(3.14), "3.14"),
        (JSONValue.bool(true), "true"),
        (JSONValue.null, "null"),
        (JSONValue.array([.integer(1), .string("two")]), #"[1,"two"]"#),
        (JSONValue.object(["active": .bool(true), "name": .string("Ada")]), #"{"active":true,"name":"Ada"}"#),
    ])
    func encodesValue(_ value: JSONValue, expectedJSON: String) throws {
        let data = try encoder.encode(value)
        let encoded = try #require(String(data: data, encoding: .utf8))

        #expect(encoded == expectedJSON)
    }

    @Test(arguments: [
        JSONValue.string("hello"),
        JSONValue.integer(42),
        JSONValue.double(3.14),
        JSONValue.bool(false),
        JSONValue.null,
        JSONValue.array([.integer(1), .double(2.5), .null]),
        JSONValue.object(["meta": .object(["count": .integer(2)])]),
    ])
    func roundTripsThroughJSONCoder(_ original: JSONValue) throws {
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(JSONValue.self, from: data)

        #expect(matches(decoded, original))
    }

    @Test
    func supportsLiteralConstruction() {
        let string: JSONValue = "Ada"
        let integer: JSONValue = 42
        let double: JSONValue = 3.14
        let bool: JSONValue = true
        let array: JSONValue = [1, "two", false, nil]
        let object: JSONValue = ["name": "Ada", "age": 42, "verified": true, "nickname": nil]
        let null: JSONValue = nil

        #expect(matches(string, .string("Ada")))
        #expect(matches(integer, .integer(42)))
        #expect(matches(double, .double(3.14)))
        #expect(matches(bool, .bool(true)))
        #expect(matches(array, .array([.integer(1), .string("two"), .bool(false), .null])))
        #expect(matches(object, .object([
            "name": .string("Ada"),
            "age": .integer(42),
            "verified": .bool(true),
            "nickname": .null,
        ])))
        #expect(matches(null, .null))
    }

    @Test
    func supportsObjectSubscriptLookup() {
        let json: JSONValue = [
            "user": [
                "name": "Ada",
                "active": true,
            ],
            "age": 42,
        ]

        #expect(matches(json["age"], .integer(42)))
        #expect(matches(json["user"]?["name"], .string("Ada")))
        #expect(matches(json["user"]?["active"], .bool(true)))
        #expect(json["missing"] == nil)
    }

    @Test
    func supportsArraySubscriptLookup() {
        let json: JSONValue = [
            ["name": "Ada"],
            42,
            true,
        ]

        #expect(matches(json[0]?["name"], .string("Ada")))
        #expect(matches(json[1], .integer(42)))
        #expect(matches(json[2], .bool(true)))
        #expect(json[3] == nil)
    }

    @Test
    func supportsDynamicMemberLookup() {
        let json: JSONValue = [
            "user": [
                "profile": [
                    "name": "Ada"
                ],
                "active": true,
            ]
        ]

        #expect(matches(json.user?.profile?.name, .string("Ada")))
        #expect(matches(json.user?.active, .bool(true)))
        #expect(json.user?.missing == nil)
    }

    @Test
    func returnsNilForMismatchedLookupKinds() {
        let object: JSONValue = ["name": "Ada"]
        let array: JSONValue = [1, 2, 3]
        let scalar: JSONValue = 42

        #expect(object[0] == nil)
        #expect(array["name"] == nil)
        #expect(scalar["value"] == nil)
        #expect(scalar[0] == nil)
        #expect(scalar.value == nil)
    }

    @Test
    func throwsUnsupportedObjectErrorForUnsupportedSingleValue() {
        do {
            _ = try JSONValue(from: UnsupportedDecoder())
            Issue.record("Expected dataCorrupted error")
        } catch let error as DecodingError {
            guard case let .dataCorrupted(context) = error else {
                Issue.record("Expected dataCorrupted error")
                return
            }

            #expect(context.debugDescription == "Unsupported JSON object")
        } catch {
            Issue.record("Expected DecodingError, got \(String(describing: error))")
        }
    }

    private func decode(_ json: String) throws -> JSONValue {
        try decoder.decode(JSONValue.self, from: Data(json.utf8))
    }

    private func arrayValue(from value: JSONValue) -> [JSONValue]? {
        guard case let .array(array) = value else {
            return nil
        }

        return array
    }

    private func objectValue(from value: JSONValue) -> [String: JSONValue]? {
        guard case let .object(object) = value else {
            return nil
        }

        return object
    }

    private func matches(_ lhs: JSONValue?, _ rhs: JSONValue) -> Bool {
        guard let lhs else {
            return false
        }

        return matches(lhs, rhs)
    }

    private func matches(_ lhs: JSONValue, _ rhs: JSONValue) -> Bool {
        switch (lhs, rhs) {
        case let (.string(lhs), .string(rhs)):
            lhs == rhs
        case let (.integer(lhs), .integer(rhs)):
            lhs == rhs
        case let (.double(lhs), .double(rhs)):
            lhs == rhs
        case let (.bool(lhs), .bool(rhs)):
            lhs == rhs
        case let (.object(lhs), .object(rhs)):
            dictionaryMatches(lhs, rhs)
        case let (.array(lhs), .array(rhs)):
            arrayMatches(lhs, rhs)
        case (.null, .null):
            true
        default:
            false
        }
    }

    private func arrayMatches(_ lhs: [JSONValue], _ rhs: [JSONValue]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        return zip(lhs, rhs).allSatisfy(matches)
    }

    private func dictionaryMatches(_ lhs: [String: JSONValue], _ rhs: [String: JSONValue]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (key, lhsValue) in lhs {
            guard let rhsValue = rhs[key], matches(lhsValue, rhsValue) else {
                return false
            }
        }

        return true
    }
}

private struct UnsupportedDecoder: Decoder {
    var codingPath: [CodingKey] { [] }
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
        throw DecodingError.typeMismatch(
            [String: JSONValue].self,
            .init(codingPath: codingPath, debugDescription: "Unsupported keyed container")
        )
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        UnsupportedUnkeyedDecodingContainer()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        UnsupportedSingleValueDecodingContainer()
    }
}

private struct UnsupportedSingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] { [] }

    func decodeNil() -> Bool { false }
    func decode(_: Bool.Type) throws -> Bool { throw unsupported }
    func decode(_: String.Type) throws -> String { throw unsupported }
    func decode(_: Double.Type) throws -> Double { throw unsupported }
    func decode(_: Float.Type) throws -> Float { throw unsupported }
    func decode(_: Int.Type) throws -> Int { throw unsupported }
    func decode(_: Int8.Type) throws -> Int8 { throw unsupported }
    func decode(_: Int16.Type) throws -> Int16 { throw unsupported }
    func decode(_: Int32.Type) throws -> Int32 { throw unsupported }
    func decode(_: Int64.Type) throws -> Int64 { throw unsupported }
    func decode(_: UInt.Type) throws -> UInt { throw unsupported }
    func decode(_: UInt8.Type) throws -> UInt8 { throw unsupported }
    func decode(_: UInt16.Type) throws -> UInt16 { throw unsupported }
    func decode(_: UInt32.Type) throws -> UInt32 { throw unsupported }
    func decode(_: UInt64.Type) throws -> UInt64 { throw unsupported }

    func decode<T>(_: T.Type) throws -> T where T: Decodable {
        throw unsupported
    }

    private var unsupported: DecodingError {
        .typeMismatch(
            Never.self,
            .init(codingPath: codingPath, debugDescription: "Unsupported single value")
        )
    }
}

private struct UnsupportedUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] { [] }
    var count: Int? { 0 }
    var isAtEnd: Bool { true }
    var currentIndex: Int { 0 }

    mutating func decodeNil() throws -> Bool { false }
    mutating func decode(_: Bool.Type) throws -> Bool { throw unsupported }
    mutating func decode(_: String.Type) throws -> String { throw unsupported }
    mutating func decode(_: Double.Type) throws -> Double { throw unsupported }
    mutating func decode(_: Float.Type) throws -> Float { throw unsupported }
    mutating func decode(_: Int.Type) throws -> Int { throw unsupported }
    mutating func decode(_: Int8.Type) throws -> Int8 { throw unsupported }
    mutating func decode(_: Int16.Type) throws -> Int16 { throw unsupported }
    mutating func decode(_: Int32.Type) throws -> Int32 { throw unsupported }
    mutating func decode(_: Int64.Type) throws -> Int64 { throw unsupported }
    mutating func decode(_: UInt.Type) throws -> UInt { throw unsupported }
    mutating func decode(_: UInt8.Type) throws -> UInt8 { throw unsupported }
    mutating func decode(_: UInt16.Type) throws -> UInt16 { throw unsupported }
    mutating func decode(_: UInt32.Type) throws -> UInt32 { throw unsupported }
    mutating func decode(_: UInt64.Type) throws -> UInt64 { throw unsupported }
    mutating func decode<T>(_: T.Type) throws -> T where T: Decodable { throw unsupported }
    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        throw unsupported
    }
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer { throw unsupported }
    mutating func superDecoder() throws -> Decoder { throw unsupported }

    private var unsupported: DecodingError {
        .typeMismatch(
            Never.self,
            .init(codingPath: codingPath, debugDescription: "Unsupported unkeyed container")
        )
    }
}
