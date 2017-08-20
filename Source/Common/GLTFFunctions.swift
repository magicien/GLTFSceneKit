//
//  GLTFFunctions.swift
//  GLTFSceneKit
//  Utility functions for internal use
//
//  Created by magicien on 2017/08/20.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit

func add(_ v0: SCNVector3, _ v1: SCNVector3) -> SCNVector3 {
    return SCNVector3(v0.x + v1.x, v0.y + v1.y, v0.z + v1.z)
}

func sub(_ v0: SCNVector3, _ v1: SCNVector3) -> SCNVector3 {
    return SCNVector3(v0.x - v1.x, v0.y - v1.y, v0.z - v1.z)
}

func mul(_ v: SCNVector3, _ n: CGFloat) -> SCNVector3 {
    return SCNVector3(v.x * n, v.y * n, v.z * n)
}

func div(_ v: SCNVector3, _ n: CGFloat) -> SCNVector3 {
    return mul(v, 1.0 / n)
}

func cross(_ v0: SCNVector3, _ v1: SCNVector3) -> SCNVector3 {
    return SCNVector3(v0.y * v1.z - v0.z * v1.y, v0.z * v1.x - v0.x * v1.z, v0.x * v1.y - v0.y * v1.x)
}

func length(_ v: SCNVector3) -> CGFloat {
    let l2 = v.x * v.x + v.y * v.y + v.z * v.z
    #if os(macOS)
        // CGFloat = Double
        return sqrt(l2)
    #else
        // CGFloat = Float
        return sqrtf(l2)
    #endif    
}

func normalize(_ v: SCNVector3) -> SCNVector3 {
    return mul(v, 1.0 / length(v))
}

func createNormal(_ v0: SCNVector3, _ v1: SCNVector3, _ v2: SCNVector3) -> SCNVector3 {
    let e1 = sub(v1, v0)
    let e2 = sub(v2, v0)
    let n = cross(e1, e2)
    
    return normalize(n)
}

func createVertexArray(from source: SCNGeometrySource) throws -> [SCNVector3] {
    if source.componentsPerVector != 3 {
        throw GLTFUnarchiveError.NotSupported("createVertexArray: only 3 component vector is supported: \(source.componentsPerVector)")
    }
    if !source.usesFloatComponents || source.bytesPerComponent != 4 {
        throw GLTFUnarchiveError.NotSupported("createVertexArray: only float source is supported")
    }
    
    let dummy = SCNVector3()
    var vertices = [SCNVector3](repeating: dummy, count: source.vectorCount)
    
    source.data.withUnsafeBytes { (p: UnsafePointer<Float32>) in
        var index = source.dataOffset / 4
        let step = source.dataStride / 4
        for i in 0..<source.vectorCount {
            let v0 = p[index + 0]
            let v1 = p[index + 1]
            let v2 = p[index + 2]
            index += step
            vertices[i] = SCNVector3(v0, v1, v2)
        }
    }
    return vertices
}

func createIndexArray(from element: SCNGeometryElement) -> [Int] {
    var indices = [Int](repeating: 0, count: element.primitiveCount)
    if element.bytesPerIndex == 2 {
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt16>) in
            var index = 0
            let step = 2
            for i in 0..<element.primitiveCount {
                indices[i] = Int(p[index])
                index += step
            }
        }
    } else if element.bytesPerIndex == 4 {
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt32>) in
            var index = 0
            let step = 4
            for i in 0..<element.primitiveCount {
                indices[i] = Int(p[index])
                index += step
            }
        }
    } else if element.bytesPerIndex == 8 {
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt64>) in
            var index = 0
            let step = 8
            for i in 0..<element.primitiveCount {
                indices[i] = Int(p[index])
                index += step
            }
        }
    }
    
    return indices
}

