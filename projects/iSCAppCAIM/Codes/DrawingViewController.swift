//
// DrawingViewController.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//
import UIKit

class DrawingViewController : CAIMViewController
{
    // view_allを画面いっぱいのピクセル領域(screenPixelRect)の大きさで用意
    var view_all:CAIMView = CAIMView(pixelFrame: CAIM.screenPixelRect)
    // 画像データimg_allを画面のピクセルサイズ(screenPixelSize)に合わせて用意
    var img_all:CAIMImage = CAIMImage(size: CAIM.screenPixelSize)
    
    // パーティクル情報の構造体
    struct Particle {
        var cx:Int = 0
        var cy:Int = 0
        var radius:Int = 0
        var color:CAIMColor = CAIMColor(R: 0.0, G: 0.0, B: 0.0, A: 1.0)
        var step:Float = 0.0
    }
    
    // パーティクル群を保存しておく配列
    var parts:[Particle] = [Particle]()
    
    // 準備
    override func setup() {
        iSC.setup()
        iSC.interpret("s.boot")
        
        // img_allを白で塗りつぶす
        img_all.fillColor( CAIMColor.white )
        // view_allの画像として、img_allを設定する
        view_all.image = img_all
        // view_allを画面に追加
        self.view.addSubview( view_all )
        
        // view_all上のタッチ開始時の処理として、touchPressedOnView関数を指定
        view_all.touchPressed = self.touchPressedOnView
        // view_all上のタッチ移動時の処理として、touchMovedOnView関数を指定
        view_all.touchMoved = self.touchMovedOnView
        // view_all上のタッチ終了時の処理として、touchReleasedOnView関数を指定
        view_all.touchReleased = self.touchReleasedOnView
    }
    
    // ポーリング
    override func update() {
        // 毎フレームごと、はじめにimg_allを白で塗りつぶす
        img_all.fillColor( CAIMColor.white )
        
        // view_allにタッチがあるか判定
        if(view_all.touchPixelPos.count > 0) {
            // touchPixelPosから1つずつ座標値をposに取得して、全てのタッチ情報について処理する
            for pos:CGPoint in view_all.touchPixelPos {
                // 新しいパーティクル情報の作成
                var p = Particle()
                p.cx = Int(pos.x)
                p.cy = Int(pos.y)
                p.radius = Int(arc4random()) % 40 + 20
                p.color = CAIMColor( R: Float(arc4random() % 1000)/1000.0, G: Float(arc4random() % 1000)/1000.0,
                                     B: Float(arc4random() % 1000)/1000.0, A: 1.0)
                p.step = 0
                // parts配列に新しいパーティクル(p)を追加
                parts.append(p)
            }
        }
        
        // 現在のparts内のパーティクル情報をすべてスキャンする
        for i in 0 ..< parts.count {
            // パーティクルの描画ステップを0.02進める
            parts[i].step += 0.02
            
            // 不透明度(opacity)はstep=0.0~0.5の増加に合わせて最大まで濃くなり、0.5~1.0までに最小まで薄くなる
            var opacity:Float = 0.0
            if(parts[i].step < 0.5) { opacity = parts[i].step * 2.0 }
            else { opacity = (1.0 - parts[i].step) * 2.0 }
            
            // 半径は基本半径(parts[i].radius)にstepと係数2.0を掛け算する
            let radius:Int = Int(Float(parts[i].radius) * parts[i].step * 2.0)
            
            // パーティクル情報から求めた計算結果を用いて円を描く
            ImageToolBox.fillCircle(img_all, cx: parts[i].cx, cy: parts[i].cy,
                                    radius: radius, color: parts[i].color, opacity: opacity)
        }
        
        // partsを後ろからスキャンし、stepが1.0以上になったパーティクル情報を削除する
        for i in (0 ..< parts.count).reversed() {
            if(parts[i].step >= 1.0) {
                parts.remove(at: i)
            }
        }
        
        // 画像が更新されている可能性があるので、view_allを再描画して結果を表示
        view_all.redraw()
    }
    
    func touchPressedOnView()
    {
        iSC.interpret("a = {SinOsc.ar()}.play")
    }
    
    func touchMovedOnView()
    {
        
    }
    
    func touchReleasedOnView()
    {
        iSC.interpret("a.free")
    }
}
