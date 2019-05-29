//
// CAIMMetalRenderPipeline.swift
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

public enum CAIMMetalBlendType : Int
{
    case none
    case alphaBlend
}

public struct CAIMMetalDepthState
{
    var sampleCount:Int = 1
    var depthFormat:MTLPixelFormat = .depth32Float_stencil8
}

public extension MTLRenderPipelineColorAttachmentDescriptor {
    func composite( type:CAIMMetalBlendType ) {
        switch( type ) {
        case .none:
            self.isBlendingEnabled = false
            break
        case .alphaBlend:
            self.isBlendingEnabled = true
            // 2値の加算方法
            self.rgbBlendOperation           = .add
            self.alphaBlendOperation         = .add
            // 入力データ = α
            self.sourceRGBBlendFactor        = .sourceAlpha
            self.sourceAlphaBlendFactor      = .sourceAlpha
            // 合成先データ = 1-α
            self.destinationRGBBlendFactor   = .oneMinusSourceAlpha
            self.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
    }
}

public struct CAIMMetalRenderSetting
{
    // 深度ステート
    public var depthState = CAIMMetalDepthState()
    // 頂点シェーダー
    public var vertexShader:CAIMMetalShader?
    // フラグメントシェーダー
    public var fragmentShader:CAIMMetalShader?
    // カラーアタッチメント
    public var colorAttachment = MTLRenderPipelineColorAttachmentDescriptor()
    // 頂点ディスクリプタ
    public var vertexDesc:MTLVertexDescriptor? = nil
    
    public init() {
        colorAttachment.pixelFormat = .bgra8Unorm
        colorAttachment.composite(type: .alphaBlend )
    }
}

// Metalパイプライン
public class CAIMMetalRenderPipeline
{
    // エンコーダー
    public private(set) var state:MTLRenderPipelineState?
    
    public init() { }
    
    // パイプラインの作成関数
    public func make( _ f:( inout CAIMMetalRenderSetting )->() ) {
        // 設定オブジェクトの作成
        var setting = CAIMMetalRenderSetting()
        // コールバックで設定を行う
        f( &setting )
        // 設定を用いてパイプライン記述を作成
        let rpd = makeRenderPipelineDesc( setting:setting )
        // パイプラインの作成
        self.makePipeline( rpd )
    }
    
    public func makeRenderPipelineDesc( setting:CAIMMetalRenderSetting ) -> MTLRenderPipelineDescriptor {
        // パイプラインディスクリプタの作成
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = setting.vertexShader!.function
        rpd.fragmentFunction = setting.fragmentShader!.function
        // パイプラインディスクリプタのデプス・ステンシル情報を設定
        rpd.vertexDescriptor = setting.vertexDesc
        rpd.sampleCount = setting.depthState.sampleCount
        rpd.depthAttachmentPixelFormat = setting.depthState.depthFormat
        rpd.stencilAttachmentPixelFormat = setting.depthState.depthFormat
        // 色設定
        rpd.colorAttachments[0] = setting.colorAttachment
        
        return rpd
    }
    
    public func makePipeline( _ rpd:MTLRenderPipelineDescriptor ) {
        // パイプラインの生成
        do {
            state = try CAIMMetal.device?.makeRenderPipelineState( descriptor: rpd )
        }
        catch {
            print( error.localizedDescription )
        }
    }
}

#endif
