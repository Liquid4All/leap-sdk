// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "LeapSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "LeapSDK",
            targets: ["LeapSDK"]
        ),
        .library(
            name: "LeapModelDownloader",
            targets: ["LeapModelDownloader", "LeapSDK"]
        ),
        .library(
            name: "LeapOpenAIClient",
            targets: ["LeapOpenAIClient"]
        ),
        .library(
            name: "LeapUI",
            targets: ["LeapUi", "LeapSDK"]
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
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapSDK.xcframework.zip",
            checksum: "987d4f1b1941b9b523d6e18b17b4d7898b4b5c641fe08a65bc049c69e8348122"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapModelDownloader.xcframework.zip",
            checksum: "76c8a645ad4413abd8dfac30ae466145b97dd7e1dc1e189b05fe70ebe2356da4"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapOpenAIClient.xcframework.zip",
            checksum: "79bc5443a1cce6fcd4c49c91eeb85727034aaca10d3ef69582c061989c3d9b70"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapUi.xcframework.zip",
            checksum: "3403c989b8464f8b84b1a88b169667b13391f7408ce3fb2f0c9c4139db7ecdc1"
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
