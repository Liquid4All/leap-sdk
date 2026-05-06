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
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.4-SNAPSHOT/LeapSDK.xcframework.zip",
            checksum: "9108cd3b0ba57246b2c2056b57f11f251f9655b2f72f21807fca46556a7df8a6"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.4-SNAPSHOT/LeapModelDownloader.xcframework.zip",
            checksum: "29cde2c7eeb610b40eff4d5c63cc8ae3d270f284bd48e5496b01686d1f449b75"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.4-SNAPSHOT/LeapOpenAIClient.xcframework.zip",
            checksum: "a0d330163d003fdcaf0f6a458a77c52e16259bfb97d85fcdc206e7d1bc0fd0b3"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.4-SNAPSHOT/LeapUi.xcframework.zip",
            checksum: "67c108975c04af23814edd626884f1a0ac59d04bd57c320fa4948f9981bf2f8a"
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
