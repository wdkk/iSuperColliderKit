//
//  iSCAppDelegate.h
//  iSCApp
//
//  Created by Kengo Watanabe on 07/02/2015.
//  Copyright Watanabe-DENKI Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iSCController.h>

#import "LoggingViewController.h"
#import "LiveViewController.h"

@interface iSCAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tab_bar_controller;

@property (nonatomic, strong) LoggingViewController *log_vc;
@property (nonatomic, strong) LiveViewController *live_vc;

@end

