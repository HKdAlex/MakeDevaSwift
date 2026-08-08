// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MakeDeva",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "MakeDevaCore",
            targets: ["MakeDevaCore"]
        ),
        .executable(
            name: "makedeva",
            targets: ["MakeDevaCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.8.0"),
        // Sibling checkout: ../BBText/... — or ../../BBText/... when nested under MakeDevaReserve/
        .package(path: "../../BBText/packages/bbtext-indic-sandhi"),
    ],
    targets: [
        .target(
            name: "MakeDevaCore",
            dependencies: [
                .product(name: "BBTextIndicSandhi", package: "bbtext-indic-sandhi"),
            ]
        ),
        .executableTarget(
            name: "MakeDevaCLI",
            dependencies: ["MakeDevaCore"]
        ),
        .testTarget(
            name: "MakeDevaCoreTests",
            dependencies: [
                "MakeDevaCore",
                "MakeDevaCLI",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
        // Heavy integration tests: full chapter files vs C golden output (~minutes).
        // Run locally or in CI with: swift test --filter MakeDevaParityTests
        .testTarget(
            name: "MakeDevaParityTests",
            dependencies: [
                "MakeDevaCore",
                "MakeDevaCLI",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
