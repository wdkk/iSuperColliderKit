//
// AppDelegate.swift
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

// アプリケーションクラス
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // ビューの変数
    var window:UIWindow?             // ウィンドウを格納する変数[?が必須]
    var dvc:DrawingViewController!   // 描画ビューコントローラ
    
    // アプリが起動した時に最初に呼ばれる処理
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ウィンドウを作成する
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // DrawingViewControllerを作って、dvcに入れる
        dvc = DrawingViewController()
        
        // dvcをwindowの最初の画面として設定する
        window!.rootViewController = dvc
        
        // ウィンドウを使えるようにしてアプリを開始
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}
