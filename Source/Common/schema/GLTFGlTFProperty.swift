//
// GLTFGlTFProperty.swift
//
// glTF Property
//

import Foundation

struct GLTFGlTFProperty : Codable {

  /** Dictionary object with extension-specific objects. */
  let extensions: GLTFExtension?

  /** Application-specific data. */
  let extras: GLTFExtras?
}

