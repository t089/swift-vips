// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-vips",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "VIPS", targets: ["VIPS"]),
    ],
    traits: [
        "FoundationSupport",
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
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
