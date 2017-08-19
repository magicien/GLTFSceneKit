//
// GLTFBuffer.swift
//
// Buffer
// A buffer points to binary geometry, animation, or skins.
//

import Foundation

struct GLTFBuffer: Codable {

  /** The uri of the buffer.  Relative paths are relative to the .gltf file.  Instead of referencing an external file, the uri can also be a data-uri. */
  let uri: String?

  /** The length of the buffer in bytes. */
  let byteLength: Int

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case uri
    case byteLength
    case name
    case extensions
    case extras
  }
}

