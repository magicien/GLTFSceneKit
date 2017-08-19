//
// GLTFTextureInfo.swift
//
// Texture Info
// Reference to a texture.
//

import Foundation

struct GLTFTextureInfo: Codable {

  /** The index of the texture. */
  let index: GLTFGlTFid

  /** This integer value is used to construct a string in the format TEXCOORD_<set index> which is a reference to a key in mesh.primitives.attributes (e.g. A value of 0 corresponds to TEXCOORD_0). */
  let _texCoord: Int?
  var texCoord: Int {
    get { return self._texCoord ?? 0 }
  }

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case index
    case _texCoord = "texCoord"
    case extensions
    case extras
  }
}

