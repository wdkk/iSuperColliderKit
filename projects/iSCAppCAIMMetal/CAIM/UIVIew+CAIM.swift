//
// UIView+CAIM.swift
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

public extension UIView
{
    var pixelX:CGFloat {
        get { return self.frame.origin.x * UIScreen.main.scale }
        set { self.frame.origin.x = newValue / UIScreen.main.scale }
    }
    var pixelY:CGFloat {
        get { return self.frame.origin.y * UIScreen.main.scale }
        set { self.frame.origin.y = newValue / UIScreen.main.scale }
    }
    var pixelWidth:CGFloat {
        get { return self.frame.size.width * UIScreen.main.scale }
        set { self.frame.size.width = newValue / UIScreen.main.scale }
    }
    var pixelHeight:CGFloat {
        get { return self.frame.size.height * UIScreen.main.scale }
        set { self.frame.size.height = newValue / UIScreen.main.scale }
    }
    var pixelFrame:CGRect {
        get { return CGRect(x: pixelX, y: pixelY, width: pixelWidth, height: pixelHeight) }
        set {
            self.frame = CGRect( x: newValue.origin.x / UIScreen.main.scale,
                                 y: newValue.origin.y / UIScreen.main.scale,
                                 width: newValue.size.width / UIScreen.main.scale,
                                 height: newValue.size.height / UIScreen.main.scale )
        }
    }
    var pixelBounds:CGRect {
        get { return CGRect(x: bounds.origin.x * UIScreen.main.scale,
                            y: bounds.origin.y * UIScreen.main.scale,
                            width: bounds.size.width * UIScreen.main.scale,
                            height: bounds.size.height * UIScreen.main.scale)
        }
        set {
            self.bounds = CGRect( x: newValue.origin.x / UIScreen.main.scale,
                                  y: newValue.origin.y / UIScreen.main.scale,
                                  width: newValue.size.width / UIScreen.main.scale,
                                  height: newValue.size.height / UIScreen.main.scale )
        }
    }
}
