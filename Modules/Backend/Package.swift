// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"]),
    ],
    dependencies: [
        .package(path: "../CDPersist")
    ],
    targets: [
        .target(
            name: "Backend",
            dependencies: [
                "CDPersist",
            ]),
        .testTarget(
            name: "BackendTests",
            dependencies: ["Backend"]),
    ]
)
