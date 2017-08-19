//
//  GLTFTypes.swift
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/18.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit

let attributeMap: [String: SCNGeometrySource.Semantic] = [
    "POSITION": SCNGeometrySource.Semantic.vertex,
    "NORMAL": SCNGeometrySource.Semantic.normal,
    "TANGENT": SCNGeometrySource.Semantic.tangent,
    "TEXCOORD_0": SCNGeometrySource.Semantic.texcoord,
    "TEXCOORD_1": SCNGeometrySource.Semantic.texcoord,
    "COLOR_0": SCNGeometrySource.Semantic.color,
    "JOINTS_0": SCNGeometrySource.Semantic.boneIndices,
    "WEIGHTS_0": SCNGeometrySource.Semantic.boneWeights
]

let GLTF_BYTE = Int(GL_BYTE)
let GLTF_UNSIGNED_BYTE = Int(GL_UNSIGNED_BYTE)
let GLTF_SHORT = Int(GL_SHORT)
let GLTF_UNSIGNED_SHORT = Int(GL_UNSIGNED_SHORT)
let GLTF_UNSIGNED_INT = Int(GL_UNSIGNED_INT)
let GLTF_FLOAT = Int(GL_FLOAT)

let GLTF_ARRAY_BUFFER = Int(GL_ARRAY_BUFFER)
let GLTF_ELEMENT_ARRAY_BUFFER = Int(GL_ELEMENT_ARRAY_BUFFER)

let GLTF_POINTS = Int(GL_POINTS)
let GLTF_LINES = Int(GL_LINES)
let GLTF_LINE_LOOP = Int(GL_LINE_LOOP)
let GLTF_LINE_STRIP = Int(GL_LINE_STRIP)
let GLTF_TRIANGLES = Int(GL_TRIANGLES)
let GLTF_TRIANGLE_STRIP = Int(GL_TRIANGLE_STRIP)
let GLTF_TRIANGLE_FAN = Int(GL_TRIANGLE_FAN)

let usesFloatComponentsMap: [Int: Bool] = [
    GLTF_BYTE: false,
    GLTF_UNSIGNED_BYTE: false,
    GLTF_SHORT: false,
    GLTF_UNSIGNED_SHORT: false,
    GLTF_UNSIGNED_INT: false,
    GLTF_FLOAT: true
]

let bytesPerComponentMap: [Int: Int] = [
    GLTF_BYTE: 1,
    GLTF_UNSIGNED_BYTE: 1,
    GLTF_SHORT: 2,
    GLTF_UNSIGNED_SHORT: 2,
    GLTF_UNSIGNED_INT: 4,
    GLTF_FLOAT: 4
]

let componentsPerVectorMap: [String: Int] = [
    "SCALAR": 1,
    "VEC2": 2,
    "VEC3": 3,
    "VEC4": 4,
    "MAT2": 4,
    "MAT3": 9,
    "MAT4": 16
]

// GLTF_LINE_LOOP, GLTF_LINE_STRIP, GLTF_TRIANGEL_FAN: need to convert
let primitiveTypeMap: [Int: SCNGeometryPrimitiveType] = [
    GLTF_POINTS: SCNGeometryPrimitiveType.point,
    GLTF_LINES: SCNGeometryPrimitiveType.line,
    GLTF_TRIANGLES: SCNGeometryPrimitiveType.triangles,
    GLTF_TRIANGLE_STRIP: SCNGeometryPrimitiveType.triangleStrip
]

