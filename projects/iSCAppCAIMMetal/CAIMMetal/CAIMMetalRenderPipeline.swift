//
// CAIMMetalRenderPipeline.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//


import Foundation
import Metal

enum CAIMMetalBlendType : Int
{
    case none
    case alpha_blend
}

class CAIMMetalRenderPipeline
{
    // パイプライン
    private var _mtl_pipeline: MTLRenderPipelineState?
    var mtl_pipeline:MTLRenderPipelineState? { return _mtl_pipeline }
    // パイプラインディスクリプター
    fileprivate var _render_pipeline_desc:MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
    
    // 頂点シェーダー
    private var _internal_vsh:CAIMMetalShader?
    private weak var _vsh:CAIMMetalShader?
    var vshader:CAIMMetalShader? {
        get { return _vsh }
        set {
            _vsh = newValue
            _render_pipeline_desc.vertexFunction = _vsh!.function
            remake()
        }
    }
    // フラグメントシェーダー
    private var _internal_fsh:CAIMMetalShader?
    private weak var _fsh:CAIMMetalShader?
    var fshader:CAIMMetalShader? {
        get { return _fsh }
        set {
            _fsh = newValue
            _render_pipeline_desc.fragmentFunction = _fsh!.function
            remake()
        }
    }
    
    var blend_type:CAIMMetalBlendType = .none {
        didSet {
            setBlendMode(blend_type)
            remake()
        }
    }
    
    // 外部からシェーダを指定する
    init(vertex vsh:CAIMMetalShader?, fragment fsh:CAIMMetalShader?, blend:CAIMMetalBlendType = .none) {
        setBlendMode(blend)
        
        self.vshader = vsh
        self.fshader = fsh
        
        _mtl_pipeline = self.makePipeline(_render_pipeline_desc)
    }
    
    // 内部にシェーダを持たせる
    init(vertname:String, fragname:String, blend:CAIMMetalBlendType = .none) {
        setBlendMode(blend)
        
        self._internal_vsh = CAIMMetalShader(vertname)
        self._internal_fsh = CAIMMetalShader(fragname)
        
        self.vshader = self._internal_vsh
        self.fshader = self._internal_fsh
        
        _mtl_pipeline = self.makePipeline(_render_pipeline_desc)
    }
    
    deinit {
        self._vsh = nil
        self._fsh = nil
        self._internal_vsh = nil
        self._internal_fsh = nil
    }

    private func setBlendMode(_ type:CAIMMetalBlendType) {
        let color_attachment:MTLRenderPipelineColorAttachmentDescriptor = _render_pipeline_desc.colorAttachments[0]
        color_attachment.pixelFormat = .bgra8Unorm
        
        switch(type) {
        case .none:
            color_attachment.isBlendingEnabled = false
            break
        case .alpha_blend:
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
        }
    }
    
    private func makePipeline(_ render_pipeline_desc:MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
        do {
           return try CAIMMetal.device.makeRenderPipelineState(descriptor: render_pipeline_desc)
        }
        catch {
            print("Failed to create pipeline state, error")
        }
        return nil
    }

    private func remake() {
        _mtl_pipeline = self.makePipeline(_render_pipeline_desc)
    }
}
