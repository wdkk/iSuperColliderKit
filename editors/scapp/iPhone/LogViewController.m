//
//  LogViewController.m
//  iPhone_Language
//
//  Created by kengo on 2014/10/18.
//
//

#import "LogViewController.h"
#import "iSCController.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (void) viewDidLoad
{
    [self.view addSubview:[iSCController logView]];
}


@end
