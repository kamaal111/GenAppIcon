// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppIconGenerator",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "AppIconGenerator",
            targets: ["AppIconGenerator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/ShrimpExtensions.git", "3.0.0" ..< "4.0.0")
    ],
    targets: [
        .target(
            name: "AppIconGenerator",
            dependencies: ["ShrimpExtensions"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "AppIconGeneratorTests",
            dependencies: ["AppIconGenerator"]),
    ]
)
