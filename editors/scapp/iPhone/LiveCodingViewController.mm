//
//  LiveCodingViewController.m
//  isclang
//
//  Created by Axel Balley on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LiveCodingViewController.h"

extern int rtf2txt(char *txt);  // void -> int

@implementation LiveCodingViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.target = nil;
		self.selector = nil;
	}
	return self;
}

- (void) viewDidLoad
{
    float wid = self.view.frame.size.width;
    float hgt = self.view.frame.size.height;
    float tool_hgt = 44;
    float tab_hgt = 49;
    
    
    self.text_view = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, wid, hgt-tool_hgt-tab_hgt)];
    self.text_view.delegate = self;
	[self.text_view setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[self.text_view setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.view addSubview:self.text_view];
    
    self.tool_bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, hgt-tool_hgt-tab_hgt, wid, tool_hgt)];
    [self.view addSubview:self.tool_bar];
    
    self.bt_exec_file = [[UIBarButtonItem alloc] initWithTitle:@"Exec File" style:UIBarButtonItemStyleDone target:self action:@selector(triggerExecuteFile:)];
    [self.tool_bar setItems:@[self.bt_exec_file]];
    
    self.bt_done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.bt_done.frame = CGRectMake(160, 200, 80, 40);
    [self.bt_done setTitle:@"Done" forState:UIControlStateNormal];
    [self.bt_done addTarget:self action:@selector(triggerDone:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.bt_done];
    
    self.bt_exec = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.bt_exec.frame = CGRectMake(240, 200, 80, 40);
    [self.bt_exec setTitle:@"Execute" forState:UIControlStateNormal];
    [self.bt_exec addTarget:self action:@selector(triggerExecute:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.bt_exec];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[self showButtons:NO];
}

- (void) keyboardDidShow:(NSNotification *) notif
{
	NSDictionary *info = [notif userInfo];
	NSValue *val = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect r = [val CGRectValue];
	
	CGRect done_frame = self.bt_done.frame;
	CGRect exec_frame = self.bt_exec.frame;
	
	r = [self.view convertRect:r fromView:nil];
				
	done_frame.origin.y = r.origin.y - done_frame.size.height - 10;
	exec_frame.origin.y = done_frame.origin.y;
	
	[self.bt_done setFrame:done_frame];
	[self.bt_exec setFrame:exec_frame];
    
	[self showButtons:YES];
}

- (void) keyboardWillHide:(NSNotification *) notif
{
	[self showButtons:NO];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void) setTarget:(id)t withSelector:(SEL)s
{
	self.target = t;
	self.selector = s;
}

- (void) loadFile:(NSString *)file
{
	NSString *contents = [NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:nil];
	int length = (int)[contents length];    // kengo:
	char *buf = (char *) malloc(length+1);
	[contents getCString:buf maxLength:length+1 encoding:NSASCIIStringEncoding];
	rtf2txt(buf);
    while (*buf=='\n') { buf++; }
	
	self.text_view.text = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
}

- (void) showButtons: (BOOL)state
{
	[self.bt_done setHidden:!state];
	[self.bt_exec setHidden:!state];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"TextView should begin editing");
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"TextView should end editing");
    return YES;
}

- (void) textViewDidBeginEditing: (UITextView *)textView
{
    NSLog(@"TextView did begin editing");
	[self showButtons:YES];
}

-(void) textViewDidEndEditing:(UITextView*)textView
{
    NSLog(@"TextView did end editing");
}

- (void)triggerDone:(id)sender
{
	//[self.text_view resignFirstResponder];
    [self.view endEditing:YES];
	[self showButtons:NO];
}

- (void)triggerExecute:(id)sender
{
	NSRange range = [self.text_view selectedRange];
	NSString *text = [self.text_view text];
	NSUInteger start, end;
	[text getLineStart:&start end:&end contentsEnd:nil forRange:range];
	NSString *line = [text substringWithRange:NSMakeRange(start, end-start)];
// kengo:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if (self.target && [self.target respondsToSelector:self.selector])
    {
        [self.target performSelector:self.selector withObject:line];
	}
#pragma clang diagnostic pop
    
	[self.text_view resignFirstResponder];
	//[self showButtons:NO];
}

- (void)triggerExecuteFile:(id)sender
{
// kengo:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSLog(@"Execute File");
	if (self.target && [self.target respondsToSelector:self.selector])
    {
        [self.target performSelector:self.selector withObject:[self.text_view text]];
    }
#pragma clang diagnostic pop
}

// kengo: deleting dealloc.


@end
