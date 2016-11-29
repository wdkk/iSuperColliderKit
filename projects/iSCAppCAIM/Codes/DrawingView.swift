/**
 DrawingView.swift
 
 Copyright (c) 2015 Watanabe-DENKI Inc.
 
 This software is released under the MIT License.
 http://opensource.org/licenses/mit-license.php
 */

import UIKit

class DrawingView: CAIMView
{
    // 画像データの変数
    var img_red:CAIMImage!

    // はじめに1度だけ呼ばれる関数(ここで準備する)
    func setup(vc:CAIMViewController)
    {
        // 画像データを作成
        img_red  = CAIMImage(wid: 320, hgt: 320)
        ImageToolBox.fillRed(img: img_red)
        
        self.image = img_red
        
        // 画面を更新
        redraw()
    }
    
    func touchBegan(vc: CAIMViewController)
    {
        iSC.interpret("a = {SinOsc.ar()}.play")
        print("began")
    }
    
    func touchMoved(vc: CAIMViewController)
    {

    }
    
    func touchEnded(vc: CAIMViewController)
    {
        iSC.interpret("a.free")
        print("ended")
    }
    
    func update(vc: CAIMViewController)
    {
        // 60FPS
    }
}



