/**
 AppDelegate.swift
 
 Copyright (c) 2015 Watanabe-DENKI Inc.
 
 This software is released under the MIT License.
 http://opensource.org/licenses/mit-license.php
 */

 // Advancedメッセージ
 // (1) AppDelegateはiOSのアプリケーションの大元クラス。iOSアプリケーションを作る上で必須のクラスのためどのようなクラスなのかを調べてみよう（要検索）

import UIKit

// アプリケーションクラス
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // ビューの変数
    var window:UIWindow?         // ウィンドウを格納する変数[?が必須]
    var vc:MyViewController!
    
    // アプリが起動した時に最初に呼ばれる処理
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
    {
        // ウィンドウを作成する
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // MyViewControllerの作成
        vc = MyViewController()
        window!.rootViewController = vc
        
        // ウィンドウを使えるようにしてアプリを開始
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
