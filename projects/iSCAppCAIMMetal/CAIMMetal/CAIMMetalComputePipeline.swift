//
//  CAIMMetalComputePipeline.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/02/07.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation
import Metal

class CAIMMetalComputePipeline
{
    var pipeline: MTLComputePipelineState!    // パイプライン
    weak var csh:CAIMMetalComputeShader!
    
    init(csh:CAIMMetalComputeShader!)
    {
        self.csh = csh
        
        let device:MTLDevice! = CAIMMetal.device
        let library:MTLLibrary? = device.newDefaultLibrary()
        let compute_func:MTLFunction? = library!.makeFunction(name: csh.shader_name!)
        
        do
        {
            self.pipeline = try device.makeComputePipelineState(function: compute_func!)
        }
        catch
        {
            print("Failed to create compute pipeline state, error")
            return
        }
    }
}
