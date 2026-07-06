// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

// The inference-engine libraries ship as their own top-level frameworks (their own binaryTargets),
// listed in every product that needs the engine, so SPM embeds + code-signs each with the consumer's
// identity on device. This replaces the previous layout where they were dylibs nested inside
// LeapSDK.framework/Frameworks (Xcode "Embed & Sign" never re-signs nested dylibs, so device dyld
// rejected them). See Liquid4All/leap-android-sdk#281.
let releaseBase =
    "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.13-1-SNAPSHOT"

let package = Package(
    name: "LeapSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "LeapSDK",
            targets: ["LeapSDK", "inference_engine", "inference_engine_llamacpp_backend", "ie_zip"]
        ),
        .library(
            name: "LeapModelDownloader",
            targets: [
                "LeapModelDownloader", "inference_engine", "inference_engine_llamacpp_backend",
                "ie_zip",
            ]
        ),
        .library(
            name: "LeapOpenAIClient",
            targets: ["LeapOpenAIClient"]
        ),
        .library(
            name: "LeapUI",
            targets: [
                "LeapUi", "LeapSDK", "inference_engine", "inference_engine_llamacpp_backend",
                "ie_zip",
            ]
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
            checksum: "7e12f0654c2f6ca13edd3719eacb8643ff4fcd8a67ff36e4eda83c7db7b9ad1e"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "\(releaseBase)/LeapModelDownloader.xcframework.zip",
            checksum: "7379ddbb06b201db7cdfe69e68fdec6ff46ffefbe9fab0ee63adfac5f57911b1"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "\(releaseBase)/LeapOpenAIClient.xcframework.zip",
            checksum: "eab9ba0d11dc040075482d60d8fe8b418c1a028e4dfaedaf46ba07c6e54be349"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "\(releaseBase)/LeapUi.xcframework.zip",
            checksum: "0084b4956cf6eb9af3b0a6da71056051f20677c6afa8145b3aa46801ba40b2aa"
        ),
        // Inference-engine runtime, shipped as sibling frameworks (see comment above).
        .binaryTarget(
            name: "inference_engine",
            url: "\(releaseBase)/inference_engine.xcframework.zip",
            checksum: "8bdfdb1f3d45ea9e302ddfdb8366a1d87f6bd8cb34e72ea2094b6d64a680f9cc"
        ),
        .binaryTarget(
            name: "inference_engine_llamacpp_backend",
            url: "\(releaseBase)/inference_engine_llamacpp_backend.xcframework.zip",
            checksum: "44210d0a3c237f362628b66d0369a0b38542df530332ae57c46714cfaa687028"
        ),
        .binaryTarget(
            name: "ie_zip",
            url: "\(releaseBase)/ie_zip.xcframework.zip",
            checksum: "685564c8be1bd9acc1e006385d43b8c8ddf907c1a7b4135d8b3effa6c087555e"
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
