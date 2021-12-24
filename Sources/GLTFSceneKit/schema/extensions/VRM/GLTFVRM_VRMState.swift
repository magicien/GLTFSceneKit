//
//  GLTFVRM_VRMState.swift
//

import Foundation

class GLTFVRM_VRMState {
  static private let sceneSettingsQueue = DispatchQueue(label: "GLTFVRM_sceneSettingsQueue", attributes: .concurrent)
  static private let updatedAtQueue = DispatchQueue(label: "GLTFVRM_updatedAtQueue", attributes: .concurrent)
  static private var physicsSceneSettings: [String: GLTFVRM_VRMPhysicsSettings] = [:]
  static private var physicsUpdatedAt: [String: TimeInterval] = [:]

  static func getSceneSettings(key: String) -> GLTFVRM_VRMPhysicsSettings? {
    return self.sceneSettingsQueue.sync {
      return self.physicsSceneSettings[key]
    }
  }

  static func setSceneSettings(key: String, value: GLTFVRM_VRMPhysicsSettings) {
    self.sceneSettingsQueue.sync(flags: .barrier) {
      self.physicsSceneSettings[key] = value
    }
  }

  static func getUpdatedAt(key: String) -> TimeInterval? {
    return self.updatedAtQueue.sync {
      return self.physicsUpdatedAt[key]
    }
  }

  static func setUpdatedAt(key: String, value: TimeInterval) {
    self.updatedAtQueue.sync(flags: .barrier) {
      self.physicsUpdatedAt[key] = value
    }
  }
}
