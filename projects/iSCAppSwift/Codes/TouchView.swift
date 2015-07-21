//
//  TouchView.swift
//  iSCAppSwift
//
//  Created by kengo on 2015/02/09.
//  Copyright (c) 2015年 Watanabe-DENKI Inc. All rights reserved.
//

import Foundation
import UIKit

class TouchView : UIView
{
    var touches_began: ()->Void = {}
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        touches_began()
    }
}