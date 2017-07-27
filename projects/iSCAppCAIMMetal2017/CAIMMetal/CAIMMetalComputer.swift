//
// CAIMMetalComputer.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import UIKit
import Metal
import QuartzCore

class CAIMMetalComputer
{    
    func compute(pl:CAIMMetalComputePipeline, thread_size:Size2) {
        // 適用可能のスレッド数の計算
        let wid:Int32 = thread_size.w
        let hgt:Int32 = thread_size.h
        var th_wid:Int32 = 1
        var th_hgt:Int32 = 1
        for w:Int32 in 0 ..< 16 {
            if(wid % (16-w) == 0) { th_wid = (16-w); break }
        }
        for h:Int32 in 0 ..< 16 {
            if(hgt % (16-h) == 0) { th_hgt = (16-h); break }
        }
        
        let thread_num:MTLSize = MTLSize(width: Int(th_wid), height: Int(th_hgt), depth: 1)                 // スレッド数
        let thread_groups:MTLSize = MTLSize(width: Int(wid / th_wid), height: Int(hgt / th_hgt), depth: 1)  // スレッドグループ数
        
        // コマンドバッファの作成 → コンピュートコマンドエンコーダの生成(※コマンドバッファは再利用をサポートしてないので、この関数内で作成)
        let command_buffer:MTLCommandBuffer = CAIMMetal.command_queue.makeCommandBuffer()
        let comp_enc:MTLComputeCommandEncoder = command_buffer.makeComputeCommandEncoder()
        
        comp_enc.setComputePipelineState(pl.pipeline!)

        //pl.csh?.attach(comp_enc)

        comp_enc.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: thread_num)
        comp_enc.endEncoding()
        command_buffer.commit()
        command_buffer.waitUntilCompleted()
    }
    
    /*
    func setBuffer(_ idx:Int, buffer:CAIMMetalBufferBase) {
        setVertexBuffer(buffer.mtlbuf, offset: 0, at: idx)
    }
    */
}
