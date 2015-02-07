//
//  LoggingViewController.m
//  iSCApp
//
//  Created by Kengo Watanabe on 07/02/2015.
//  Copyright Watanabe-DENKI Inc. All rights reserved.
//

#import "LoggingViewController.h"
#import "iSCController.h"

@interface LoggingViewController ()

@end

@implementation LoggingViewController

- (void) viewDidLoad
{
    [self.view addSubview:[iSCController logView]];
}


@end
