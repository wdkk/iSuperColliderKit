//
//  ViewController.swift
//  iSCAppSwift
//
//  Created by kengo on 2015/02/07.
//  Copyright (c) 2015 Watanabe-DENKI Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tv_blue:TouchView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        //self.view.addSubview(iSC.sharedLogView())
        
        tv_blue = TouchView(frame:CGRectMake(40, 100, 80, 80))
        tv_blue?.backgroundColor = UIColor.blueColor()
        tv_blue?.touches_began = touchesBlue
        self.view.addSubview(tv_blue!);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func touchesBlue()
    {
        iSC.interpret("a = {SinOsc.ar()}.play");
    }
}

