# JSONValue

`JSONValue` is a small Swift Package that wraps arbitrary JSON payloads in a
single recursive enum.

It is useful when you need to decode unknown or mixed JSON structures without
committing to a fixed `Codable` model upfront.

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?logo=swift&logoColor=white" alt="Swift 6.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/iOS-13.0+-000000?logo=apple" alt="iOS 13.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/macOS-10.15+-000000?logo=apple" alt="macOS 10.15+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/tvOS-13.0+-000000?logo=apple" alt="tvOS 13.0+"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/watchOS-6.0+-000000?logo=apple" alt="watchOS 6.0+"></a>
  <a href="https://developer.apple.com/visionos/"><img src="https://img.shields.io/badge/visionOS-1.0+-000000?logo=apple" alt="visionOS 1.0+"></a>
</p>

## Installation

Add the package to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/inekipelov/swift-json-value.git", from: "1.0.0")
```

Then add `JSONValue` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        "JSONValue"
    ]
)
```

## Usage

```swift
import Foundation
import JSONValue

let data = Data(
    """
    {
      "id": 42,
      "name": "Ada",
      "flags": [true, false, null],
      "profile": {
        "role": "admin"
      }
    }
    """.utf8
)

let value = try JSONDecoder().decode(JSONValue.self, from: data)

if case let .object(object) = value {
    if case let .number(id)? = object["id"] {
        print(id) // 42
    }

    if case let .array(flags)? = object["flags"] {
        print(flags.count) // 3
    }
}
```

This package extracts the generic JSON container used in TrackFinder into a
standalone SPM module so it can be reused independently from the application.
