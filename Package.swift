// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

// The inference engine ships as its own top-level framework (its own binaryTarget), listed in every
// product that needs it, so SPM embeds and code-signs it with the consumer's identity on device
// (Xcode "Embed & Sign" never re-signs dylibs nested inside another framework). See
// Liquid4All/leap-android-sdk#281.
let releaseBase =
    "https://github.com/Liquid4All/leap-sdk/releases/download/v0.11.0-4-SNAPSHOT"

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
            checksum: "3fd32171f3961d37d065aca3ab0cac682ade30f7bcef6df58bdf298308eeacad"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "\(releaseBase)/LeapModelDownloader.xcframework.zip",
            checksum: "1912b445720203475240600fc54ab9f0c8bf336ec5fefe3d7259e9f6a7220651"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "\(releaseBase)/LeapOpenAIClient.xcframework.zip",
            checksum: "662712723adbf4fbcf5a35f520f7f03aafaaf1953c2ea23ec0d294e0c93306d5"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "\(releaseBase)/LeapUi.xcframework.zip",
            checksum: "42d00d2949fcbf275dc8e374cd3b8cf1cf5d11b17ec7654e70a8cbac5dcff4fe"
        ),
        // Inference-engine runtime, shipped as a sibling framework (see comment above).
        .binaryTarget(
            name: "inference_engine",
            url: "\(releaseBase)/inference_engine.xcframework.zip",
            checksum: "ff3f676d2de7ac8f1c70e87ba167149b5f1ab6f697141dc39f2a96aef787b98f"
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
