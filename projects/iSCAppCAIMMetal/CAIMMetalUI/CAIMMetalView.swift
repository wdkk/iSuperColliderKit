//
// CAIMMetalView.swift
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
import QuartzCore

#if os(iOS)
import UIKit
#endif

public class CAIMMetalView: CAIMBaseView, CAIMMetalViewProtocol
{
    // UI
    public private(set) lazy var metalLayer:CAMetalLayer = CAMetalLayer()
    // デプス
    public private(set) var depthState:CAIMMetalDepthState = CAIMMetalDepthState()
    public private(set) var depthTexture:MTLTexture?
    // クリアカラー
    public var clearColor:CAIMColor = .white
    
    public override var bounds:CGRect { didSet { metalLayer.frame = self.bounds } }
    
    public override var frame:CGRect { didSet { metalLayer.frame = self.bounds } }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupMetal()
    }
    
    public override init(pixelFrame pfrm: CGRect) {
        super.init(pixelFrame: pfrm)
        setupMetal()
    }
    
    public override init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        super.init(x: x, y: y, width: width, height: height)
        setupMetal()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // Metalの初期化 / Metal Layerの準備
    private func setupMetal() {
        metalLayer.device = CAIMMetal.device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = false
        metalLayer.frame = self.bounds
        metalLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer( metalLayer )
    }
    
    // Metalコマンドの開始(CAIMMetalViewから呼び出せる簡易版。本体はCAIMMetal.execute)
    public func execute( preRenderFunc:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                         renderFunc:( _ renderEncoder:MTLRenderCommandEncoder )->(),
                         postRenderFunc:( _ commandBuffer:MTLCommandBuffer )->() = { _ in },
                         completion: ((_ commandBuffer:MTLCommandBuffer )->())? = nil ) {
        CAIMMetal.execute(
        prev: preRenderFunc,
        main: { ( commandBuffer:MTLCommandBuffer ) in
            self.beginDraw( commandBuffer:commandBuffer, renderFunc:renderFunc )
        },
        post: postRenderFunc,
        completion: completion )
    }
 
    // デプステクスチャの設定と再生成
    private func updateDepthTexture( drawable:CAMetalDrawable ) {
        // デプステクスチャディスクリプタの設定
        let depth_desc:MTLTextureDescriptor = makeDepthTextureDescriptor( drawable:drawable, depthState:depthState )
        // デプステクスチャの作成
        makeDepthTexture( depthDesc:depth_desc, depthState:depthState )
    }
    
    // エンコーダの設定と再生成
    private func makeEncoder( commandBuffer command_buffer:MTLCommandBuffer, drawable:CAMetalDrawable ) -> MTLRenderCommandEncoder? {
        // レンダーパスディスクリプタの設定
        let r_pass_desc:MTLRenderPassDescriptor = makeRenderPassDescriptor( drawable:drawable, color:clearColor, depthTexture:depthTexture! )
        // エンコーダ生成
        return command_buffer.makeRenderCommandEncoder( descriptor: r_pass_desc )
    }
    
    @discardableResult
    public func beginDraw( commandBuffer command_buffer:MTLCommandBuffer,
                           renderFunc:( _ renderEncoder:MTLRenderCommandEncoder )->() ) -> Bool {
        if( metalLayer.bounds.width < 1 || metalLayer.bounds.height < 1 ) { return false }
        
        guard let drawable:CAMetalDrawable = metalLayer.nextDrawable() else { print("cannot get Metal drawable."); return false }
        
        updateDepthTexture( drawable: drawable )

        guard let encoder = makeEncoder( commandBuffer: command_buffer, drawable: drawable ) else { print("don't get RenderCommandEncoder."); return false }
        
        encoder.setFrontFacing( .counterClockwise )
        // エンコーダにカリングの初期設定
        encoder.setCullMode( .none )
        // エンコーダにデプスとステンシルの初期設定
        let depth_desc = MTLDepthStencilDescriptor()
        depth_desc.depthCompareFunction = .always
        depth_desc.isDepthWriteEnabled = false
        encoder.setDepthStencilDescriptor( depth_desc )
        
        // 指定された関数オブジェクトの実行
        renderFunc( encoder )
        
        // エンコーダの終了
        encoder.endEncoding()
        
        // コマンドバッファを画面テクスチャへ反映
        command_buffer.present( drawable )
        
        return true
    }
    
    public func makeDepthTexture( depthDesc depth_desc:MTLTextureDescriptor, depthState depth_state:CAIMMetalDepthState ) {
        // まだテクスチャメモリが生成されていない場合、もしくはサイズが変更された場合、新しいテクスチャを生成する
        if(depthTexture == nil || depthTexture!.width != depth_desc.width || depthTexture!.height != depth_desc.height) {
            depthTexture = CAIMMetal.device?.makeTexture( descriptor: depth_desc )
        }
    }
}

#endif
