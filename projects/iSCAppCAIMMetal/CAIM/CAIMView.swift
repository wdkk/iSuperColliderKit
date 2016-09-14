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
    // 関数を格納するイベント用のオブジェクト
    var ev_touches_began:(CAIMView)->Void     = { (view:CAIMView)->Void in /* nothing */ }
    var ev_touches_moved:(CAIMView)->Void     = { (view:CAIMView)->Void in /* nothing */ }
    var ev_touches_ended:(CAIMView)->Void     = { (view:CAIMView)->Void in /* nothing */ }
    var ev_touches_cancelled:(CAIMView)->Void = { (view:CAIMView)->Void in /* nothing */ }
    
    // 画像プロパティ
    var image:CAIMImage!
    {
        didSet(new_image) { redraw() }
    }

    // ピクセル表示命令用の変数
    private var buf:CAIMColor8Ptr! = nil
    private var bufwid:Int = 0
    private var bufhgt:Int = 0
    
    // 再描画命令
    func redraw()
    {
        blt()        // ピクセル描画処理の呼び出し
    }
    
    // 座標プロパティ(プロパティを指定したら位置が変わるようにframe指定を行う)
    var x:CGFloat
        {
        get { return self.frame.origin.x }
        set(new_value) { self.frame.origin.x = new_value }
    }
    var y:CGFloat
        {
        get { return self.frame.origin.y }
        set(new_value) { self.frame.origin.y = new_value }
    }
    
    // サイズプロパティ(プロパティを指定したら位置が変わるようにframe指定を行う)
    var width:Int
        {
        get { return Int(self.frame.size.width) }
        set(new_value) { self.frame.size.width = CGFloat(new_value) }
    }
    var height:Int
        {
        get { return Int(self.frame.size.height) }
        set(new_value) { self.frame.size.height = CGFloat(new_value) }
    }
    
    // タッチ位置の座標変数
    var touch_pos:[CGPoint] = Array<CGPoint>()
    // タッチ判定
    var is_touch:Bool = false
    // タッチ個数
    private var touch_count:Int = 0
    // UITouch情報
    var touches:[UITouch] = Array<UITouch>()
    // UIEvent情報
    var event:UIEvent? = nil
    
    
    // 初期化関数
    init()
    {
        super.init(frame: CGRectZero)
        self.backgroundColor = .clearColor()
        self.multipleTouchEnabled = true
    }
    
    // 初期化関数フレームあり
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clearColor()
        self.multipleTouchEnabled = true
    }
    
    // 初期化関数(requiredされて入れたもの)
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // 解放時関数
    deinit
    {
        if(buf != nil) { free(buf) }
    }
    
    // タッチ開始関数
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent:event)    // 親のメソッドをコール(必須)
        self.touch_count += touches.count
        self.touches.appendContentsOf(touches)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        ev_touches_began(self)                          // タッチイベント関数のコール
    }
    
    // タッチなぞり関数
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesMoved(touches, withEvent:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        ev_touches_moved(self)                          // タッチイベント関数のコール
    }
    
    // タッチ終了関数
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesEnded(touches, withEvent:event)    // 親のメソッドをコール(必須)
        self.touch_count -= touches.count
        
        for t:UITouch in touches
        {
            var mind:CGFloat = 999999.0
            var minidx:Int = 0
            var i:Int = 0
            for touch:UITouch in self.touches
            {
                let pt1:CGPoint = t.locationInView(self)
                let pt2:CGPoint = touch.locationInView(self)
                
                let d:CGFloat = sqrt((pt1.x-pt2.x)*(pt1.x-pt2.x) + (pt1.y-pt2.y)*(pt1.y-pt2.y))
                if(d < mind) { mind = d; minidx = i }
                i += 1
            }
            self.touches.removeAtIndex(minidx)
        }
        
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        ev_touches_ended(self)                          // タッチイベント関数のコール
    }
    
    // タッチ中の中断関数
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        super.touchesCancelled(touches, withEvent:event)// 親のメソッドをコール(必須)
        self.touch_count = 0
        self.touches.removeAll()
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        ev_touches_cancelled(self)                      // タッチイベント関数のコール
    }
    
    // 指の座標を取得してtouchesの情報を詰める
    // ただしtouch.locationInViewで取得できる(x,y)座標はpixelではなく、point（Retinaディスプレイ関連。Appleのリファレンス参照のこと)
    // このため、Retinaスケールを考慮してpointをpixelに置き換える
    private func recognizeTouchInfo(event: UIEvent)
    {
        // タッチ情報の配列をリセット
        self.touch_pos.removeAll(keepCapacity: false)
        // retinaスケールの取得
        let sc:CGFloat = UIScreen.mainScreen().scale
        // タッチ数分のループ
        for touch:UITouch in self.touches
        {
            // (x,y)point座標系を取得
            let pos:CGPoint = touch.locationInView(self)
            // pixel座標系に置き直し、touch_posに追加していく
            self.touch_pos.append(CGPoint(x: pos.x * sc, y: pos.y * sc))
        }
        
        self.is_touch = (self.touch_count > 0)
        self.event = event
    }
    
    
    // アフィン変換プロパティ
    var scale_x = Double(1.0)   // 横方向拡大率
    {
        didSet{ affineTransform() } // 値セット後のアフィン変換処理
    }
    var scale_y = Double(1.0)   // 縦方向拡大率
    {
        didSet{ affineTransform() } // 値セット後のアフィン変換処理
    }
    var angle   = Double(0.0)   // 回転角度(360度法)
    {
        didSet{ affineTransform() } // 値セット後のアフィン変換処理
    }
    
    // アフィン変換作成処理関数
    private func affineTransform()
    {
        var affine = CGAffineTransform()
        affine.a  = CGFloat(scale_x *  cos(angle * M_PI / 180.0))
        affine.b  = CGFloat(scale_x *  sin(angle * M_PI / 180.0))
        affine.c  = CGFloat(scale_y * -sin(angle * M_PI / 180.0))
        affine.d  = CGFloat(scale_y *  cos(angle * M_PI / 180.0))
        affine.tx = 0.0
        affine.ty = 0.0
        self.transform = affine
    }
    
    // ピクセル表示命令（BitBlt)
    private func blt()
    {
        if(image == nil) { return }
        
        // parameter of CAIMImage
        let wid:Int = image.width
        let hgt:Int = image.height
        let mem:UnsafeMutablePointer<UInt8> = image.memory
        
        // 画像データがない場合、サイズが変更された場合のみメモリを確保する(高速化テク)
        if(buf == nil || wid != bufwid || hgt != bufhgt)
        {
            if(buf != nil) { free(buf) }
            buf = CAIMColor8Ptr(malloc(wid * hgt * sizeof(CAIMColor8)))
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

        // 画面に表示するためCGImageを作成する
        let bytes_per_row:Int = 4 * wid
        let bytes_size:CFIndex = CFIndex(bytes_per_row) * hgt
        let color_space:CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        let data_prov:CGDataProviderRef? = CGDataProviderCreateWithData(nil, UnsafePointer<UInt8>(buf), bytes_size, nil)
    
        let cg_image = CGImageCreate(
                wid,
                hgt,
                8,
                32,
                4 * wid,
                color_space,
                .ByteOrderDefault,
                data_prov,
                nil,
                true,
                .RenderingIntentDefault)
        
        // viewのlayer(CALayer)にCGImageを渡す（画面に表示される)
        self.layer.contents = cg_image
    }
}
