//
//  GLTFShaderModifierFragment_VRMUnlitTexture_Cutoff.shader
//  GLTFSceneKit
//
//  Created magicien on 12/16/21.
//  Copyright © 2021 DarkHorse. All rights reserved.
//

#pragma arguments

float alphaCutOff;

#pragma body

if (_output.color.a < alphaCutOff) {
  discard_fragment();
}
_output.color = float4(_surface.diffuse.rgb, 1.0);
