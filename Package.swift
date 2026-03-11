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
            targets: ["LeapUi"]
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
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0-SNAPSHOT/LeapSDK.xcframework.zip",
            checksum: "288ef56d0e0833b4d533748dc90093929976088876cc7cd4d24e30b840097050"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0-SNAPSHOT/LeapModelDownloader.xcframework.zip",
            checksum: "4db4f040208277c403284780687f1ba23fda4926c30966ec8f6bc07c9559d549"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0-SNAPSHOT/LeapOpenAIClient.xcframework.zip",
            checksum: "e42604c5bf94d1a6f1baaaeec2e4f7ac64c13c7c433f04d2938baccb4db496a7"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0-SNAPSHOT/LeapUi.xcframework.zip",
            checksum: "f08f8787463c601e1c2d100dc5fb0b461c8e0fed731139fec71085f8db2985d8"
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
