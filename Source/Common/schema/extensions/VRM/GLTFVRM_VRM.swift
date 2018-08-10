//
// GLTFVRM_VRM.swift
//

import Foundation
import SceneKit

public struct GLTFVRM_GLTFVRMExtension: GLTFCodable {
    public struct GLTFVRM_VRM: Codable {
        public let exportVersion: String?
        public let meta: GLTFVRM_GLTFVRMMeta
        public let humanoid: GLTFVRM_GLTFVRMHumanoid
        public let firstPerson: GLTFVRM_GLTFVRMFirstperson
        public let blendShapeMaster: GLTFVRM_GLTFVRMBlendShapeMaster
        public let secondaryAnimation: GLTFVRM_GLTFVRMSecondaryAnimation
        public let materialProperties: [GLTFVRM_GLTFVRMMaterialProperties]
    }
    
    public struct GLTFVRM_GLTFVRMMeta: Codable {
        public let title: String
        public let version: String
        public let author: String
        public let contactInformation: String
        public let reference: String
        public let texture: Int
        public let allowedUserName: String
        public let violentUssageName: String
        public let sexualUssageName: String
        public let commercialUssageName: String
        public let otherPermissionUrl: String
        public let licenseName: String
        public let otherLicenseUrl: String
    }
    
    public struct GLTFVRM_GLTFVRMHumanoid: Codable {
        public let humanBones: [GLTFVRM_GLTFVRMHumanBone]
        public let armStretch: Float
        public let legStretch: Float
        public let upperArmTwist: Float
        public let lowerArmTwist: Float
        public let upperLegTwist: Float
        public let lowerLegTwist: Float
        public let feetSpacing: Float
        public let hasTranslationDoF: Bool
    }
    
    public struct GLTFVRM_GLTFVRMHumanBone: Codable {
        public let bone: String
        public let node: Int
        public let useDefaultValues: Bool
    }
    
    public struct GLTFVRM_GLTFVRMFirstperson: Codable {
        public let firstPersonBone: Int
        public let firstPersonBoneOffset: GLTFVRM_GLTFVRMVec3
        public let meshAnnotations: [GLTFVRM_GLTFVRMMeshAnnotation]
        public let lookAtTypeName: String
        public let lookAtHorizontalInner: GLTFVRM_GLTFVRMDegreeMap
        public let lookAtHorizontalOuter: GLTFVRM_GLTFVRMDegreeMap
        public let lookAtVerticalDown: GLTFVRM_GLTFVRMDegreeMap
        public let lookAtVerticalUp: GLTFVRM_GLTFVRMDegreeMap
    }
    
    public struct GLTFVRM_GLTFVRMMeshAnnotation: Codable {
        public let mesh: Int
        public let firstPersonFlag: String
    }
    
    public struct GLTFVRM_GLTFVRMDegreeMap: Codable {
        public let curve: [Float]?
        public let xRange: Float
        public let yRange: Float
    }
    
    public struct GLTFVRM_GLTFVRMBlendShapeMaster: Codable {
        public let blendShapeGroups: [GLTFVRM_GLTFVRMBlendShapeGroup]
    }
    
    public struct GLTFVRM_GLTFVRMBlendShapeGroup: Codable {
        public let name: String
        public let presetName: String
        public let binds: [GLTFVRM_GLTFVRMBind]
        public let materialValues: [GLTFVRM_GLTFVRMMaterialValue]
    }
    
    public struct GLTFVRM_GLTFVRMBind: Codable {
        public let mesh: Int
        public let index: Int
        public let weight: Float
    }
    
    public struct GLTFVRM_GLTFVRMMaterialValue: Codable {
        
    }
    
    public struct GLTFVRM_GLTFVRMSecondaryAnimation: Codable {
        public let boneGroups: [GLTFVRM_GLTFVRMBoneGroup]
        public let colliderGroups: [GLTFVRM_GLTFVRMColliderGroup]
    }
    
    public struct GLTFVRM_GLTFVRMBoneGroup: Codable {
        public let comment: String
        public let stiffiness: Float
        public let gravityPower: Float
        public let gravityDir: GLTFVRM_GLTFVRMVec3
        public let dragForce: Float
        public let center: Float
        public let hitRadius: Float
        public let bones: [Int]
        public let colliderGroups: [Int]
    }
    
    public struct GLTFVRM_GLTFVRMColliderGroup: Codable {
        public let node: Int
        public let colliders: [GLTFVRM_GLTFVRMCollider]
    }
    
    public struct GLTFVRM_GLTFVRMCollider: Codable {
        public let offset: GLTFVRM_GLTFVRMVec3
        public let radius: Float
    }
    
    public struct GLTFVRM_GLTFVRMMaterialProperties: Codable {
        public let name: String
        public let shader: String
        public let renderQueue: Int
        public let floatProperties: [String: Float]
        public let keywordMap: [String: Bool]
        public let tagMap: [String: String]
    }
    
    public struct GLTFVRM_GLTFVRMVec3: Codable {
        public let x: Float
        public let y: Float
        public let z: Float
    }
    
    public let data: GLTFVRM_VRM?
    
    enum CodingKeys: String, CodingKey {
        case data = "VRM"
    }
    
    public func didLoad(by object: Any, unarchiver: GLTFUnarchiver) {
        guard let data = self.data else { return }
        guard let scene = object as? SCNScene else { return }
        
        // TODO: Implement
        data.materialProperties.forEach { material in
            let nodes = scene.rootNode.childNodes(passingTest: { node, finish in
                if node.geometry?.material(named: material.name) != nil {
                    return true
                }
                return false
            })
            print("material nodes count: \(nodes.count)")
            if nodes.count == 0 { return }
            
            guard let orgMaterial = nodes[0].geometry?.material(named: material.name) else { return }
            
            /*
            orgMaterial.shaderModifiers = [
                .surface: try! String(contentsOf: URL(fileURLWithPath: Bundle(for: GLTFUnarchiver.self).path(forResource: "GLTFShaderModifierSurface_pbrSpecularGlossiness_texture_doubleSidedWorkaround", ofType: "shader")!), encoding: String.Encoding.utf8)
            ]
            */
        }
    }
}


