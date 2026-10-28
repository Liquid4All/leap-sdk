// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

// The inference engine ships as its own top-level framework (its own binaryTarget), listed in every
// product that needs it, so SPM embeds and code-signs it with the consumer's identity on device
// (Xcode "Embed & Sign" never re-signs dylibs nested inside another framework). See
// Liquid4All/leap-android-sdk#281.
let releaseBase =
    "https://github.com/Liquid4All/leap-sdk/releases/download/v0.11.0-3-SNAPSHOT"

let package = Package(
    name: "LeapSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "LeapSDK",
            targets: ["LeapSDK", "inference_engine"]
        ),
        .library(
            name: "LeapModelDownloader",
            targets: ["LeapModelDownloader", "inference_engine"]
        ),
        .library(
            name: "LeapOpenAIClient",
            targets: ["LeapOpenAIClient"]
        ),
        .library(
            name: "LeapUI",
            targets: ["LeapUi", "LeapSDK", "inference_engine"]
        ),
        .library(
            name: "LeapSDKMacros",
            targets: ["LeapSDKMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "LeapSDK",
            url: "\(releaseBase)/LeapSDK.xcframework.zip",
            checksum: "474dd709693b719c45a3f9ce2737ae98299a1c9fb34474efe7850e379470e347"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "\(releaseBase)/LeapModelDownloader.xcframework.zip",
            checksum: "5d2cbe7b0e4100f83ae8e25fda34d10934bfc7dc4438eb019d628766d6e2d9c8"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "\(releaseBase)/LeapOpenAIClient.xcframework.zip",
            checksum: "b98e08fa2777ec77a832f37c911653d75bf580883eb5737069a9ebac85b6e448"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "\(releaseBase)/LeapUi.xcframework.zip",
            checksum: "d3e8198de0944abeff8fe279882ba7efda234b861093460086b804ae20ff2820"
        ),
        // Inference-engine runtime, shipped as a sibling framework (see comment above).
        .binaryTarget(
            name: "inference_engine",
            url: "\(releaseBase)/inference_engine.xcframework.zip",
            checksum: "f2400b6dd77c095af24ca91dd9923c4027a7b47d140ce279542765ff52e16f7e"
        ),
        .macro(
            name: "LeapSDKConstrainedGenerationPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "Sources/LeapSDKConstrainedGenerationPlugin"
        ),
        .target(
            name: "LeapSDKMacros",
            dependencies: [
                "LeapSDKConstrainedGenerationPlugin",
            ],
            path: "Sources/LeapSDKMacros"
        ),
    ]
)
