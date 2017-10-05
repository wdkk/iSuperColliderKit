//
// CAIMMetalView.swift
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

class CAIMMetalView: CAIMView
{    
    // Metal Objects
    private var _metal_layer:CAMetalLayer?
    var metal_layer:CAMetalLayer? { return _metal_layer }

    override init(frame: CGRect) {
        super.init(frame:frame)
        initializeMetal()
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // Metalの初期化 / Metal Layerの準備
    private func initializeMetal() {
        // layer's frame
        _metal_layer = CAMetalLayer()
        _metal_layer?.device = CAIMMetal.device
        _metal_layer?.pixelFormat = .bgra8Unorm
        _metal_layer?.framebufferOnly = true
        _metal_layer?.frame = self.bounds
        _metal_layer?.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(_metal_layer!)
    }
}
