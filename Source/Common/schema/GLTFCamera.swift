//
// GLTFCamera.swift
//
// Camera
// A camera's projection.  A node can reference a camera to apply a transform to place the camera in the scene.
//

import Foundation

struct GLTFCamera: Codable {

  /** An orthographic camera containing properties to create an orthographic projection matrix. */
  let orthographic: GLTFCameraOrthographic?

  /** A perspective camera containing properties to create a perspective projection matrix. */
  let perspective: GLTFCameraPerspective?

  /** Specifies if the camera uses a perspective or orthographic projection.  Based on this, either the camera's `perspective` or `orthographic` property will be defined. */
  let type: String

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?

  private enum CodingKeys: String, CodingKey {
    case orthographic
    case perspective
    case type
    case name
    case extensions
    case extras
  }
}

