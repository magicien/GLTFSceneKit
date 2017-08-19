//
// GLTFMesh.swift
//
// Mesh
// A set of primitives to be rendered.  A node can contain one mesh.  A node's transform places the mesh in the scene.
//

import Foundation

struct GLTFMesh: Codable {

  /** An array of primitives, each defining geometry to be rendered with a material. */
  let primitives: [GLTFMeshPrimitive]

  /** Array of weights to be applied to the Morph Targets. */
  let weights: [Float]?

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case primitives
    case weights
    case name
    case extensions
    case extras
  }
}

