//
//  iSCAppDelegate.m
//  iSCApp
//
//  Created by Kengo Watanabe on 07/02/2015.
//  Copyright Watanabe-DENKI Inc. All rights reserved.
//

#import "iSCAppDelegate.h"

@implementation iSCAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Generate Window and ViewControllers
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Boot iSCKit Controller
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
