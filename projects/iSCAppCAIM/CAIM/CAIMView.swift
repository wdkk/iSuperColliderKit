//
// CAIMView.swift
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
import Accelerate

// CAIM用画像表示ビュークラス
public class CAIMView : CAIMBaseView
{
    // 画像プロパティ
    var image:CAIMImage! { didSet(new_image) { redraw() } }

    // ピクセル表示命令用の変数
    fileprivate var buf:CAIMColor8Ptr? = nil
    fileprivate var bufwid:Int = 0
    fileprivate var bufhgt:Int = 0

    // 解放時関数
    deinit {
        if(buf != nil) { free(buf) }
    }
        
    // 再描画命令
    public func redraw() { setNeedsDisplay() }
    
    // UIKit API draw(rect:)の上書き
    public override func draw(_ rect: CGRect) {
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
        let mem = image.memory
        
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
