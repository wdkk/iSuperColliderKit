//
//  isclangAppDelegate.h
//  isclang
//
//  Created by Axel Balley on 25/10/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <iSCController.h>
#import <iSCWindow.h>

#import "LoggingViewController.h"
#import "LiveViewController.h"

@interface iSCAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tab_bar_controller;

@property (nonatomic, strong) LoggingViewController *log_vc;
@property (nonatomic, strong) LiveViewController *live_vc;

+(iSCAppDelegate*) sharedInstance;

@end

