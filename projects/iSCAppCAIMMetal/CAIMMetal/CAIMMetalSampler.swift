//
// CAIMMetalSampler.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Metal
import MetalKit

public class CAIMMetalSampler
{
    static public var `default` : MTLSamplerState {
        // descriptorを作ってそこからsamplerを生成
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter             = MTLSamplerMinMagFilter.nearest
        sampler.magFilter             = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter             = MTLSamplerMipFilter.nearest
        sampler.maxAnisotropy         = 1
        sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge   // width
        sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge   // height
        sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge   // depth
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp           = 0
        sampler.lodMaxClamp           = Float.greatestFiniteMagnitude
        
        return CAIMMetal.device!.makeSamplerState(descriptor: sampler)!
    }
}

#endif
