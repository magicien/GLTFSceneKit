// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GLTFSceneKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v11)
    ],
    products: [
        .library(name: "GLTFSceneKit", targets: ["GLTFSceneKit"]),
    ],
    targets: [
        .target(
            name: "GLTFSceneKit",
            path: "Sources",
            resources: [
                .copy("Resources"),
            ])
    ]
)
