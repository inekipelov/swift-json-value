import XCTest
@testable import JSONValue

final class JSONValueTests: XCTestCase {
    private let decoder = JSONDecoder()

    func testDecodesString() throws {
        let value = try decode(#""hello""#)

        guard case let .string(string) = value else {
            return XCTFail("Expected string value")
        }

        XCTAssertEqual(string, "hello")
    }

    func testDecodesNumber() throws {
        let value = try decode("42")

        guard case let .number(number) = value else {
            return XCTFail("Expected number value")
        }

        XCTAssertEqual(number, 42)
    }

    func testDecodesBool() throws {
        let value = try decode("true")

        guard case let .bool(bool) = value else {
            return XCTFail("Expected bool value")
        }

        XCTAssertTrue(bool)
    }

    func testDecodesNull() throws {
        let value = try decode("null")

        guard case .null = value else {
            return XCTFail("Expected null value")
        }
    }

    func testDecodesArray() throws {
        let value = try decode(#"[1, "two", false]"#)

        guard case let .array(array) = value else {
            return XCTFail("Expected array value")
        }

        XCTAssertEqual(array.count, 3)
    }

    func testDecodesObject() throws {
        let value = try decode(#"{"name":"Ada","active":true}"#)

        guard case let .object(object) = value else {
            return XCTFail("Expected object value")
        }

        XCTAssertEqual(object.keys.sorted(), ["active", "name"])
    }

    func testDecodesNestedPayload() throws {
        let value = try decode(#"{"user":{"name":"Ada"},"items":[1,null,{"ok":false}]}"#)

        guard case let .object(object) = value else {
            return XCTFail("Expected object value")
        }

        guard case let .object(user)? = object["user"] else {
            return XCTFail("Expected nested user object")
        }

        guard case let .string(name)? = user["name"] else {
            return XCTFail("Expected nested name string")
        }

        XCTAssertEqual(name, "Ada")

        guard case let .array(items)? = object["items"] else {
            return XCTFail("Expected nested items array")
        }

        XCTAssertEqual(items.count, 3)
    }

    func testThrowsUnsupportedObjectErrorForUnsupportedSingleValue() {
        XCTAssertThrowsError(try JSONValue(from: UnsupportedDecoder())) { error in
            guard case let DecodingError.dataCorrupted(context) = error else {
                return XCTFail("Expected dataCorrupted error")
            }

            XCTAssertEqual(context.debugDescription, "Unsupported JSON object")
        }
    }

    private func decode(_ json: String) throws -> JSONValue {
        try decoder.decode(JSONValue.self, from: Data(json.utf8))
    }
}

private struct UnsupportedDecoder: Decoder {
    var codingPath: [CodingKey] { [] }
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
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
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
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
