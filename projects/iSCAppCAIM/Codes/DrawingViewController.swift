//
// DrawingViewController.swift
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

// 自由にピクセルを塗って絵を作れるView
class DrawingViewController : CAIMViewController
{
    // パーティクル情報の構造体
    struct Particle {
        var cx:Int = 0
        var cy:Int = 0
        var radius:Int = 0
        var color:CAIMColor = CAIMColor(R: 0.0, G: 0.0, B: 0.0, A: 1.0)
        var step:Float = 0.0
    }
	
    // パーティクルの変数
    var parts:[Particle] = [Particle]()
	
    // 準備
    override func setup() {
		iSC.setup()
        iSC.interpret("s.boot")

        clear()        // 画面をクリア
        redraw()       // 画面を更新
    }

    // ポーリング
    override func update() {
        clear() // 毎回クリア
		
        if(self.touch_pos.count > 0) {
            for pos:CGPoint in self.touch_pos {
                var p = Particle()
                p.cx = Int(pos.x)
                p.cy = Int(pos.y)
                p.radius = Int(arc4random()) % 40 + 20
                p.color = CAIMColor( R: Float(arc4random() % 1000)/1000.0, G: Float(arc4random() % 1000)/1000.0,
                                     B: Float(arc4random() % 1000)/1000.0, A: 1.0)
                p.step = 0
				
                parts.append(p)
            }
        }
		
        // parts内のパーティクル情報をすべてスキャンする
        let count:Int = parts.count
        for i in 0 ..< count {
            parts[i].step += 0.02

            var opacity:Float = 0.0
            if(parts[i].step < 0.5) { opacity = parts[i].step * 2.0 }
            else { opacity = (1.0-parts[i].step) * 2.0 }
			
            let radius:Int = Int(Float(parts[i].radius) * parts[i].step * 2.0)
			
            ImageToolBox.fillCircle(self.image, cx: parts[i].cx, cy: parts[i].cy,
                radius: radius, color: parts[i].color, opacity: opacity)
        }
		
        // partsを後ろからスキャンしstepが1.0以上になったパーティクル情報を削除する
        for i in 0 ..< count {
            let revi = count-1-i
            if(parts[revi].step >= 1.0) {
                parts.remove(at: revi)
            }
        }
		
        redraw()    // 画面を更新
    }
	
    override func touchPressed()
    {
        iSC.interpret("a = {SinOsc.ar()}.play")
    }
    
    override func touchMoved()
    {

    }
    
    override func touchReleased()
    {
        iSC.interpret("a.free")
    }
}



