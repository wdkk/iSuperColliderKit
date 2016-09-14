//
//  CAIMMetalView.swift
//  ios_caim01
//
//  Created by kengo on 2016/02/02.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class CAIMMetalView: CAIMView
{    
    // Metal Objects
    var metal_layer:CAMetalLayer!

    override init(frame: CGRect)
    {
        super.init(frame:frame)
        
        initializeMetal()
        buildResources()
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override func redraw() { autoreleasepool { draw() } }
    
    // Metalの初期化 / Metal Layerの準備
    private func initializeMetal()
    {
        // layer's frame
        metal_layer = CAMetalLayer()
        metal_layer.device = CAIMMetal.device
        metal_layer.pixelFormat = .BGRA8Unorm
        metal_layer.framebufferOnly = true
        metal_layer.frame = self.bounds
        metal_layer.contentsScale = UIScreen.mainScreen().scale
        self.layer.addSublayer(metal_layer)
    }
    
    func buildResources()
    {
        // 描画リソースを用意する
    }
    
    func draw()
    {
        // レンダリング処理を書く
    }
}
