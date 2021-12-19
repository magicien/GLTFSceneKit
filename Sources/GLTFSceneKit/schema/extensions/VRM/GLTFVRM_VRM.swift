//
// GLTFVRM_VRM.swift
//

import Foundation
import SceneKit

public let GLTFVRM_VRMNodeKey = "GLTFVRM_NodeKey"
var physicsSceneSettings: [String: GLTFVRM_VRMPhysicsSettings] = [:]
var physicsUpdatedAt: [String: TimeInterval] = [:]

struct GLTFVRM_GLTFVRMExtension: GLTFCodable {
    static let humanoidBonesKey = "VRMHumanoidBones"
    static let blendShapesKey = "VRMBlendShapes"
    static let metaKey = "VRMMeta"

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
        let title: String?
        let version: String?
        let author: String?
        let contactInformation: String?
        let reference: String?
        let texture: Int?
        let allowedUserName: String?
        let violentUssageName: String?
        let sexualUssageName: String?
        let commercialUssageName: String?
        let otherPermissionUrl: String?
        let licenseName: String?
        let otherLicenseUrl: String?
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
        let comment: String?
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
        
        // Load humanoid
        var humanoidBoneMap = [String: String]()
        data.humanoid.humanBones.forEach { humanBone in
            if let boneName = unarchiver.nodes[humanBone.node]?.name {
                humanoidBoneMap[humanBone.bone] = boneName
            }
        }
        scene.rootNode.setValue(humanoidBoneMap, forKey: GLTFVRM_GLTFVRMExtension.humanoidBonesKey)

        // Load materialProperties
        // TODO: Implement shaders
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

                let isAlphaCutoff: Bool
                let blendModeFloat = material.floatProperties["_BlendMode"]
                let blendMode = Int(blendModeFloat ?? 0)
                switch blendMode {
                case 1: // Cutout
                  orgMaterial.blendMode = .replace
                  isAlphaCutoff = true
                case 2: // Transparent
                  orgMaterial.blendMode = .alpha
                  isAlphaCutoff = false
                case 3: // TransparentWithZWrite
                  orgMaterial.blendMode = .alpha
                  isAlphaCutoff = false
                default: // Opaque (0)
                  orgMaterial.blendMode = .replace
                  isAlphaCutoff = false
                }

                let cullModeFloat = material.floatProperties["_CullMode"]
                let cullMode = Int(cullModeFloat ?? 0)
                switch cullMode {
                case 1: // Front
                  orgMaterial.cullMode = .front
                  orgMaterial.isDoubleSided = false
                case 2: // Back
                  orgMaterial.cullMode = .back
                  orgMaterial.isDoubleSided = false
                default: // Off (0)
                  orgMaterial.cullMode = .front
                  orgMaterial.isDoubleSided = true
                }

                let zWriteFloat = material.floatProperties["_ZWrite"]
                let zWrite = Int(zWriteFloat ?? 1)
                orgMaterial.writesToDepthBuffer = zWrite == 1

                if isAlphaCutoff {
                  orgMaterial.shaderModifiers = [
                    .fragment: try! String(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "GLTFShaderModifierFragment_VRMUnlitTexture_Cutoff", ofType: "shader")!), encoding: String.Encoding.utf8)
                  ]

                  let alphaCutOff = material.floatProperties["_Cutoff"] ?? 0
                  orgMaterial.setValue(alphaCutOff, forKey: "alphaCutOff")
                } else {
                  orgMaterial.shaderModifiers = [
                    .fragment: try! String(contentsOf: URL(fileURLWithPath: bundle.path(forResource: "GLTFShaderModifierFragment_VRMUnlitTexture", ofType: "shader")!), encoding: String.Encoding.utf8)
                  ]
                }
            }
        }

        // Load blendShapes
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
        scene.rootNode.setValue(blendShapes, forKey: GLTFVRM_GLTFVRMExtension.blendShapesKey)

        self.setupPhysics(for: scene, unarchiver: unarchiver)
    }
    
    func setMetadata(_ meta: GLTFVRM_GLTFVRMMeta, to scene: SCNScene) {
        let dict: [String:Any] = [
            "title": meta.title ?? "",
            "author": meta.author ?? "",
            "contactInformation": meta.contactInformation ?? "",
            "reference": meta.reference ?? "",
            "texture": meta.texture ?? 0,
            "version": meta.version ?? "",
            "allowedUserName": meta.allowedUserName ?? "",
            "violentUssageName": meta.violentUssageName ?? "",
            "sexualUssageName": meta.sexualUssageName ?? "",
            "commercialUssageName": meta.commercialUssageName ?? "",
            "otherPermissionUrl": meta.otherPermissionUrl ?? "",
            "licenseName": meta.licenseName ?? "",
            "otherLicenseUrl": meta.otherLicenseUrl ?? ""
        ]
        scene.setValue(dict, forKey: GLTFVRM_GLTFVRMExtension.metaKey)
    }

  func setupPhysics(for scene: SCNScene, unarchiver: GLTFUnarchiver) {
      guard let data = self.data else { return }

      var colliderGroups: [GLTFVRM_VRMSpringBoneColliderGroup] = []
      var springBones: [GLTFVRM_VRMSpringBone] = []

      data.secondaryAnimation.colliderGroups.forEach { colliderGroup in
        let nodeNo = colliderGroup.node
        guard let nodeName = unarchiver.nodes[nodeNo]?.name else { return }
        guard let colliderNode = scene.rootNode.childNode(withName: nodeName, recursively: true) else { return }

        let colliders: [GLTFVRM_VRMSphereCollider] = colliderGroup.colliders.map { collider in
          let offset = simd_float3(collider.offset.x, collider.offset.y, collider.offset.z)
          return GLTFVRM_VRMSphereCollider(offset: offset, radius: collider.radius)
        }

        let group = GLTFVRM_VRMSpringBoneColliderGroup(node: colliderNode, colliders: colliders)
        colliderGroups.append(group)
      }

      data.secondaryAnimation.boneGroups.forEach { boneGroup in
        var rootBones: [SCNNode] = []

        boneGroup.bones.forEach { boneNo in
          guard let boneName = unarchiver.nodes[boneNo]?.name else { return }
          guard let bone = scene.rootNode.childNode(withName: boneName, recursively: true) else { return }

          rootBones.append(bone)
        }

        let colliders = boneGroup.colliderGroups.map { colliderGroups[$0] }

        let springBone = GLTFVRM_VRMSpringBone(
          center: nil,
          rootBones: rootBones,
          comment: boneGroup.comment,
          stiffnessForce: boneGroup.stiffiness,
          gravityPower: boneGroup.gravityPower,
          gravityDir: simd_float3(boneGroup.gravityDir.x, boneGroup.gravityDir.y, boneGroup.gravityDir.z),
          dragForce: boneGroup.dragForce,
          hitRadius: boneGroup.hitRadius,
          colliderGroups: colliders
        )
        springBones.append(springBone)
      }

      let physics = GLTFVRM_VRMPhysicsSettings(colliderGroups: colliderGroups, springBones: springBones)
      let nodeId = UUID().uuidString
      scene.rootNode.setValue(nodeId, forKey: GLTFVRM_VRMNodeKey)
      physicsSceneSettings[nodeId] = physics
    }
}

extension SCNNode {
    // TODO: Blending some shapes which have the same keyPath
    public func setVRMBlendShape(name: String, weight: CGFloat) {
        guard let shapes = self.value(forKey: GLTFVRM_GLTFVRMExtension.blendShapesKey) as? [String : [String : CGFloat]] else { return }
        
        shapes[name]?.forEach { (keyPath, weightRatio) in
            self.setValue(weight * weightRatio, forKeyPath: keyPath)
        }
    }
    
    public func getVRMHumanoidBone(name: String) -> SCNNode? {
        guard let boneMap = self.value(forKey: GLTFVRM_GLTFVRMExtension.humanoidBonesKey) as? [String: String] else { return nil }
        guard let boneName = boneMap[name] else { return nil }
        
        return self.childNode(withName: boneName, recursively: true)
    }

    public func updateVRMSpringBones(time: TimeInterval) {
      self.enumerateHierarchy { node, _ in
        guard let nodeId = node.value(forKey: GLTFVRM_VRMNodeKey) as? String else { return }
        guard let settings = physicsSceneSettings[nodeId] else { return }

        var deltaTime: TimeInterval
        if let previousTime = physicsUpdatedAt[nodeId] {
          deltaTime = time - previousTime
        } else {
          deltaTime = 0
        }
        physicsUpdatedAt[nodeId] = time

        settings.springBones.forEach {
          $0.update(deltaTime: deltaTime, colliders: settings.colliderGroups)
        }
      }
    }
}
