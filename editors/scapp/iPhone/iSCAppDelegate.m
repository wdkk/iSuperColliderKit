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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ウィンドウの作成
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.log_vc = [[LogViewController alloc] initWithNibName:nil bundle:nil];
    self.log_vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Post"
                                                            image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.browser_navi = [[FileBrowserNavigationController alloc] initWithNibName:nil bundle:nil];
    self.browser_navi.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Browser"
                                                                 image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                         selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    self.live_vc = [[LiveCodingViewController alloc] initWithNibName:nil bundle:nil];
    self.live_vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Live"
                                                            image:[[UIImage imageNamed:@"tab_login"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[[UIImage imageNamed:@"tab_login_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    // タブバーコントローラの作成
    self.tab_bar_controller = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    [self.tab_bar_controller setViewControllers:@[self.log_vc, self.browser_navi, self.live_vc] animated:YES];
    
    iSCController *cont = [iSCController sharedInstance];
    [cont setup];
    
    // Override point for customization after application launch
    self.window.rootViewController = self.tab_bar_controller;
	
    [self.window makeKeyAndVisible];
    
    return YES;
}

+(iSCAppDelegate*) sharedInstance
{
    return [UIApplication sharedApplication].delegate;
}

@end
