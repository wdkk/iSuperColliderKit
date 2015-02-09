//
//  iSCTestAppDelegate.h
//  iSCTestApp
//
//  Created by Kengo Watanabe on 07/02/2015.
//  Copyright Watanabe-DENKI Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "LogViewController.h"
#import "LiveCodingViewController.h"
#import "iSCController.h"
#import "iSCWindow.h"

@interface iSCTestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tab_bar_controller;

@property (nonatomic, strong) LogViewController *log_vc;
@property (nonatomic, strong) LiveCodingViewController *live_vc;

+(iSCTestAppDelegate*) sharedInstance;

@end

