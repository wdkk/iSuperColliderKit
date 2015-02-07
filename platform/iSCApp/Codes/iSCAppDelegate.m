//
//  isclangAppDelegate.m
//  isclang
//
//  Created by Axel Balley on 25/10/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "iSCAppDelegate.h"

@implementation iSCAppDelegate

@synthesize window;

+(iSCAppDelegate*) sharedInstance
{
    return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ウィンドウの作成
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.log_vc = [[LoggingViewController alloc] initWithNibName:nil bundle:nil];
    self.log_vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Log"
                                                            image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.live_vc = [[LiveViewController alloc] initWithNibName:nil bundle:nil];
    self.live_vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Live"
                                                            image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // タブバーコントローラの作成
    self.tab_bar_controller = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [self.tab_bar_controller setViewControllers:@[self.log_vc, self.live_vc] animated:YES];
    [self.tab_bar_controller setCustomizableViewControllers:nil];
    
    iSCController *scc = [iSCController sharedInstance];
    [scc setup];    
    
    // Override point for customization after application launch
    self.window.rootViewController = self.tab_bar_controller;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
