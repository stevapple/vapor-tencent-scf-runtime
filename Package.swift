// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vapor-tencent-scf-runtime",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "VaporTencentSCFRuntime",
            targets: ["VaporTencentSCFRuntime"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.13.0"),
        .package(url: "https://github.com/stevapple/swift-tencent-scf-runtime.git", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-extras/swift-extras-base64.git", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "VaporTencentSCFRuntime",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "TencentSCFRuntime", package: "swift-tencent-scf-runtime"),
                .product(name: "TencentSCFEvents", package: "swift-tencent-scf-runtime"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "ExtrasBase64", package: "swift-extras-base64"),
            ]
        ),
        .testTarget(
            name: "VaporTencentSCFRuntimeTests",
            dependencies: [
                .byName(name: "VaporTencentSCFRuntime"),
                .product(name: "TencentSCFTesting", package: "swift-tencent-scf-runtime"),
            ]
        ),
    ]
)
