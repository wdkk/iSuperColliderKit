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
    float tool_hgt = 44;
    float tab_hgt = 49;
    
    iSCController *cont = [iSCController sharedInstance];
    
    self.log_view = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, wid, hgt-tool_hgt-tab_hgt)];
    self.log_view.delegate = self;
    self.log_view.textColor = [UIColor blueColor];
    self.log_view.font = [UIFont systemFontOfSize:10.0];
    [self.log_view setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.log_view setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.log_view];
    
    self.tool_bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, hgt-tool_hgt-tab_hgt, wid, tool_hgt)];
    [self.view addSubview:self.tool_bar];
    
    self.bt_speaker = [[UIBarButtonItem alloc] initWithTitle:@"Speakers" style:UIBarButtonItemStyleDone target:cont
                                                      action:@selector(triggerSpeaker:)];
    [self.tool_bar setItems:@[self.bt_speaker]];

    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


@end
