//
// CAIMUtil.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//


import Foundation

// init()を必ず持つようにするためのプロトコル
protocol Initializable
{
    init()
}

// バンドル画像のパスを返す
public func CAIMBundle(_ file_path:String) -> String {
    let path:String! = Bundle.main.resourcePath
    return (path! + "/" + file_path)
}

// 現在のシステム時間のmsを返す
public func CAIMNow() -> Int64 {
    var now_time:timeval = timeval()
    var tzp:timezone = timezone()
    
    gettimeofday(&now_time, &tzp)
    
    return (Int64(now_time.tv_sec) * 1000 + Int64(now_time.tv_usec) / 1000)
}

// 秒間のFPSを計測する（ループ内で使う）
public func CAIMFPS() {
    struct variables {
        static var is_started:Bool = false
        static var time_span:Int64 = 0
        static var fps:UInt32 = 0
    }
    
    if (!variables.is_started) {
        variables.is_started = true
        variables.time_span = CAIMNow()
        variables.fps = 0
    }
    
    let dt:Int64 = CAIMNow() - variables.time_span
    if (dt >= 1000) {
        print("CAIM: \(variables.fps)(fps)")
        variables.time_span = CAIMNow()
        variables.fps = 0
    }
    
    variables.fps += 1
}

// ランダム値の計算
public func CAIMRandom(_ max:Float32=1.0) -> Float32 { return Float32(arc4random() % 1000) / 1000.0 * max }
public func CAIMRandom(_ max:Int32) -> Float32 { return Float32(arc4random() % 1000) / 1000.0 * Float32(max) }
public func CAIMRandom(_ max:Int) -> Float32 { return Float32(arc4random() % 1000) / 1000.0 * Float32(max) }

// スクリーンサイズの取得
public var CAIMScreenPixel:CGSize {
    let sc:CGFloat = UIScreen.main.scale
    let size:CGSize = UIScreen.main.bounds.size
    let wid = size.width * sc
    let hgt = size.height * sc
    return CGSize(width:wid, height:hgt)
}
