//
// CAIMColor+CAIM.swift
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

public struct CAIMColor {
    var R, G, B, A:Float

    init() {
        self.R = 0.0; self.G = 0.0; self.B = 0.0; self.A = 1.0;
    }
    
    init(R:Float, G:Float, B:Float, A:Float) {
        self.R = R; self.G = G; self.B = B; self.A = A;
    }
    
    init(_ red:Float, _ green:Float, _ blue:Float, _ alpha:Float) {
        R = red; G = green; B = blue; A = alpha;
    }
    
    static var clear:CAIMColor { return CAIMColor(0.0, 0.0, 0.0, 0.0) }
    static var black:CAIMColor { return CAIMColor(0.0, 0.0, 0.0, 1.0) }
    static var white:CAIMColor { return CAIMColor(1.0, 1.0, 1.0, 1.0) }
    static var red:CAIMColor   { return CAIMColor(1.0, 0.0, 0.0, 1.0) }
    static var green:CAIMColor { return CAIMColor(0.0, 1.0, 0.0, 1.0) }
    static var blue:CAIMColor  { return CAIMColor(0.0, 0.0, 1.0, 1.0) }
    static var yellow:CAIMColor{ return CAIMColor(1.0, 1.0, 0.0, 1.0) }
    static var cyan:CAIMColor  { return CAIMColor(0.0, 1.0, 1.0, 1.0) }
    static var magenta:CAIMColor { return CAIMColor(1.0, 0.0, 1.0, 1.0) }
}

public func == (left:CAIMColor, right:CAIMColor) -> Bool {
    return (left.A == right.A) && (left.G == right.G) && (left.B == right.B) && (left.A == right.A)
}

public func != (left:CAIMColor, right:CAIMColor) -> Bool {
    return !((left.A == right.A) && (left.G == right.G) && (left.B == right.B) && (left.A == right.A))
}

typealias CAIMColorPtr = UnsafeMutablePointer<CAIMColor>
typealias CAIMColorMatrix = UnsafeMutablePointer<CAIMColorPtr>
typealias CAIMBytePtr = UnsafeMutablePointer<UInt8>

public struct CAIMColor8 {
    var R, G, B, A:UInt8
}
typealias CAIMColor8Ptr = UnsafeMutablePointer<CAIMColor8>
