//
// GLTFTexture.swift
//
// Texture
// A texture and its sampler.
//

import Foundation

struct GLTFTexture: Codable {

  /** The index of the sampler used by this texture. When undefined, a sampler with repeat wrapping and auto filtering should be used. */
  let sampler: GLTFGlTFid?

  /** The index of the image used by this texture. */
  let source: GLTFGlTFid?

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case sampler
    case source
    case name
    case extensions
    case extras
  }
}

