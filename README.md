# JSONValue

`JSONValue` is a Swift Package for encoding, decoding, and constructing
arbitrary JSON values without a fixed `Codable` model.

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?logo=swift&logoColor=white" alt="Swift 6.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/iOS-13.0+-000000?logo=apple" alt="iOS 13.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/macOS-10.15+-000000?logo=apple" alt="macOS 10.15+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/tvOS-13.0+-000000?logo=apple" alt="tvOS 13.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/watchOS-6.0+-000000?logo=apple" alt="watchOS 6.0+"></a>
  <a href="https://developer.apple.com/visionos/"><img src="https://img.shields.io/badge/visionOS-1.0+-000000?logo=apple" alt="visionOS 1.0+"></a>
</p>

## Usage

```swift
import Foundation
import JSONValue

let value: JSONValue = [
    "id": 42,
    "name": "Ada",
    "active": true,
    "rating": 4.5,
    "tags": ["swift", nil]
]

let data = try JSONEncoder().encode(value)
let decoded = try JSONDecoder().decode(JSONValue.self, from: data)
```

Supported literals: `String`, `Int`, `Double`, `Bool`, array, dictionary, and `nil`.

## Installation

```swift
.package(url: "https://github.com/inekipelov/swift-json-value.git", from: "1.0.0")
```