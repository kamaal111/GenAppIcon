// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GALocales",
    defaultLocalization: "en",
    products: [
        .library(
            name: "GALocales",
            targets: ["GALocales"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GALocales",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "GALocalesTests",
            dependencies: ["GALocales"]),
    ]
)
