//
// MTLRenderCommandEncoder+Lily.swift
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
import Metal

extension MTLRenderCommandEncoder
{
    // MARK: - vertex buffer functions
    #if os(macOS) || (os(iOS) && !arch(x86_64))
    private func makeMetalBuffer<T>( from obj:T ) -> MTLBuffer? { return CAIMMetalAllocatedBuffer( T.self ).metalBuffer }
    #endif
    
    public func setVertexBuffer( _ buffer:MTLBuffer, index idx:Int ) {
        self.setVertexBuffer( buffer, offset: 0, index: idx )
    }
    public func setVertexBuffer<T:CAIMMetalBufferAllocatable>( _ obj:T, offset:Int=0, index idx:Int ) {
        self.setVertexBuffer( obj.metalBuffer, offset: offset, index: idx )
    }

    // MARK: - fragment buffer functions
    public func setFragmentBuffer( _ buffer:MTLBuffer, index idx:Int ) {
        self.setFragmentBuffer( buffer, offset: 0, index: idx )
    }
    public func setFragmentBuffer<T:CAIMMetalBufferAllocatable>( _ obj:T, offset:Int=0, index idx:Int ) {
        self.setFragmentBuffer( obj.metalBuffer, offset: offset, index: idx )
    }
    
    // MARK: - pipeline function
    public func use( _ pipeline:CAIMMetalRenderPipeline, _ drawFunc:( MTLRenderCommandEncoder )->() ) {
        // エンコーダにパイプラインを指定
        self.setRenderPipelineState( pipeline.state! )
        // 描画関数を実行
        drawFunc( self )
    }
    
    public func drawShape( _ shape:CAIMMetalDrawable, index idx:Int = 0 ) {
        shape.draw( with:self, index:idx )
    }
    
    public func setDepthStencilDescriptor( _ desc:MTLDepthStencilDescriptor ) {
        let depth_stencil_state = CAIMMetal.device?.makeDepthStencilState( descriptor: desc )
        self.setDepthStencilState( depth_stencil_state )
    }
}

#endif
