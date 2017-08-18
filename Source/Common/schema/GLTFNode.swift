//
// GLTFNode.swift
//
// Node
// A node in the node hierarchy.  When the node contains `skin`, all `mesh.primitives` must contain `JOINTS_0` and `WEIGHTS_0` attributes.  A node can have either a `matrix` or any combination of `translation`/`rotation`/`scale` (TRS) properties. TRS properties are converted to matrices and postmultiplied in the `T * R * S` order to compose the transformation matrix; first the scale is applied to the vertices, then the rotation, and then the translation. If none are provided, the transform is the identity. When a node is targeted for animation (referenced by an animation.channel.target), only TRS properties may be present; `matrix` will not be present.
//

import Foundation

struct GLTFNode : Codable {

  /** The index of the camera referenced by this node. */
  let camera: GLTFGlTFid?

  /** The indices of this node's children. */
  let children: [GLTFGlTFid]?

  /** The index of the skin referenced by this node. */
  let skin: GLTFGlTFid?

  /** A floating-point 4x4 transformation matrix stored in column-major order. */
  let matrix: [Float] = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]

  /** The index of the mesh in this node. */
  let mesh: GLTFGlTFid?

  /** The node's unit quaternion rotation in the order (x, y, z, w), where w is the scalar. */
  let rotation: [Float] = [0,0,0,1]

  /** The node's non-uniform scale. */
  let scale: [Float] = [1,1,1]

  /** The node's translation. */
  let translation: [Float] = [0,0,0]

  /** The weights of the instantiated Morph Target. Number of elements must match number of Morph Targets of used mesh. */
  let weights: [Float]?

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

