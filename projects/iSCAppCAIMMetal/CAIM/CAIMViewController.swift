//
// CAIMViewController.swift
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

class CAIMViewController: UIViewController
{
    // 関数を格納するイベント用のオブジェクト
    var ev_did_load:(CAIMViewController)->Void      = { (vc:CAIMViewController)->Void in /* nothing */ }
    var ev_did_appear:(CAIMViewController)->Void    = { (vc:CAIMViewController)->Void in /* nothing */ }
    var ev_did_disappear:(CAIMViewController)->Void = { (vc:CAIMViewController)->Void in /* nothing */ }
    var ev_update:(CAIMViewController)->Void        = { (vc:CAIMViewController)->Void in /* nothing */ }
    // タッチイベント系の関数オブジェクト
    var ev_touches_began:(CAIMViewController)->Void     = { (vc:CAIMViewController)->Void in /* nothing */ }
    var ev_touches_moved:(CAIMViewController)->Void     = { (vc:CAIMViewController)->Void in /* nothing */ }
    var ev_touches_ended :(CAIMViewController)->Void    = { (vc:CAIMViewController)->Void in /* nothing */ }
    var ev_touches_cancelled:(CAIMViewController)->Void = { (vc:CAIMViewController)->Void in /* nothing */ }
    
    private var display_link:CADisplayLink!
    
    // 座標プロパティ
    var x:CGFloat { get { return self.view.frame.origin.x } }
    var y:CGFloat { get { return self.view.frame.origin.y } }
    var width:CGFloat { get { return self.view.frame.size.width } }
    var height:CGFloat { get { return self.view.frame.size.height } }

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
    
    
    // ページがロード(生成)された時、処理される。主にUI部品などを作るときに利用
    override func viewDidLoad()
    {
        // 親のviewDidLoadを呼ぶ[必須]
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // 登録した関数のコール
        ev_did_load(self)
    }

    override func viewDidAppear(_ animated: Bool)
    {
        // 親のviewDidAppearを呼ぶ
        super.viewDidAppear(animated)
        
        // 登録した関数のコール
        ev_did_appear(self)
        
        // updateのループ処理を開始
        display_link = CADisplayLink(target: self, selector: #selector(polling))
        display_link.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        // 親のviewDidAppearを呼ぶ
        super.viewDidDisappear(animated)
        
        // 登録した関数のコール
        ev_did_disappear(self)
        
        // updateのループ処理を終了
        display_link.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    // CADisplayLinkで60fpsで呼ばれる関数
    func polling(display_link :CADisplayLink)
    {
        // 登録した関数のコール
        ev_update(self)
    }
    
    // タッチ開始関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with:event)    // 親のメソッドをコール(必須)
        self.touch_count += touches.count
        self.recognizeTouchInfo(touches, event:event!)   // 指の情報を取得
        ev_touches_began(self)                          // タッチイベント関数のコール
    }
    
    // タッチなぞり関数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesMoved(touches, with:event)    // 親のメソッドをコール(必須)
        self.recognizeTouchInfo(touches, event:event!)   // 指の情報を取得
        ev_touches_moved(self)                          // タッチイベント関数のコール
    }
    
    // タッチ終了関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with:event)    // 親のメソッドをコール(必須)
        self.touch_count -= touches.count
        self.recognizeTouchInfo(touches, event:event!)   // 指の情報を取得
        ev_touches_ended(self)                          // タッチイベント関数のコール
    }
    
    // タッチ中の中断関数
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        super.touchesCancelled(touches!, with:event)// 親のメソッドをコール(必須)
        self.touch_count = 0
        self.recognizeTouchInfo(touches!, event:event!) // 指の情報を取得
        ev_touches_cancelled(self)                      // タッチイベント関数のコール
    }
    
    // 指の座標を取得してtouchesの情報を詰める
    // ただしtouch.locationInViewで取得できる(x,y)座標はpixelではなく、point（Retinaディスプレイ関連。Appleのリファレンス参照のこと)
    // このため、Retinaスケールを考慮してpointをpixelに置き換える
    private func recognizeTouchInfo(_ touches: Set<NSObject>, event: UIEvent)
    {
        // タッチ情報の配列をリセット
        self.touch_pos.removeAll(keepingCapacity: false)
        self.touches.removeAll(keepingCapacity: false)
        // retinaスケールの取得
        let sc:CGFloat = UIScreen.main.scale
        // タッチ数分のループ
        for touch in touches as! Set<UITouch>
        {
            // (x,y)point座標系を取得
            let pos:CGPoint = touch.location(in: self.view)
            // pixel座標系に置き直し、touch_posに追加していく
            self.touch_pos.append(CGPoint(x: pos.x * sc, y: pos.y * sc))
            
            // touchesにはそのままUITouchの情報を格納する
            self.touches.append(touch)
        }
    
        self.is_touch = (self.touch_count > 0)
        self.event = event
    }
}
