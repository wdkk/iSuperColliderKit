//
//  LiveCodingViewController.h
//  isclang
//
//  Created by Axel Balley on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveCodingViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) UITextView        *text_view;
@property (nonatomic, strong) UIToolbar         *tool_bar;
@property (nonatomic, strong) UIBarButtonItem   *bt_exec_file;
@property (nonatomic, strong) UIButton          *bt_done;
@property (nonatomic, strong) UIButton          *bt_exec;
@property (nonatomic, strong) id  target;
@property (nonatomic)         SEL selector;

- (void) setTarget:(id)t withSelector:(SEL)s;
- (void) loadFile:(NSString *)file;
- (void) showButtons: (BOOL)state;
- (void) triggerDone: (id)sender;
- (void) triggerExecute: (id)sender;
- (void) triggerExecuteFile: (id)sender;

@end
