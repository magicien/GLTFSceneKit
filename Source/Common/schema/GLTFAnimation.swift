//
// GLTFAnimation.swift
//
// Animation
// A keyframe animation.
//

import Foundation

struct GLTFAnimation : Codable {

  /** An array of channels, each of which targets an animation's sampler at a node's property. Different channels of the same animation can't have equal targets. */
  let channels: [GLTFAnimationChannel]

  /** An array of samplers that combines input and output accessors with an interpolation algorithm to define a keyframe graph (but not its target). */
  let samplers: [GLTFAnimationSampler]

  let name: String?

  let extensions: GLTFExtension?

  let extras: GLTFExtras?
}

