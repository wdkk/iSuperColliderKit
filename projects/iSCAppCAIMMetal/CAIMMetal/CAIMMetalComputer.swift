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

class CAIMMetalComputer
{    
    func compute(pl:CAIMMetalComputePipeline, thread_size:Size2)
    {
        // 適用可能のスレッド数の計算
        let wid:Int32 = thread_size.wid
        let hgt:Int32 = thread_size.hgt
        var th_wid:Int32 = 1
        var th_hgt:Int32 = 1
        for w:Int in 0 ..< 16
        {
            if(wid % (16-w) == 0) { th_wid = (16-w); break }
        }
        for h:Int in 0 ..< 16
        {
            if(hgt % (16-h) == 0) { th_hgt = (16-h); break }
        }
        
        let thread_num:MTLSize = MTLSize(width: Int(th_wid), height: Int(th_hgt), depth: 1)                 // スレッド数
        let thread_groups:MTLSize = MTLSize(width: Int(wid / th_wid), height: Int(hgt / th_hgt), depth: 1)  // スレッドグループ数
        
        // コマンドバッファの作成 → コンピュートコマンドエンコーダの生成(※コマンドバッファは再利用をサポートしてないので、この関数内で作成)
        let command_buffer:MTLCommandBuffer = CAIMMetal.command_queue.makeCommandBuffer()
        let comp_enc:MTLComputeCommandEncoder = command_buffer.makeComputeCommandEncoder()
        
        comp_enc.setComputePipelineState(pl.pipeline)

        pl.csh.attach(comp_enc)

        comp_enc.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: thread_num)
        comp_enc.endEncoding()
        command_buffer.commit()
        command_buffer.waitUntilCompleted()
    }
}
