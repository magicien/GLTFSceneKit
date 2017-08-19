//
// GLTFSampler.swift
//
// Sampler
// Texture sampler properties for filtering and wrapping modes.
//

import Foundation

struct GLTFSampler: Codable {

  /** Magnification filter.  Valid values correspond to WebGL enums: `9728` (NEAREST) and `9729` (LINEAR). */
  let magFilter: Int?

  /** Minification filter.  All valid values correspond to WebGL enums. */
  let minFilter: Int?

  /** s wrapping mode.  All valid values correspond to WebGL enums. */
  let _wrapS: Int?
  var wrapS: Int {
    get { return self._wrapS ?? 10497 }
  }

  /** t wrapping mode.  All valid values correspond to WebGL enums. */
  let _wrapT: Int?
  var wrapT: Int {
    get { return self._wrapT ?? 10497 }
  }

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case magFilter
    case minFilter
    case _wrapS = "wrapS"
    case _wrapT = "wrapT"
    case name
    case extensions
    case extras
  }
}

