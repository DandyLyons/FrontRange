// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FrontRange",
    platforms: [
      .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FrontRange",
            targets: ["FrontRange"],
        ),
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.3"), // CustomDump
      .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.14.1"), // Parsing
      .package(url: "https://github.com/jpsim/Yams.git", from: "6.1.0"), // Yams
    ],
    targets: [
        .target(
// A tool for parsing, mutating, serializing, and deserializing text documents with YAML front matter.
            name: "FrontRange",
            dependencies: [
              .product(name: "CustomDump", package: "swift-custom-dump"),
              .product(name: "Parsing", package: "swift-parsing"),
              "Yams",
            ],
        ),
        .testTarget(
            name: "FrontRangeTests",
            dependencies: [
              .product(name: "CustomDump", package: "swift-custom-dump"),
              "FrontRange",
            ]
        ),
    ]
)
