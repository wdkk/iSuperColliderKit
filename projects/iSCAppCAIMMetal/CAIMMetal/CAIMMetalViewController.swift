//
// CAIMMetalViewController.swift
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

class CAIMMetalViewController: UIViewController
{
    // オーバーライド用関数群
    // DrawingViewControllerではこれらを「上書き」して処理を追加する
    func setup() {}
    func update(renderer:CAIMMetalRenderer) {}
    func touchPressed() {}
    func touchMoved() {}
    func touchReleased() {}
    func touchCancelled() {}

    // タッチ位置の座標変数
    var touch_pos:[CGPoint] = [CGPoint]()
    var release_pos:[CGPoint] = [CGPoint]()
    
    fileprivate var _display_link:CADisplayLink?        // ループ処理用ディスプレイリンク
    
    fileprivate var _caim_metal_view:CAIMMetalView?     // MetalView
    fileprivate var _renderer:CAIMMetalRenderer?
    
    
    // ページがロード(生成)された時、処理される。主にUI部品などを作るときに利用
    override func viewDidLoad() {
        // 親のviewDidLoadを呼ぶ[必須]
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // 画像を表示するCAIMViewを内部でつくり、ViewControllerに貼り付ける
        _caim_metal_view = CAIMMetalView(frame: self.view.bounds)
        self.view.addSubview(_caim_metal_view!)
        
        // レンダラの作成
        self._renderer = CAIMMetalRenderer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 親のviewDidAppearを呼ぶ
        super.viewDidAppear(animated)
        
        // オーバーライド関数のコール
        setup()
        
        // updateのループ処理を開始
        _display_link = CADisplayLink(target: self, selector: #selector(CAIMMetalViewController.polling(_:)))
        _display_link?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // 親のviewDidAppearを呼ぶ
        super.viewDidDisappear(animated)
        
        // updateのループ処理を終了
        _display_link?.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    // CADisplayLinkで60fpsで呼ばれる関数
    @objc func polling(_ display_link :CADisplayLink) {
        // レンダラとビューの紐付け、および準備
        _renderer?.ready(view: _caim_metal_view!)
        
        // オーバーライド関数のコール
        update(renderer: CAIMMetalRenderer.current!)
        
        // レンダ処理を確定する
        _renderer?.commit()
    }
    
    // タッチ開始関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)            // 指の情報を取得
        touchPressed()
    }
    
    // タッチなぞり関数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)            // 指の情報を取得
        touchMoved()
    }
    
    // タッチ終了関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with:event)     // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(event!)             // 指の情報を取得
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
            let pos:CGPoint = touch.location(in: self.view)
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
}
