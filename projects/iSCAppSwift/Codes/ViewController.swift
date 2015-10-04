/*

iSuperCollider Kit (iSCKit) - SuperCollider for iOS 7 later
Copyright (c) 2015 Kengo Watanabe <kengo@wdkk.co.jp>. All rights reserved.
http://wdkk.co.jp/

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/


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

