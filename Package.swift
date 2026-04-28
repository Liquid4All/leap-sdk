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
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0/LeapSDK.xcframework.zip",
            checksum: "8337c5056ed5285f6b6bee198b6c81757c608243ac2d6be5fa1084b6407016ae"
        ),
        .binaryTarget(
            name: "LeapModelDownloader",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0/LeapModelDownloader.xcframework.zip",
            checksum: "0c7242e4c91433fc53822d06387d5e77f8891388113200028917e2eac45e36c3"
        ),
        .binaryTarget(
            name: "LeapOpenAIClient",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0/LeapOpenAIClient.xcframework.zip",
            checksum: "4b8b641f5ce97818cbfa23b53bcfdd9361a44e3ae44146effcdabfc5ad6820a5"
        ),
        .binaryTarget(
            name: "LeapUi",
            url: "https://github.com/Liquid4All/leap-sdk/releases/download/v0.10.0/LeapUi.xcframework.zip",
            checksum: "9f709bbdf04390f5135c16d191b337c74479491b72783dcd89bfab5ff5afbd59"
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
