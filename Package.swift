// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DBCNetworking",
    platforms: [.iOS(.v13), .macCatalyst(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "DBCNetworking", targets: ["DBCNetworking"]),
        .executable(name: "http-tool", targets: ["HTTPTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DBCNetworking",
            dependencies: []
        ),
        .testTarget(
            name: "DBCNetworkingTests",
            dependencies: ["DBCNetworking"],
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "HTTPTool",
            dependencies: [
                "DBCNetworking",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
