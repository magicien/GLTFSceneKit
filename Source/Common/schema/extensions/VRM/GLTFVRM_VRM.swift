//
// GLTFVRM_VRM.swift
//

import Foundation
import SceneKit

struct GLTFVRM_GLTFVRMExtension: GLTFCodable {
    struct GLTFVRM_VRM: Codable {
        let exportVersion: String?
        let meta: GLTFVRM_GLTFVRMMeta
        let humanoid: GLTFVRM_GLTFVRMHumanoid
        let firstPerson: GLTFVRM_GLTFVRMFirstperson
        let blendShapeMaster: GLTFVRM_GLTFVRMBlendShapeMaster
        let secondaryAnimation: GLTFVRM_GLTFVRMSecondaryAnimation
        let materialProperties: [GLTFVRM_GLTFVRMMaterialProperties]
    }
    
    struct GLTFVRM_GLTFVRMMeta: Codable {
        let title: String
        let version: String
        let author: String
        let contactInformation: String
        let reference: String
        let texture: GLTFGlTFid
        let allowedUserName: String
        let violentUssageName: String
        let sexualUssageName: String
        let commercialUssageName: String
        let otherPermissionUrl: String
        let licenseName: String
        let otherLicenseUrl: String
    }
    
    struct GLTFVRM_GLTFVRMHumanoid: Codable {
        let humanBones: [GLTFVRM_GLTFVRMHumanBone]
        let armStretch: Float
        let legStretch: Float
        let upperArmTwist: Float
        let lowerArmTwist: Float
        let upperLegTwist: Float
        let lowerLegTwist: Float
        let feetSpacing: Float
        let hasTranslationDoF: Bool
    }
    
    struct GLTFVRM_GLTFVRMHumanBone: Codable {
        let bone: String
        let node: GLTFGlTFid
        let useDefaultValues: Bool
    }
    
    struct GLTFVRM_GLTFVRMFirstperson: Codable {
        let firstPersonBone: Int
        let firstPersonBoneOffset: GLTFVRM_GLTFVRMVec3
        let meshAnnotations: [GLTFVRM_GLTFVRMMeshAnnotation]
        let lookAtTypeName: String
        let lookAtHorizontalInner: GLTFVRM_GLTFVRMDegreeMap
        let lookAtHorizontalOuter: GLTFVRM_GLTFVRMDegreeMap
        let lookAtVerticalDown: GLTFVRM_GLTFVRMDegreeMap
        let lookAtVerticalUp: GLTFVRM_GLTFVRMDegreeMap
    }
    
    struct GLTFVRM_GLTFVRMMeshAnnotation: Codable {
        let mesh: GLTFGlTFid
        let firstPersonFlag: String
    }
    
    struct GLTFVRM_GLTFVRMDegreeMap: Codable {
        let curve: [Float]?
        let xRange: Float
        let yRange: Float
    }
    
    struct GLTFVRM_GLTFVRMBlendShapeMaster: Codable {
        let blendShapeGroups: [GLTFVRM_GLTFVRMBlendShapeGroup]
    }
    
    struct GLTFVRM_GLTFVRMBlendShapeGroup: Codable {
        let name: String
        let presetName: String
        let binds: [GLTFVRM_GLTFVRMBind]
        let materialValues: [GLTFVRM_GLTFVRMMaterialValue]
    }
    
    struct GLTFVRM_GLTFVRMBind: Codable {
        let mesh: GLTFGlTFid
        let index: Int
        let weight: Float
    }
    
    struct GLTFVRM_GLTFVRMMaterialValue: Codable {
        
    }
    
    struct GLTFVRM_GLTFVRMSecondaryAnimation: Codable {
        let boneGroups: [GLTFVRM_GLTFVRMBoneGroup]
        let colliderGroups: [GLTFVRM_GLTFVRMColliderGroup]
    }
    
    struct GLTFVRM_GLTFVRMBoneGroup: Codable {
        let comment: String
        let stiffiness: Float
        let gravityPower: Float
        let gravityDir: GLTFVRM_GLTFVRMVec3
        let dragForce: Float
        let center: Float
        let hitRadius: Float
        let bones: [GLTFGlTFid]
        let colliderGroups: [GLTFGlTFid]
    }
    
    struct GLTFVRM_GLTFVRMColliderGroup: Codable {
        let node: GLTFGlTFid
        let colliders: [GLTFVRM_GLTFVRMCollider]
    }
    
    struct GLTFVRM_GLTFVRMCollider: Codable {
        let offset: GLTFVRM_GLTFVRMVec3
        let radius: Float
    }
    
    struct GLTFVRM_GLTFVRMMaterialProperties: Codable {
        let name: String
        let shader: String
        let renderQueue: Int
        let floatProperties: [String: Float]
        let keywordMap: [String: Bool]
        let tagMap: [String: String]
    }
    
    struct GLTFVRM_GLTFVRMVec3: Codable {
        let x: Float
        let y: Float
        let z: Float
    }
    
    let data: GLTFVRM_VRM?
    
    enum CodingKeys: String, CodingKey {
        case data = "VRM"
    }
    
    func didLoad(by object: Any, unarchiver: GLTFUnarchiver) {
        guard let data = self.data else { return }
        
        // TODO: Implement
    }
}


