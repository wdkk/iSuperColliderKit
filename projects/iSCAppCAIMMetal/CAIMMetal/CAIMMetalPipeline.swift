//
//  CAIMMetalPipeline.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/02/07.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

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
        let vertex_func:MTLFunction? = library!.newFunctionWithName(vsh.shader_name!)
        let fragment_func:MTLFunction? = library!.newFunctionWithName(fsh.shader_name!)
        
        let render_pipeline_desc:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        render_pipeline_desc.vertexFunction = vertex_func
        render_pipeline_desc.fragmentFunction = fragment_func
        
        let color_attachment:MTLRenderPipelineColorAttachmentDescriptor = render_pipeline_desc.colorAttachments[0]
        color_attachment.pixelFormat = .BGRA8Unorm
        // アルファブレンディングの設定
        color_attachment.blendingEnabled = true
        // 2値の加算方法
        color_attachment.rgbBlendOperation           = MTLBlendOperation.Add
        color_attachment.alphaBlendOperation         = MTLBlendOperation.Add
        // 入力データ = α
        color_attachment.sourceRGBBlendFactor        = MTLBlendFactor.SourceAlpha
        color_attachment.sourceAlphaBlendFactor      = MTLBlendFactor.SourceAlpha
        // 合成先データ = 1-α
        color_attachment.destinationRGBBlendFactor   = MTLBlendFactor.OneMinusSourceAlpha
        color_attachment.destinationAlphaBlendFactor = MTLBlendFactor.OneMinusSourceAlpha
        do
        {
            self.pipeline = try device.newRenderPipelineStateWithDescriptor(render_pipeline_desc)
        }
        catch
        {
            print("Failed to create pipeline state, error")
            return
        }
    }
}
