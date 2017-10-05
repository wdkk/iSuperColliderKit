//
// CAIMMetalRenderer.swift
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

class CAIMMetalRenderer
{
    private static weak var _current:CAIMMetalRenderer?
    public static var current:CAIMMetalRenderer? { return CAIMMetalRenderer._current }
    
    private weak var _metal_view:CAIMMetalView?
    private var _drawable:CAMetalDrawable?
    private var _render_pass_desc:MTLRenderPassDescriptor?
    private var _command_buffer:MTLCommandBuffer?
    
    private var _encoder:MTLRenderCommandEncoder?
    public var encoder:MTLRenderCommandEncoder? { return _encoder }
    
    private weak var _pipeline:CAIMMetalRenderPipeline?
    public var pipeline:CAIMMetalRenderPipeline? { return _pipeline }
    
    public var culling:MTLCullMode = .none
    
    private var _bg_color:MTLClearColor? = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public var bg_color:CAIMColor? {
        get { return _bg_color != nil ? CAIMColor(R: Float(_bg_color!.red),
                                                  G: Float(_bg_color!.green),
                                                  B: Float(_bg_color!.blue),
                                                  A: Float(_bg_color!.alpha)) : nil }
        set {
            if(newValue == nil) { _bg_color = nil; return }
            _bg_color = MTLClearColor(red: Double(newValue!.R), green: Double(newValue!.G), blue: Double(newValue!.B), alpha: Double(newValue!.A))
        }
    }
    
    // Metal描画のセッティング
    @discardableResult
    func ready(view:CAIMMetalView) -> Bool {
        _metal_view = view
        if(_metal_view == nil) { print("CAIMMetalView is nil."); return false }
        _drawable = view.metal_layer?.nextDrawable()
        if(_drawable == nil) { print("cannot get Metal drawable."); return false }
        
        // カレントの設定
        CAIMMetalRenderer._current = self
        
        // レンダーパスの属性（コマンドエンコーダの生成に必要）
        _render_pass_desc = MTLRenderPassDescriptor()
        _render_pass_desc?.colorAttachments[0].texture = _drawable!.texture
        _render_pass_desc?.colorAttachments[0].loadAction = self._bg_color != nil ? .clear : .load
        if(self._bg_color != nil) { _render_pass_desc?.colorAttachments[0].clearColor = self._bg_color! }
        _render_pass_desc?.colorAttachments[0].storeAction = .store
        
        // 描画コマンドエンコーダの入力
        _command_buffer = CAIMMetal.command_queue.makeCommandBuffer()
        _encoder = _command_buffer?.makeRenderCommandEncoder(descriptor: _render_pass_desc!)
        
        return true
    }
    
    // 描画結果の確定（画面へ反映)
    func commit() {
        // カリングの設定
        _encoder?.setFrontFacing(.counterClockwise)
        _encoder?.setCullMode(self.culling)
        
        // コマンドエンコーダの完了
        _encoder?.endEncoding()
        // コマンドバッファの確定
        _command_buffer?.present(_drawable!)
        _command_buffer?.commit()
        // コマンドバッファ解放
        _command_buffer = nil
    }
    
    // 使用するパイプラインの設定
    func use(_ pipeline:CAIMMetalRenderPipeline?) {
        self.encoder?.setRenderPipelineState(pipeline!.mtl_pipeline!)
        self._pipeline = pipeline
    }
    
    func link(_ buffer:CAIMMetalBufferBase, to type:CAIMMetalShaderType, at idx:Int) {
        switch(type) {
        case .vertex:
            self.encoder?.setVertexBuffer(buffer.mtlbuf, offset: 0, index: idx)
        case .fragment:
            self.encoder?.setFragmentBuffer(buffer.mtlbuf, offset: 0, index: idx)
        default:
            break
        }
    }
    
    func linkVertexBuffer(_ idx:Int, _ buffer:CAIMMetalBufferBase) {
        self.encoder?.setVertexBuffer(buffer.mtlbuf, offset: 0, index: idx)
    }
    
    func linkFragmentBuffer(_ idx:Int, _ buffer:CAIMMetalBufferBase) {
        self.encoder?.setFragmentBuffer(buffer.mtlbuf, offset: 0, index: idx)
    }
    
    func draw<T>(_ shape:CAIMShape<T>) {
        shape.draw(self)
    }
}

