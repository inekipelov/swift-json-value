// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-json-value",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "JSONValue",
            targets: ["JSONValue"]
        ),
    ],
    targets: [
        .target(
            name: "JSONValue",
            path: "Sources",
            sources: ["JSONValue.swift"]
        ),
        .testTarget(
            name: "JSONValueTests",
            dependencies: ["JSONValue"],
            path: "Tests",
            sources: ["JSONValueTests.swift"]
        ),
    ]
)
