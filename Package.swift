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
      .package(url: "https://github.com/jpsim/Yams.git", from: "6.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FrontRange",
            dependencies: [
              "Yams",
            ],
        ),
        .testTarget(
            name: "FrontRangeTests",
            dependencies: ["FrontRange"]
        ),
    ]
)
