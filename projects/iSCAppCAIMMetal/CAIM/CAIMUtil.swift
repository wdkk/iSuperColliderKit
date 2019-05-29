//
// CAIMUtil.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

import Foundation
import UIKit

// init()を必ず持つようにするためのプロトコル
protocol Initializable
{
    init()
}

public class CAIM
{
    // バンドル画像のパスを返す
    public static func bundle(_ file_path:String) -> String {
        let path:String! = Bundle.main.resourcePath
        return (path! + "/" + file_path)
    }
    
    // 現在のシステム時間のmsを返す
    public static var now:Int64 {
        var now_time:timeval = timeval()
        var tzp:timezone = timezone()
        
        gettimeofday(&now_time, &tzp)
        
        return (Int64(now_time.tv_sec) * 1000 + Int64(now_time.tv_usec) / 1000)
    }
    
    // 秒間のFPSを計測する（ループ内で使う）
    public static func fps() {
        struct variables {
            static var is_started:Bool = false
            static var time_span:Int64 = 0
            static var fps:UInt32 = 0
        }
        
        if (!variables.is_started) {
            variables.is_started = true
            variables.time_span = CAIM.now
            variables.fps = 0
        }
        
        let dt:Int64 = CAIM.now - variables.time_span
        if (dt >= 1000) {
            print("CAIM: \(variables.fps)(fps)")
            variables.time_span = CAIM.now
            variables.fps = 0
        }
        
        variables.fps += 1
    }
    
    // ランダム値の計算
    public static func random(_ max:Float=1.0) -> Float { return Float(arc4random() % 1000) / 1000.0 * max }
    public static func random(_ max:Int32) -> Float { return Float(arc4random() % 1000) / 1000.0 * Float(max) }
    public static func random(_ max:Int) -> Float { return Float(arc4random() % 1000) / 1000.0 * Float(max) }
    
    // スクリーンサイズの取得
    public static var screenPointSize:CGSize {
        return UIScreen.main.bounds.size
    }
    
    // スクリーンピクセルサイズの取得
    public static var screenPixelSize:CGSize {
        let sc:CGFloat = UIScreen.main.scale
        let size:CGSize = UIScreen.main.bounds.size
        let wid = size.width * sc
        let hgt = size.height * sc
        return CGSize(width:wid, height:hgt)
    }
    
    // スクリーンサイズの取得
    public static var screenPointRect:CGRect {
        return UIScreen.main.bounds
    }
    
    // スクリーンピクセルサイズの取得
    public static var screenPixelRect:CGRect {
        let sc:CGFloat = UIScreen.main.scale
        let rc:CGRect = UIScreen.main.bounds
        let wid = rc.width * sc
        let hgt = rc.height * sc
        return CGRect(x:0, y:0, width:wid, height:hgt)
    }
}

extension Float {
    public var toRadian:Float { return self * Float.pi / 180.0 }
    public var toDegree:Float { return self * 180.0 / Float.pi }
}

extension Double {
    public var toRadian:Double { return self * Double.pi / 180.0 }
    public var toDegree:Double { return self * 180.0 / Double.pi }
}

extension Int {
    public var toRadian:Float { return Float(self) * Float.pi / 180.0 }
    public var toDegree:Float { return Float(self) * 180.0 / Float.pi }
}
