//
// GLTFSampler.swift
//
// Sampler
// Texture sampler properties for filtering and wrapping modes.
//

import Foundation

struct GLTFSampler : Codable {

  /** Magnification filter.  Valid values correspond to WebGL enums: `9728` (NEAREST) and `9729` (LINEAR). */
  let magFilter: Int?

  /** Minification filter.  All valid values correspond to WebGL enums. */
  let minFilter: Int?

  /** s wrapping mode.  All valid values correspond to WebGL enums. */
  let wrapS: Int = 10497

  /** t wrapping mode.  All valid values correspond to WebGL enums. */
  let wrapT: Int = 10497

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

