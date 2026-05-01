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
            checksum: "2b4a37fc626285aa2616599f295e354b58909f4805d3f9f68cc78fdbcfba468f"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapModelDownloader.xcframework.zip",
            checksum: "9ccd69192784e973c6e237794eb58aa89beb0a638de24c8aefc942ee13a6d7c5"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapOpenAIClient.xcframework.zip",
            checksum: "cc2471507c9fbac0de05681c6ba5a615eed3053c3d0bc3d0e03c31a41b786e1c"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.3-SNAPSHOT/LeapUi.xcframework.zip",
            checksum: "f0af7659dcf92fa4b0284b055da69e03e5e17c509fb60e0b2ab3e2af9be4163c"
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
