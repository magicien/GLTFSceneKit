//
// GLTFMeshPrimitive.swift
//
// Mesh Primitive
// Geometry to be rendered with the given material.
//

import Foundation

struct GLTFMeshPrimitive : Codable {

  /** A dictionary object, where each key corresponds to mesh attribute semantic and each value is the index of the accessor containing attribute's data. */
  let attributes: [String:GLTFGlTFid]

  /** The index of the accessor that contains mesh indices.  When this is not defined, the primitives should be rendered without indices using `drawArrays()`.  When defined, the accessor must contain indices: the `bufferView` referenced by the accessor should have a `target` equal to 34963 (ELEMENT_ARRAY_BUFFER); `componentType` must be 5121 (UNSIGNED_BYTE), 5123 (UNSIGNED_SHORT) or 5125 (UNSIGNED_INT), the latter may require enabling additional hardware support; `type` must be `"SCALAR"`. For triangle primitives, the front face has a counter-clockwise (CCW) winding order. */
  let indices: GLTFGlTFid?

  /** The index of the material to apply to this primitive when rendering. */
  let material: GLTFGlTFid?

  /** The type of primitives to render. All valid values correspond to WebGL enums. */
  let mode: Int = 4

  /** An array of Morph Targets, each  Morph Target is a dictionary mapping attributes (only `POSITION`, `NORMAL`, and `TANGENT` supported) to their deviations in the Morph Target. */
  let targets: [[String:GLTFGlTFid]]?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

