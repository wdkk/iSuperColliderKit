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
    float wid = self.view.frame.size.width;
    float hgt = self.view.frame.size.height;
    float tab_hgt = 49;
    
    self.log_view = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, wid, hgt-tab_hgt)];
    self.log_view.delegate = self;
    self.log_view.textColor = [UIColor blueColor];
    self.log_view.font = [UIFont systemFontOfSize:10.0];
    [self.log_view setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.log_view setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.log_view];
}


@end
