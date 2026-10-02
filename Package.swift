// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

// The inference engine ships as its own top-level framework (its own binaryTarget), listed in every
// product that needs it, so SPM embeds and code-signs it with the consumer's identity on device
// (Xcode "Embed & Sign" never re-signs dylibs nested inside another framework). See
// Liquid4All/leap-android-sdk#281.
let releaseBase =
    "https://github.com/Liquid4All/leap-sdk/releases/download/v0.11.0-SNAPSHOT"

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
            checksum: "f837346f81c73ac9f72e5cb115a9b4087a9155ae743cdc365b702361414343ac"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "\(releaseBase)/LeapModelDownloader.xcframework.zip",
            checksum: "8e08d69033f22615d49936ebd2cc9ee4bef9442d499cf54ff45243c9bbf29f24"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "\(releaseBase)/LeapOpenAIClient.xcframework.zip",
            checksum: "9f73ae6de8779e65e349e7668c6d15989eeb11622f8644dec7877577fa0a6a17"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "\(releaseBase)/LeapUi.xcframework.zip",
            checksum: "5455a094af42ffef21d452d130cfcd3c672205af5f483393c4198fa7b6661fa2"
        ),
        // Inference-engine runtime, shipped as a sibling framework (see comment above).
        .binaryTarget(
            name: "inference_engine",
            url: "\(releaseBase)/inference_engine.xcframework.zip",
            checksum: "bd8f4ca176afc87713f48d49e24301090882e8a10761b476ebcf8ee2cced2ba2"
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
