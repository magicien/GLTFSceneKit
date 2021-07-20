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
    
    enum GLTFVRM_GLTFVRMShaderName: String {
        case unlitTexture = "VRM/UnlitTexture"
        case unlitCutout = "VRM/UnlitCutout"
        case unlitTransparent = "VRM/UnlitTransparent"
        case unlitTransparentZWrite = "VRM/UnlitTransparentZWrite"
        case mToon = "VRM/MToon"
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

        self.setMetadata(data.meta, to: scene)
        
        // FIXME: Can't handle a node name including "."
        scene.rootNode.childNodes(passingTest: { (node, _) in
            return node.name?.contains(".") ?? false
        }).forEach {
            $0.name = $0.name?.replacingOccurrences(of: ".", with: "_")
        }
        
        // TODO: Implement
        data.materialProperties.forEach { material in
            let nodes = scene.rootNode.childNodes(passingTest: { node, finish in
                if node.geometry?.material(named: material.name) != nil {
                    return true
                }
                return false
            })
            
            nodes.forEach { node in
                node.renderingOrder = material.renderQueue
                
                guard let orgMaterial = node.geometry?.material(named: material.name) else { return }
                orgMaterial.shaderModifiers = [
                    .fragment: try! String(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "GLTFShaderModifierFragment_VRMUnlitTexture", ofType: "shader")!), encoding: String.Encoding.utf8)
                ]
                
                orgMaterial.blendMode = .alpha
            }
        }
        
        // shapeName (presetName/name) => keyPath => weight
        var blendShapes: [String: [String: CGFloat]] = [:]
        data.blendShapeMaster.blendShapeGroups.forEach { blendShapeGroup in
            var morpherWeights = [String: CGFloat]()
            
            blendShapeGroup.binds.forEach { bind in
                guard bind.mesh < unarchiver.meshes.count else {
                    // Data count error
                    return
                }
                
                guard let meshNode = unarchiver.meshes[bind.mesh] else {
                    return
                }

                // TODO: Handle empty name and name conflicts
                guard let meshName = meshNode.name else {
                    return
                }
                                
                for i in 0..<meshNode.childNodes.count {
                    let keyPath = "/\(meshName).childNodes[\(i)].morpher.weights[\(bind.index)]"
                    morpherWeights[keyPath] = CGFloat(bind.weight / 100.0)
                }
            }
            
            var shapeName = blendShapeGroup.presetName
            if shapeName == "" {
                shapeName = blendShapeGroup.name
            }
            blendShapes[shapeName] = morpherWeights
        }
        scene.rootNode.setValue(blendShapes, forKey: "VRMBlendShapes")
    }
    
    func setMetadata(_ meta: GLTFVRM_GLTFVRMMeta, to scene: SCNScene) {
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
    }
}

extension SCNNode {
    // TODO: Blending some shapes which have the same keyPath
    public func setVRMBlendShape(name: String, weight: CGFloat) {
        guard let shapes = self.value(forKey: "VRMBlendShapes") as? [String : [String : CGFloat]] else { return }
        
        shapes[name]?.forEach { (keyPath, weightRatio) in
            self.setValue(weight * weightRatio, forKeyPath: keyPath)
        }
    }
}
