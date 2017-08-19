//
// GLTFMaterialOcclusionTextureInfo.swift
//
// Material Occlusion Texture Info
//

import Foundation

struct GLTFMaterialOcclusionTextureInfo: Codable {

  let index: GLTFGlTFid?

  let texCoord: Int?

  /** A scalar multiplier controlling the amount of occlusion applied. A value of 0.0 means no occlusion. A value of 1.0 means full occlusion. This value affects the resulting color using the formula: `occludedColor = lerp(color, color * <sampled occlusion texture value>, <occlusion strength>)`. This value is ignored if the corresponding texture is not specified. This value is linear. */
  let _strength: Float?
  var strength: Float {
    get { return self._strength ?? 1 }
  }

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case index
    case texCoord
    case _strength = "strength"
    case extensions
    case extras
  }
}

