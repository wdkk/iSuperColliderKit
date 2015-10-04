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

#import "iSCAppDelegate.h"

@implementation iSCAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Generate Window and ViewControllers
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Boot iSCKit Controller before using iSC log view.
    [iSC setup];
    
    self.log_vc = [[LoggingViewController alloc] initWithNibName:nil bundle:nil];
    self.log_vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Log"
                                                            image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.live_vc = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    self.live_vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Live"
                                                            image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // Generate Tab bar controller.
    self.tab_bar_controller = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [self.tab_bar_controller setViewControllers:@[self.log_vc, self.live_vc] animated:YES];
    [self.tab_bar_controller setCustomizableViewControllers:nil];
    
    // Override point for customization after application launch
    self.window.rootViewController = self.tab_bar_controller;
    [self.window makeKeyAndVisible];
    
    // boot SuperCollider
    [iSC interpret:@"s.boot"];
    
    return YES;
}

@end
