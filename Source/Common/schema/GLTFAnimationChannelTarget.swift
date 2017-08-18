//
// GLTFAnimationChannelTarget.swift
//
// Animation Channel Target
// The index of the node and TRS property that an animation channel targets.
//

import Foundation

struct GLTFAnimationChannelTarget : Codable {

  /** The index of the node to target. */
  let node: GLTFGlTFid?

  /** The name of the node's TRS property to modify, or the "weights" of the Morph Targets it instantiates. */
  let path: String

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

