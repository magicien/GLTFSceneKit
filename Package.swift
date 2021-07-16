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
                .process("Common/GLTFShaderModifierFragment_alphaCutoff.shader"),
                .process("Common/schema/extensions/KHR_materials_pbrSpecularGlossiness/GLTFShaderModifierSurface_pbrSpecularGlossiness_texture_doubleSidedWorkaround.shader"),
                .process("Common/schema/extensions/KHR_materials_pbrSpecularGlossiness/GLTFShaderModifierSurface_pbrSpecularGlossiness.shader"),
                .process("Common/GLTFShaderModifierSurface.shader"),
                .process("Common/GLTFShaderModifierSurface_doubleSidedWorkaround.shader"),
                .process("Common/schema/extensions/KHR_materials_pbrSpecularGlossiness/GLTFShaderModifierSurface_pbrSpecularGlossiness_doubleSidedWorkaround.shader"),
                .process("Common/GLTFShaderModifierSurface_alphaModeBlend.shader")
            ])
    ]
)



/*
let package = Package(
    name: "GLTFSceneKit",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GLTFSceneKit",
            targets: ["GLTFSceneKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GLTFSceneKit",
            dependencies: [])
    ]
)
*/