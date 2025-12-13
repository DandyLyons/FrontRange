// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FrontRange",
  platforms: [
    .macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16),
  ],
  products: [
    .library(
      name: "FrontRange",
      targets: ["FrontRange"],
    ),
    .executable(
      name: "fr",
      targets: ["FrontRangeCLI"]
    ),
    .executable(
      name: "frontrange-mcp",
      targets: ["FrontRangeMCP"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"), // ArgumentParser
    .package(url: "https://github.com/tuist/Command.git", from: "0.13.0"), // Command
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.3"), // CustomDump
    .package(url: "https://github.com/adam-fowler/jmespath.swift.git", from: "1.0.3"), // JMESPath
    .package(url: "https://github.com/modelcontextprotocol/swift-sdk", from: "0.7.1"), // ModelContextProtocol Swift SDK
    .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.14.1"), // Parsing
    .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"), // PathKit
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0"), // CSV parsing
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.1.0"), // Yams
  ],
  targets: [
    // MARK: FrontRange
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
      ],
      exclude: [
        "FrontRange.xctestplan",
      ],
    ),
    // MARK: FrontRangeCLI (fr)
    .executableTarget(
      name: "FrontRangeCLI",
      dependencies: [
        "FrontRange",
        .product(name: "ArgumentParser", package: "swift-argument-parser"), // CLI argument parsing
        .product(name: "JMESPath", package: "jmespath.swift"), // JMESPath query support
        .product(name: "PathKit", package: "PathKit"), // For file path handling
        .product(name: "SwiftCSV", package: "SwiftCSV"), // CSV parsing
      ],
    ),
    .testTarget(
      name: "FrontRangeCLITests",
      dependencies: [
        .product(name: "Command", package: "command"), // Programmatic CLI testing
        .target(name: "FrontRangeCLI"),
      ],
      exclude: [
        "FrontRangeCLICore.xctestplan",
      ],
      resources: [
        .copy("../../ExampleFiles"),
      ],
    ),
    
    // MARK: FrontRangeMCP
    .executableTarget(
      name: "FrontRangeMCP",
      dependencies: [
        "FrontRange",
        .product(name: "MCP", package: "swift-sdk"),
      ],
    ),
    .testTarget(
      name: "FrontRangeMCPTests",
      dependencies: [
        .target(name: "FrontRangeMCP"),
      ],
      resources: [
        .copy("../../ExampleFiles"),
      ]
    ),
  ]
)
