//
// GLTFBufferView.swift
//
// Buffer View
// A view into a buffer generally representing a subset of the buffer.
//

import Foundation

struct GLTFBufferView: Codable {

  /** The index of the buffer. */
  let buffer: GLTFGlTFid

  /** The offset into the buffer in bytes. */
  let _byteOffset: Int?
  var byteOffset: Int {
    get { return self._byteOffset ?? 0 }
  }

  /** The length of the bufferView in bytes. */
  let byteLength: Int

  /** The stride, in bytes, between vertex attributes.  When this is not defined, data is tightly packed. When two or more accessors use the same bufferView, this field must be defined. */
  let byteStride: Int?

  /** The target that the GPU buffer should be bound to. */
  let target: Int?

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case buffer
    case _byteOffset = "byteOffset"
    case byteLength
    case byteStride
    case target
    case name
    case extensions
    case extras
  }
}

