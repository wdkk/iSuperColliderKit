//
// CAIMMetalComputePipeline.swift
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

public struct CAIMMetalComputeSetting
{
   public var computeShader:CAIMMetalShader?
}

open class CAIMMetalComputePipeline
{
    public private(set) var state:MTLComputePipelineState?
    
    public init() { }
    
    public func make( _ f:( inout CAIMMetalComputeSetting )->() ) {
        // 設定オブジェクトの作成
        var setting = CAIMMetalComputeSetting()
        f( &setting )
        self.makePipeline( function: setting.computeShader!.function! )
    }

    public func makePipeline( function f:MTLFunction ) {
        do {
            self.state = try CAIMMetal.device?.makeComputePipelineState( function: f )
        }
        catch {
            print( "Failed to create compute pipeline state, error" )
        }
    }
}

#endif
