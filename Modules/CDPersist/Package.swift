// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CDPersist",
    products: [
        .library(
            name: "CDPersist",
            targets: ["CDPersist"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/ManuallyManagedObject.git", "2.0.0" ..< "3.0.0"),
        .package(url: "https://github.com/Kamaalio/ShrimpExtensions.git", "3.0.0" ..< "4.0.0")
    ],
    targets: [
        .target(
            name: "CDPersist",
            dependencies: [
                "ManuallyManagedObject",
                "ShrimpExtensions",
            ]),
        .testTarget(
            name: "CDPersistTests",
            dependencies: ["CDPersist"]),
    ]
)
