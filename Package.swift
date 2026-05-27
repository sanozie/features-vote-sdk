// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeaturesVote",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FeaturesVote",
            targets: ["FeaturesVote"]
        ),
    ],
    targets: [
        .target(
            name: "FeaturesVote",
            dependencies: []
        ),
        .testTarget(
            name: "FeaturesVoteTests",
            dependencies: ["FeaturesVote"]
        ),
    ]
)
