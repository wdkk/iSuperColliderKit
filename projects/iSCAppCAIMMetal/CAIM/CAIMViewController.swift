//
// CAIMViewController.swift
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

class CAIMViewController: UIViewController
{
    // ビューコントローラ設定用オーバーライド関数
    public func setup() {}
    public func update() {}
    public func teardown() {}
    
    public var pixelX:CGFloat {
        get { return self.view.pixelX }
        set { self.view.pixelX = newValue }
    }
    public var pixelY:CGFloat {
        get { return self.view.pixelY }
        set { self.view.pixelY = newValue }
    }
    public var pixelWidth:CGFloat {
        get { return self.view.pixelWidth }
        set { self.view.pixelWidth = newValue }
    }
    public var pixelHeight:CGFloat {
        get { return self.view.pixelHeight }
        set { self.view.pixelHeight = newValue }
    }
    public var pixelFrame:CGRect {
        get { return view.pixelFrame }
        set { self.view.pixelFrame = newValue }
    }
    public var pixelBounds:CGRect {
        get { return view.pixelBounds }
        set { self.view.pixelBounds = newValue }
    }
  
    fileprivate var _display_link:CADisplayLink!    // ループ処理用ディスプレイリンク
    
    // ページがロード(生成)された時、処理される。主にUI部品などを作るときに利用
    override func viewDidLoad() {
        // 親のviewDidLoadを呼ぶ[必須]
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        // 親のviewDidAppearを呼ぶ
        super.viewDidAppear(animated)
        
        // オーバーライド関数のコール
        setup()
        
        // updateのループ処理を開始
        _display_link = CADisplayLink(target: self, selector: #selector(CAIMViewController.polling(_:)))
        _display_link.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // 親のviewDidAppearを呼ぶ
        super.viewDidDisappear(animated)
        
        // updateのループ処理を終了
        _display_link.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
        
        teardown()
    }
    
    // CADisplayLinkで60fpsで呼ばれる関数
    @objc func polling(_ display_link :CADisplayLink) {
        // オーバーライド関数のコール
        update()
    }
}
