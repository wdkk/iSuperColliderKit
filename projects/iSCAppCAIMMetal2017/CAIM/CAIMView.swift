//
// CAIMView.swift
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
import Accelerate

// CAIM用画像表示ビュークラス
class CAIMView : UIView
{
    // オーバーライド用関数群
    func touchPressed() {}
    func touchMoved() {}
    func touchReleased() {}
    func touchCancelled() {}
    
    // 画像プロパティ
    var image:CAIMImage! {
        didSet(new_image) { redraw() }
    }

    // ピクセル表示命令用の変数
    fileprivate var buf:CAIMColor8Ptr! = nil
    fileprivate var bufwid:Int = 0
    fileprivate var bufhgt:Int = 0
    
    // タッチ位置の座標変数
    var touch_pos:[CGPoint] = [CGPoint]()
    var release_pos:[CGPoint] = [CGPoint]()
    
    // 初期化関数フレームあり
    override init(frame:CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = true
    }
    
    // 初期化関数(requiredされて入れたもの)
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    // 解放時関数
    deinit {
        if(buf != nil) { free(buf) }
    }
    
    // タッチ開始関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        touchPressed()
    }
    
    // タッチなぞり関数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)               // 指の情報を取得
        touchMoved()
    }
    
    // タッチ終了関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with:event)     // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        touchReleased()
    }
    
    // タッチ中の中断関数
    override func touchesCancelled(_ rmv_touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(rmv_touches, with:event) // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        touchCancelled()
    }
    
    // 指の座標を取得してtouchesの情報を詰める
    // ただしtouch.location(in:)で取得できる(x,y)座標はpixelではなく、point（Retinaディスプレイ関連。Appleのリファレンス参照のこと)
    // このため、Retinaスケールを考慮してpointをpixelに置き換える
    fileprivate func recognizeTouchInfo(_ event: UIEvent) {
        // タッチ情報の配列をリセット
        self.touch_pos.removeAll(keepingCapacity: false)
        self.release_pos.removeAll(keepingCapacity: false)
        // retinaスケールの取得
        let sc:CGFloat = UIScreen.main.scale
        // タッチ数分のループ
        for touch:UITouch in event.allTouches! {
            
            // point座標系を取得
            let pos:CGPoint = touch.location(in: self)
            if(touch.phase == .ended || touch.phase == .cancelled) {
                // scを掛け算してpixel座標系に変換し、release_posに追加
                self.release_pos.append(CGPoint(x: pos.x * sc, y: pos.y * sc))
            }
            else {
                // scを掛け算してpixel座標系に変換し、touch_posに追加
                self.touch_pos.append(CGPoint(x: pos.x * sc, y: pos.y * sc))
            }
        }
    }
    
    // 再描画命令
    func redraw() { setNeedsDisplay() }
    
    // UIKit API draw(rect:)の上書き
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        let context:CGContext = UIGraphicsGetCurrentContext()!
    
        // 画像が指定されていないときは白でクリア
        if(image == nil) {
            context.clear(rect)
            UIColor.white.setFill()
            context.fill(rect)
            return
        }
        
        // parameter of CAIMImage
        let wid:Int = image.width
        let hgt:Int = image.height
        let mem:UnsafeMutablePointer<UInt8> = image.memory
        
        // 画像データがない場合、サイズが変更された場合のみメモリを確保する
        if(buf == nil || wid != bufwid || hgt != bufhgt) {
            if(buf != nil) { free(buf) }
            buf = unsafeBitCast(malloc(wid * hgt * MemoryLayout<CAIMColor8>.size), to: CAIMColor8Ptr.self)
            bufwid = wid
            bufhgt = hgt
        }
        
        // ready Accelerate Process
        // AccelerateのvImageを用いて高速に画像処理を行っている
        var src:vImage_Buffer = vImage_Buffer(data: mem, height: UInt(hgt), width: UInt(wid), rowBytes: Int(wid * 4 * 4) )
        var dst:vImage_Buffer = vImage_Buffer(data: buf, height: UInt(hgt), width: UInt(wid), rowBytes: Int(wid * 4) )
        let max_float:[Float] = [ 1.0, 1.0, 1.0, 1.0 ]
        let min_float:[Float] = [ 0.0, 0.0, 0.0, 0.0 ]
        let map:Int32 = 0
        // RGBAのFloat型(32bit)を8bitに変換をかける。vImageで高速化
        vImageConvert_ARGBFFFFtoARGB8888_dithered(&src, &dst, max_float, min_float, map, nil, 0)
        
        let channel = 4
        let depth = 8
        let bytes_per_row:Int = wid * channel * depth / 8
        let color_space:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 8bitピクセルデータからCGContextの作成
        let ctx:CGContext? = CGContext(data: buf,
                                       width: bufwid,
                                       height: bufhgt,
                                       bitsPerComponent: depth,
                                       bytesPerRow: bytes_per_row,
                                       space: color_space,
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        // CGContextからCGImageを作成
        let cgimg:CGImage? = ctx!.makeImage()
        // CGImageを使って画面に描画
        drawCGImage(context, cgimg!, rect)
    }

    // CGImageを使って画面に描画を行う
    private func drawCGImage(_ context:CGContext, _ img:CGImage, _ rect: CGRect) {
        // CGContextはy座標系が逆位置なので反転する
        context.translateBy(x: 0, y: CGFloat(self.frame.size.height))
        context.scaleBy(x: 1.0, y: -1.0)
        // 描画
        context.draw(img, in: rect)
        // 反転したCGContextを元に戻す
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0, y: CGFloat(-self.frame.size.height))
    }
}
