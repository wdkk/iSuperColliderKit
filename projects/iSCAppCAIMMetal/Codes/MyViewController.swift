//
//  MyViewController.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/13.
//  Copyright Watanabe-DENKI Inc. All rights reserved.
//

import UIKit

class MyViewController : CAIMViewController
{
    var metal_view:MyMetalView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ev_update = self.update
        
        // setup iSCKit
        iSC.setup()
        // Boot Supercollider.
        iSC.interpret("s.boot")
        
        metal_view = MyMetalView(frame: self.view.bounds)
        self.view.addSubview(metal_view)
    }
    
    func update(vc:CAIMViewController)
    {
        metal_view.redraw()
        CAIMFPS()
    }
}

