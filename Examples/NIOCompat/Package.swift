// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NIOCompat",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../../"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.86.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "NIOCompat",
            dependencies: [
                .product(name: "VIPS", package: "swift-vips"),
                .product(name: "NIOCore", package: "swift-nio")
            ],
            resources: [
                .copy("../Resources/balloons.jpg")
            ]),
    ]
)
