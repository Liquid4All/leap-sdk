// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

// The inference engine ships as its own top-level framework (its own binaryTarget), listed in every
// product that needs it, so SPM embeds and code-signs it with the consumer's identity on device
// (Xcode "Embed & Sign" never re-signs dylibs nested inside another framework). See
// Liquid4All/leap-android-sdk#281.
let releaseBase =
    "https://github.com/Liquid4All/leap-sdk/releases/download/v0.11.0-2-SNAPSHOT"

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
            checksum: "5d68e7059470c6a22ebabd149441f81f75387b72bc614948548b76bb6ea3f3ca"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "\(releaseBase)/LeapModelDownloader.xcframework.zip",
            checksum: "d29ea00aa112e4df64774a5fcb8b75fd4f66db5bee43e731b00be3f33f6074ec"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "\(releaseBase)/LeapOpenAIClient.xcframework.zip",
            checksum: "42c4dda5fa84280966ce204754dd8e8b30657391a71f1393fb4a8c037c785540"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "\(releaseBase)/LeapUi.xcframework.zip",
            checksum: "55adeff421ff0d5711381fec38534be13684410dccd3c5404152f4cb8afad3a6"
        ),
        // Inference-engine runtime, shipped as a sibling framework (see comment above).
        .binaryTarget(
            name: "inference_engine",
            url: "\(releaseBase)/inference_engine.xcframework.zip",
            checksum: "b37c71d586014dbc2526c2fe1e9217513719ac6763c3acbf1998c03273f9280d"
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
