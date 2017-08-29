//
//  GLTFShaderModifierSurface.shader
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/29.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

#pragma arguments

float4 baseColorFactor;
float metallicFactor;
float roughnessFactor;

#pragma body

_surface.diffuse *= baseColorFactor;
_surface.metalness *= metallicFactor;
_surface.roughness *= roughnessFactor;
