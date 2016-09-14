//
// CAIMFPS.swift
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

// 現在のシステム時間のmsを返す
public func CAIMNow() -> UInt
{
    var now_time:timeval = timeval()
    var tzp:timezone = timezone()
    
    gettimeofday(&now_time, &tzp)
        
    return (UInt(now_time.tv_sec) * 1000 + UInt(now_time.tv_usec) / 1000)
}

// 秒間のFPSを計測する（ループ内で使う）
public func CAIMFPS()
{
    struct variables
    {
        static var is_started:Bool = false
        static var time_span:UInt = 0
        static var fps:UInt32 = 0
    }
    
    if (!variables.is_started)
    {
        variables.is_started = true
        variables.time_span = CAIMNow()
        variables.fps = 0
    }
        
    if (CAIMNow() - variables.time_span >= 1000)
    {
        print("CAIM: \(variables.fps)(fps)")
        variables.time_span = CAIMNow()
        variables.fps = 0
    }
        
    variables.fps += 1
}