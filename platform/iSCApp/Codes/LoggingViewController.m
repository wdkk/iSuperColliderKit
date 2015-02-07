//
//  LoggingViewController.m
//  iSCApp
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
