//
// GLTFMaterialOcclusionTextureInfo.swift
//
// Material Occlusion Texture Info
//

import Foundation

struct GLTFMaterialOcclusionTextureInfo : Codable {

  let index: GLTFGlTFid?

  let texCoord: Int?

  /** A scalar multiplier controlling the amount of occlusion applied. A value of 0.0 means no occlusion. A value of 1.0 means full occlusion. This value affects the resulting color using the formula: `occludedColor = lerp(color, color * <sampled occlusion texture value>, <occlusion strength>)`. This value is ignored if the corresponding texture is not specified. This value is linear. */
  let strength: Float = 1

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

