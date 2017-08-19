//
// GLTFScene.swift
//
// Scene
// The root nodes of a scene.
//

import Foundation

struct GLTFScene: Codable {

  /** The indices of each root node. */
  let nodes: [GLTFGlTFid]?

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case nodes
    case name
    case extensions
    case extras
  }
}

