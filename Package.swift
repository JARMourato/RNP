// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RNP",
    platforms: [.iOS(.v13), .macOS(.v12), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(name: "RNP", targets: ["RNP"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "RNP", dependencies: [], path: "Sources"),
        .testTarget(name: "RNPTests", dependencies: ["RNP"], path: "Tests"),
    ]
)
