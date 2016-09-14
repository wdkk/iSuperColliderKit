//
//  CAIMMetalRenderer.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/13.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class CAIMMetalRenderer
{
    private weak var view:CAIMMetalView?
    private var drawable:CAMetalDrawable?
    private var render_pass_desc:MTLRenderPassDescriptor!
    
    func ready(view:CAIMMetalView,
               clear:Bool=true,
               color:MTLClearColor=MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) -> Bool
    {
        self.view = view
        drawable = view.metal_layer.nextDrawable()
        if(drawable == nil) { print("cannot get Metal drawable."); return false }
        
        // レンダーパスの属性（コマンドエンコーダの生成に必要）
        render_pass_desc = MTLRenderPassDescriptor()
        render_pass_desc.colorAttachments[0].texture = drawable!.texture
        render_pass_desc.colorAttachments[0].clearColor = color
        render_pass_desc.colorAttachments[0].loadAction = clear ? .Clear : .Load
        render_pass_desc.colorAttachments[0].storeAction = .Store
        
        return true
    }
    
    func render(pl:CAIMMetalPipeline, draw:(MTLRenderCommandEncoder)->Void)
    {
        if(self.view == nil) { print("CAIMMetalView is nil."); return }
        if(drawable == nil)  { drawable = self.view!.metal_layer.nextDrawable() }
        if(drawable == nil)  { print("cannot get Metal drawable."); return }
        
        // 描画コマンドの入力
        let cmd_buf:MTLCommandBuffer = CAIMMetal.command_queue.commandBuffer()
        let cmd_enc:MTLRenderCommandEncoder = cmd_buf.renderCommandEncoderWithDescriptor(self.render_pass_desc)
        cmd_enc.setFrontFacingWinding(MTLWinding.CounterClockwise)
        cmd_enc.setCullMode(MTLCullMode.None)
        cmd_enc.setRenderPipelineState(pl.pipeline)

        // シェーダバッファのアタッチ
        pl.vsh.attach(cmd_enc)
        pl.fsh.attach(cmd_enc)
        
        // メッシュの描画
        draw(cmd_enc)
        
        cmd_enc.endEncoding()
        cmd_buf.presentDrawable(drawable!)
        cmd_buf.commit()
    }
}
