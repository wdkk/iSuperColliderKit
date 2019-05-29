//
// CAIMMetalViewProtocol.swift
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

import Foundation
import QuartzCore
import Metal

public protocol CAIMMetalViewProtocol
{
    func makeRenderPassDescriptor( drawable:CAMetalDrawable, color:CAIMColor, depthTexture depth_texture:MTLTexture ) -> MTLRenderPassDescriptor
    func makeDepthTextureDescriptor( drawable:CAMetalDrawable, depthState depth_state:CAIMMetalDepthState) -> MTLTextureDescriptor
}

public extension CAIMMetalViewProtocol
{
    func makeRenderPassDescriptor( drawable:CAMetalDrawable, color:CAIMColor, depthTexture depth_texture:MTLTexture ) -> MTLRenderPassDescriptor {
        let r_pass_desc:MTLRenderPassDescriptor = MTLRenderPassDescriptor()
        // カラーアタッチメントの設定
        r_pass_desc.colorAttachments[0].texture = drawable.texture
        r_pass_desc.colorAttachments[0].loadAction = (color != .clear) ? .clear : .load
        if( color != .clear ) { r_pass_desc.colorAttachments[0].clearColor = color.metalColor }
        r_pass_desc.colorAttachments[0].storeAction = .store

        // デプスの設定
        r_pass_desc.depthAttachment.texture = depth_texture
        r_pass_desc.depthAttachment.loadAction = .clear
        r_pass_desc.depthAttachment.storeAction = .dontCare
        r_pass_desc.depthAttachment.clearDepth = 1.0
        // ステンシルの設定
        r_pass_desc.stencilAttachment.texture = depth_texture
        r_pass_desc.stencilAttachment.loadAction = .clear
        r_pass_desc.stencilAttachment.storeAction = .dontCare
        r_pass_desc.stencilAttachment.clearStencil = 0
        
        return r_pass_desc
    }
    
    func makeDepthTextureDescriptor( drawable:CAMetalDrawable, depthState depth_state:CAIMMetalDepthState) -> MTLTextureDescriptor {
        // depthテクスチャの設定（デプスとステンシルを合わせもつテクスチャ）
        let depth_desc:MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: depth_state.depthFormat,
            width: drawable.texture.width,
            height: drawable.texture.height,
            mipmapped: false)
        depth_desc.textureType = (depth_state.sampleCount > 1) ? .type2DMultisample : .type2D
        depth_desc.sampleCount = depth_state.sampleCount
        depth_desc.usage = .renderTarget
        depth_desc.storageMode = .private                   // ADD: macOS
        depth_desc.resourceOptions = .storageModePrivate    // ADD: macOS
        return depth_desc
    }
}

#endif
