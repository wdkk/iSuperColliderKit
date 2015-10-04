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

#import <UIKit/UIKit.h>
#import <iSCKit/iSCKit.h>

#import "LoggingViewController.h"
#import "LiveViewController.h"

@interface iSCAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tab_bar_controller;

@property (nonatomic, strong) LoggingViewController *log_vc;
@property (nonatomic, strong) LiveViewController *live_vc;

@end

