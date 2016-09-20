//
//  CAIMMetalPipeline.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/02/07.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation
import Metal

class CAIMMetalPipeline
{
    var pipeline: MTLRenderPipelineState!    // パイプライン
    private weak var _vsh:CAIMMetalVertexShader!
    private weak var _fsh:CAIMMetalFragmentShader!
  
    var vsh:CAIMMetalVertexShader { return _vsh }
    var fsh:CAIMMetalFragmentShader { return _fsh }
    
    init(vsh:CAIMMetalVertexShader!, fsh:CAIMMetalFragmentShader!)
    {
        self._vsh = vsh
        self._fsh = fsh
        
        let device:MTLDevice! = CAIMMetal.device
        let library:MTLLibrary? = device.newDefaultLibrary()
        let vertex_func:MTLFunction? = library!.makeFunction(name: vsh.shader_name!)
        let fragment_func:MTLFunction? = library!.makeFunction(name: fsh.shader_name!)
        
        let render_pipeline_desc:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        render_pipeline_desc.vertexFunction = vertex_func
        render_pipeline_desc.fragmentFunction = fragment_func
        
        let color_attachment:MTLRenderPipelineColorAttachmentDescriptor = render_pipeline_desc.colorAttachments[0]
        color_attachment.pixelFormat = .bgra8Unorm
        // アルファブレンディングの設定
        color_attachment.isBlendingEnabled = true
        // 2値の加算方法
        color_attachment.rgbBlendOperation           = MTLBlendOperation.add
        color_attachment.alphaBlendOperation         = MTLBlendOperation.add
        // 入力データ = α
        color_attachment.sourceRGBBlendFactor        = MTLBlendFactor.sourceAlpha
        color_attachment.sourceAlphaBlendFactor      = MTLBlendFactor.sourceAlpha
        // 合成先データ = 1-α
        color_attachment.destinationRGBBlendFactor   = MTLBlendFactor.oneMinusSourceAlpha
        color_attachment.destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        do
        {
            self.pipeline = try device.makeRenderPipelineState(descriptor: render_pipeline_desc)
        }
        catch
        {
            print("Failed to create pipeline state, error")
            return
        }
    }
}
