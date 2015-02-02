//
//  LogViewController.h
//  iPhone_Language
//
//  Created by kengo on 2014/10/18.
//
//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController<UITextViewDelegate>

@property (nonatomic,strong) UITextView *log_view;
@property (nonatomic,strong) UIToolbar  *tool_bar;
@property (nonatomic,strong) UIBarButtonItem *bt_speaker;

@end
