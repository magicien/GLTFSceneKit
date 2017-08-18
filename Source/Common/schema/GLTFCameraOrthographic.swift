//
// GLTFCameraOrthographic.swift
//
// Camera Orthographic
// An orthographic camera containing properties to create an orthographic projection matrix.
//

import Foundation

struct GLTFCameraOrthographic : Codable {

  /** The floating-point horizontal magnification of the view. Must not be zero. */
  let xmag: Float

  /** The floating-point vertical magnification of the view. Must not be zero. */
  let ymag: Float

  /** The floating-point distance to the far clipping plane. `zfar` must be greater than `znear`. */
  let zfar: Float

  /** The floating-point distance to the near clipping plane. */
  let znear: Float

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

