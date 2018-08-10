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
        let texture: Int
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
        let node: Int
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
        let mesh: Int
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
        let mesh: Int
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
        let bones: [Int]
        let colliderGroups: [Int]
    }
    
    struct GLTFVRM_GLTFVRMColliderGroup: Codable {
        let node: Int
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
        guard let scene = object as? SCNScene else { return }

        let meta = data.meta
        let dict: [String:Any] = [
            "title": meta.title,
            "author": meta.author,
            "contactInformation": meta.contactInformation,
            "reference": meta.reference,
            "texture": meta.texture,
            "version": meta.version,
            "allowedUserName": meta.allowedUserName,
            "violentUssageName": meta.violentUssageName,
            "sexualUssageName": meta.sexualUssageName,
            "commercialUssageName": meta.commercialUssageName,
            "otherPermissionUrl": meta.otherPermissionUrl,
            "licenseName": meta.licenseName,
            "otherLicenseUrl": meta.otherLicenseUrl
            ]
        scene.setValue(dict, forKey: "VRMMeta")
        
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


