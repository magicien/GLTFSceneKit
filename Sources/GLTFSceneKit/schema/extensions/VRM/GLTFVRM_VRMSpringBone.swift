//
// GLTFVRM_VRMSpringBone.swift
//

import SceneKit
import simd

struct GLTFVRM_VRMSphereCollider{
  let offset: SIMD3<Float>
  let radius: Float
}

struct GLTFVRM_VRMSpringBoneColliderGroup {
  let node: SCNNode
  let colliders: [GLTFVRM_VRMSphereCollider]
}

func getWorldScale(_ node: SCNNode) -> SCNVector3 {
  // Rotation is not considered
  if let parent = node.parent {
    let parentScale = getWorldScale(parent)
    return SCNVector3(parentScale.x * node.scale.x, parentScale.y * node.scale.y, parentScale.z * node.scale.z)
  }
  return node.scale
}

struct GLTFVRM_VRMPhysicsSettings {
  let colliderGroups: [GLTFVRM_VRMSpringBoneColliderGroup]
  let springBones: [GLTFVRM_VRMSpringBone]
}
var physicsSceneSettings: [String: GLTFVRM_VRMPhysicsSettings] = [:]
var physicsUpdatedAt: [String: TimeInterval] = [:]

public class GLTFVRM_VRMSpringBone {
  struct GLTFVRM_VRMSphereCollider {
    let position: SIMD3<Float>
    let radius: Float
  }

  static let colliderNodeName = "GLTFVRM_Collider"

  public let comment: String?
  public let stiffnessForce: Float
  public let gravityPower: Float
  public let gravityDir: SIMD3<Float>
  public let dragForce: Float
  public let hitRadius: Float

  public let center: SCNNode?
  public let rootBones: [SCNNode]

  private var initialLocalRotationMap: [SCNNode: simd_quatf] = [:]
  private let colliderGroups: [GLTFVRM_VRMSpringBoneColliderGroup]
  private var verlet: [GLTFVRM_VRMSpringBoneLogic] = []
  private var colliderList: [GLTFVRM_VRMSphereCollider] = []

  init(center: SCNNode?,
       rootBones: [SCNNode],
       comment: String? = nil,
       stiffnessForce: Float = 1.0,
       gravityPower: Float = 0.0,
       gravityDir: SIMD3<Float> = .init(0, -1, 0),
       dragForce: Float = 0.4,
       hitRadius: Float = 0.02,
       colliderGroups: [GLTFVRM_VRMSpringBoneColliderGroup] = []) {
    self.center = center
    self.rootBones = rootBones
    self.comment = comment
    self.stiffnessForce = stiffnessForce
    self.gravityPower = gravityPower
    self.gravityDir = gravityDir
    self.dragForce = dragForce
    self.hitRadius = hitRadius
    self.colliderGroups = colliderGroups

    self.setup()
  }

  private func setup() {
    for (node, orientation) in self.initialLocalRotationMap {
      node.simdOrientation = orientation
    }

    self.initialLocalRotationMap = [:]
    self.verlet = []

    for bone in self.rootBones {
      bone.enumerateHierarchy { x, _ in
        self.initialLocalRotationMap[x] = x.simdOrientation
      }
      self.setupRecursive(self.center, bone)
    }
  }

  private func setupRecursive(_ center: SCNNode?, _ parent: SCNNode) {
    if parent.childNodes.isEmpty {
      let parentWorldPos = simd_float3(parent.worldPosition)
      let grandParentWorldPos = simd_float3(parent.parent!.worldPosition)
      // let delta = parent.worldPosition - parent.parent!.worldPosition
      let delta = parentWorldPos - grandParentWorldPos
      // let childPosition = parent.worldPosition + delta.normalized() * 0.07
      let childPosition = parentWorldPos + simd.normalize(delta) * 0.07
      //let localChildPosV4 = parent.worldTransform.inverted().toSimd() * simd_float4(childPosition.toSimd(), 1)
      let localChildPosV4 = parent.simdWorldTransform.inverse * simd_float4(childPosition, 1)
      let localChildPos = simd_float3(
        localChildPosV4.x / localChildPosV4.w,
        localChildPosV4.y / localChildPosV4.w,
        localChildPosV4.z / localChildPosV4.w
      )

      let logic = GLTFVRM_VRMSpringBoneLogic(center: center, node: parent, localChildPosition: localChildPos)
      self.verlet.append(logic)
    } else {
      let firstChild = parent.childNodes.first!
      let localPosition = firstChild.simdPosition
      let logic = GLTFVRM_VRMSpringBoneLogic(center: center, node: parent, localChildPosition: localPosition)
      self.verlet.append(logic)
    }

    for child in parent.childNodes {
      self.setupRecursive(center, child)
    }
  }

  func update(deltaTime: TimeInterval, colliders: [GLTFVRM_VRMSpringBoneColliderGroup]) {
    if self.verlet.isEmpty {
      if self.rootBones.isEmpty {
        return
      }
      self.setup()
    }

    self.colliderList = []
    for group in colliders {
      for collider in group.colliders {
        self.colliderList.append(GLTFVRM_VRMSphereCollider(
          position: group.node.presentation.simdConvertPosition(collider.offset, to: nil),
          radius: collider.radius
        ))
      }
    }

    let stiffness = min(1, self.stiffnessForce * Float(deltaTime))
    let external = self.gravityDir * (self.gravityPower * Float(deltaTime))

    for verlet in self.verlet {
      verlet.radius = self.hitRadius
      verlet.update(
        center: self.center,
        stiffnessForce: stiffness,
        dragForce: self.dragForce,
        external: external,
        colliders: self.colliderList
      )
    }
  }

  func reset() {
    self.setup()
  }

  // MARK: - DEBUG

  func renderColliders(rootNode: SCNNode) {
    self.verlet.forEach {
      let color = $0.node.childNodes.isEmpty ? Color.green : Color.blue
      let worldPos = $0.currentTail
      let geometry = SCNSphere(radius: CGFloat($0.radius))
      geometry.firstMaterial?.diffuse.contents = color
      geometry.firstMaterial?.readsFromDepthBuffer = false
      geometry.firstMaterial?.writesToDepthBuffer = false
      geometry.firstMaterial?.fillMode = .lines
      geometry.firstMaterial?.lightingModel = .constant
      let node = SCNNode(geometry: geometry)
      node.name = GLTFVRM_VRMSpringBone.colliderNodeName
      node.simdPosition = worldPos
      node.renderingOrder = 1100

      rootNode.addChildNode(node)

      let line = self.createLine(from: $0.node.presentation.worldPosition, to: SCNVector3(worldPos))
      line.geometry?.firstMaterial?.diffuse.contents = color
      rootNode.addChildNode(line)
    }
  }

  func createLine(from p0: SCNVector3, to p1: SCNVector3) -> SCNNode {
    let indices: [Int32] = [0, 1]
    let source = SCNGeometrySource(vertices: [p0, p1])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    let geometry = SCNGeometry(sources: [source], elements: [element])
    geometry.firstMaterial?.diffuse.contents = Color.blue
    geometry.firstMaterial?.readsFromDepthBuffer = false
    geometry.firstMaterial?.writesToDepthBuffer = false
    geometry.firstMaterial?.fillMode = .lines
    geometry.firstMaterial?.lightingModel = .constant
    let node = SCNNode(geometry: geometry)
    node.name = GLTFVRM_VRMSpringBone.colliderNodeName
    node.renderingOrder = 1100

    return SCNNode(geometry: geometry)
  }
}

extension GLTFVRM_VRMSpringBone {
  class GLTFVRM_VRMSpringBoneLogic {
    let node: SCNNode
    private let length: Float
    private(set) var currentTail: SIMD3<Float>
    private var prevTail: SIMD3<Float>
    private let localRotation: simd_quatf
    private let boneAxis: SIMD3<Float>
    private var parentRotation: simd_quatf {
      self.node.parent?.presentation.simdWorldOrientation ?? simd_quatf(matrix_identity_float4x4)
    }

    var radius: Float = 0.5

    init(center: SCNNode?, node: SCNNode, localChildPosition: SIMD3<Float>) {
      self.node = node
      let worldChildPosition = node.simdConvertPosition(localChildPosition, to: nil)
      self.currentTail = center?.simdConvertPosition(worldChildPosition, from: nil) ?? worldChildPosition
      self.prevTail = self.currentTail
      self.localRotation = node.simdOrientation
      self.boneAxis = simd_normalize(localChildPosition)
      self.length = simd_length(localChildPosition) * Float(getWorldScale(node).x)
    }

    func update(center: SCNNode?, stiffnessForce: Float, dragForce: Float, external: SIMD3<Float>, colliders: [GLTFVRM_VRMSphereCollider]) {
      let currentTail: SIMD3<Float> = center?.simdConvertPosition(self.currentTail, to: nil) ?? self.currentTail
      let prevTail: SIMD3<Float> = center?.simdConvertPosition(self.prevTail, to: nil) ?? self.prevTail

      // Verlet integration
      let dx = (currentTail - prevTail) * max(1.0 - dragForce, 0)
      let dr = simd_act(simd_normalize(self.parentRotation * self.localRotation), self.boneAxis) * stiffnessForce
      var nextTail: SIMD3<Float> = currentTail + dx + dr + external

      nextTail = self.node.presentation.simdWorldPosition + simd_normalize(nextTail - self.node.presentation.simdWorldPosition) * self.length

      nextTail = self.collision(colliders, nextTail)

      self.prevTail = center?.simdConvertPosition(currentTail, from: nil) ?? currentTail
      self.currentTail = center?.simdConvertPosition(nextTail, from: nil) ?? nextTail

      self.node.simdOrientation = self.applyRotation(nextTail)
    }

    private func applyRotation(_ nextTail: SIMD3<Float>) -> simd_quatf {
      // Reset the rotation to simplify the calculation
      self.node.simdOrientation = self.localRotation
      let nextLocalPos = self.node.presentation.convertPosition(SCNVector3(nextTail), from: nil)
      let quat = simd_quatf(from: self.boneAxis, to: simd_normalize(simd_float3(nextLocalPos)))

      return simd_normalize(self.localRotation * quat)
    }

    private func collision(_ colliders: [GLTFVRM_VRMSphereCollider], _ nextTail: SIMD3<Float>) -> SIMD3<Float> {
      var nextTail = nextTail
      for collider in colliders {
        let r = self.radius + collider.radius
        if simd_length_squared(nextTail - collider.position) <= (r * r) {
          let normal = simd_normalize(nextTail - collider.position)
          let posFromCollider = collider.position + normal * (self.radius + collider.radius)
          nextTail = self.node.presentation.simdWorldPosition + simd_normalize(posFromCollider - self.node.presentation.simdWorldPosition) * self.length
        }
      }
      return nextTail
    }
  }
}
