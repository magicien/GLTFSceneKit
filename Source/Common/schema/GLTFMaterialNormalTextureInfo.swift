//
// GLTFMaterialNormalTextureInfo.swift
//
// Material Normal Texture Info
//

import Foundation

struct GLTFMaterialNormalTextureInfo : Codable {

  let index: GLTFGlTFid?

  let texCoord: Int?

  /** The scalar multiplier applied to each normal vector of the texture. This value scales the normal vector using the formula: `scaledNormal =  normalize((normalize(<sampled normal texture value>) * 2.0 - 1.0) * vec3(<normal scale>, <normal scale>, 1.0))`. This value is ignored if normalTexture is not specified. This value is linear. */
  let scale: Float = 1

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

