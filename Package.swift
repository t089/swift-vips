// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-vips",
    platforms: [ .macOS(.v14)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "VIPS", targets: ["VIPS"]),
    ],
    traits: [
        "FoundationSupport",
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0")
    ],
    targets: [
        .systemLibrary(name: "Cvips",
                       pkgConfig: "vips"),
        .target(
            name: "CvipsShim",
            dependencies: [
                "Cvips"
            ]),
        .target(
            name: "VIPS",
            dependencies: [
                "Cvips",
                "CvipsShim",
                .product(name: "Logging", package: "swift-log")
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableExperimentalFeature("Lifetimes")
            ]),
        .executableTarget(name: "vips-tool",
            dependencies: ["VIPS", "Cvips"]
        ),
        .testTarget(
            name: "VIPSTests",
            dependencies: ["VIPS"],
            resources: [
                .copy("data")
            ]),
    ],
    swiftLanguageModes: [ .v6 ]
)
