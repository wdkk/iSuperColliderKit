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


#import "ViewController.h"
#import "TouchView.h"
#import <iSCKit/iSCKit.h>


@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad
{
    // use iSCKit Log View. it's controlled iSC Class.
    iSCLogView *log_view = [iSC sharedLogView];
    log_view.frame = CGRectMake(0, 50, log_view.frame.size.width, log_view.frame.size.height-50);
    [self.view addSubview:log_view];
    
    // create TouchView(Blue) that call Sine cave playing code
    TouchView *touch_blue = [[TouchView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    touch_blue.backgroundColor = [UIColor blueColor];
    touch_blue.delegate = self;
    touch_blue.ev_touches_began = @selector(touchesBlue:withEvent:);
    [self.view addSubview:touch_blue];
    
    // create TouchView(Red) that call Sine cave playing code
    TouchView *touch_red = [[TouchView alloc] initWithFrame:CGRectMake(50, 5, 40, 40)];
    touch_red.backgroundColor = [UIColor redColor];
    touch_red.delegate = self;
    touch_red.ev_touches_began = @selector(touchesRed:withEvent:);
    [self.view addSubview:touch_red];
}

// Touch Event of touch_blue object.
- (void) touchesBlue:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // interpret "Supercollider Code" using iSCKit.
    [iSC interpret:@"a = {SinOsc.ar()}.play"];
}


// Touch Event of touch_red object.
- (void) touchesRed:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // interpret "Supercollider Code" using iSCKit.
    [iSC interpret:@"a.free"];
}

@end
