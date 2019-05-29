//
// CAIMBaseView.swift
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
public class CAIMBaseView : UIView
{
    // タッチイベント関数オブジェクト
    public var touchPressed:()->() = {}
    public var touchMoved:()->() = {}
    public var touchReleased:()->() = {}
    public var touchCancelled:()->() = {}
    
    // タッチ位置の座標変数
    public var touchPixelPos:[CGPoint] = [CGPoint]()
    public var releasePixelPos:[CGPoint] = [CGPoint]()
    
    public override init(frame:CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = true
    }
    
    public init(pixelFrame pfrm:CGRect = .zero) {
        super.init(frame: .zero)
        self.pixelFrame = pfrm
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = true
    }
    
    public init(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        super.init(frame: .zero)
        self.pixelFrame = CGRect(x: x, y:y, width:width, height:height )
        self.backgroundColor = .clear
        self.isMultipleTouchEnabled = true
    }
    
    // 初期化関数(requiredされて入れたもの)
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    // タッチ開始関数
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        touchPressed()
    }
    
    // タッチなぞり関数
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)               // 指の情報を取得
        touchMoved()
    }
    
    // タッチ終了関数
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with:event)     // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        touchReleased()
    }
    
    // タッチ中の中断関数
    public override func touchesCancelled(_ rmv_touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(rmv_touches, with:event) // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)                 // 指の情報を取得
        touchCancelled()
    }
    
    // 指の座標を取得してtouchesの情報を詰める
    // ただしtouch.location(in:)で取得できる(x,y)座標はpixelではなく、point（Retinaディスプレイ関連。Appleのリファレンス参照のこと)
    // このため、Retinaスケールを考慮してpointをpixelに置き換える
    fileprivate func recognizeTouchInfo(_ event: UIEvent) {
        // タッチ情報の配列をリセット
        self.touchPixelPos.removeAll(keepingCapacity: false)
        self.releasePixelPos.removeAll(keepingCapacity: false)
        // retinaスケールの取得
        let sc:CGFloat = UIScreen.main.scale
        // タッチ数分のループ
        for touch:UITouch in event.allTouches! {
            // point座標系を取得
            let pos:CGPoint = touch.location(in: self)
            if(touch.phase == .ended || touch.phase == .cancelled) {
                // scを掛け算してpixel座標系に変換し、releasePosに追加
                self.releasePixelPos.append(CGPoint(x: pos.x * sc, y: pos.y * sc))
            }
            else {
                // scを掛け算してpixel座標系に変換し、touchPosに追加
                self.touchPixelPos.append(CGPoint(x: pos.x * sc, y: pos.y * sc))
            }
        }
    }
}
