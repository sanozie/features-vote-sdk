// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FeaturesVoteMacExample",
    platforms: [
        // Higher than the SDK's macOS 13 floor. macOS 14 is required for the two-parameter
        // `.onChange(of:) { _, new in }` used in ConfigurationView and for
        // `NSHostingController.sceneBridgingOptions`. The SDK itself still supports macOS 13+.
        .macOS(.v14)
    ],
    products: [
        .executable(name: "FeaturesVoteMacExample", targets: ["FeaturesVoteMacExample"])
    ],
    dependencies: [
        // Local path to the SDK at the repo root: this manifest lives at
        // TestApp/FeaturesVoteMacExample/, so `../..` resolves to the package root.
        // Mirrors how the iOS TestApp references the SDK locally, so the example always
        // builds against the in-repo SDK source rather than a published version.
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "FeaturesVoteMacExample",
            dependencies: [
                // NOTE: `package:` is the SDK's *directory* name ("features-vote-sdk"),
                // not its manifest name ("FeaturesVote").
                .product(name: "FeaturesVote", package: "features-vote-sdk")
            ],
            path: "Sources/FeaturesVoteMacExample"
        )
    ],
    // Swift 5 language mode avoids the stricter Swift 6 actor-isolation diagnostics
    // across the AppKit/SwiftUI boundary (same reason the invizzy reference app pins .v5).
    swiftLanguageVersions: [.v5]
)
