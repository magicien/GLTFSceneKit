//
// GLTFSkin.swift
//
// Skin
// Joints and matrices defining a skin.
//

import Foundation

struct GLTFSkin : Codable {

  /** The index of the accessor containing the floating-point 4x4 inverse-bind matrices.  The default is that each matrix is a 4x4 identity matrix, which implies that inverse-bind matrices were pre-applied. */
  let inverseBindMatrices: GLTFGlTFid?

  /** The index of the node used as a skeleton root. When undefined, joints transforms resolve to scene root. */
  let skeleton: GLTFGlTFid?

  /** Indices of skeleton nodes, used as joints in this skin.  The array length must be the same as the `count` property of the `inverseBindMatrices` accessor (when defined). */
  let joints: [GLTFGlTFid]

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

