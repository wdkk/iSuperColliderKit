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
    var tv_red:TouchView?
    var tv_green:TouchView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let log_view = iSC.sharedLogView()
        log_view?.frame = CGRect(x:0, y:50, width:(log_view?.frame.width)!, height:(log_view?.frame.height)!-50)
        self.view.addSubview(log_view!)
        
        tv_blue = TouchView(frame:CGRect(x:5, y:5, width:40, height:40))
        tv_blue?.backgroundColor = .blue
        tv_blue?.touches_began = touchesBlue
        self.view.addSubview(tv_blue!)
        
        tv_red = TouchView(frame:CGRect(x:50, y:5, width:40, height:40))
        tv_red?.backgroundColor = .red
        tv_red?.touches_began = touchesRed
        self.view.addSubview(tv_red!)
        
        tv_green = TouchView(frame:CGRect(x:200, y:5, width:40, height:40))
        tv_green?.backgroundColor = .green
        tv_green?.touches_began = touchesGreen
        self.view.addSubview(tv_green!)
        
        iSC.setRenderCallback { waves, count, time in
            print( time )
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func touchesBlue(touches: Set<UITouch>, with event: UIEvent?)
    {
        iSC.interpret("a = {SinOsc.ar()}.play")
    }
    
    func touchesRed(touches: Set<UITouch>, with event: UIEvent?)
    {
        iSC.interpret("a.free")
    }
    
    func touchesGreen(touches: Set<UITouch>, with event: UIEvent?)
    {
        iSC.outputSpeaker()
    }
}

