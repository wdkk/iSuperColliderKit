//
//  iSCController.h
//  iSCKit
//
//  Created by Axel Balley on 26/10/08.
//  Modified by Kengo Watanabe on 01/02/2015.
//  Copyright 2015 Watanabe-DENKI Inc. Some rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "iSCWindow.h"

typedef UITextView iSCLogView;


@interface iSCController : NSObject
{
	NSTimer         *appClockTimer;
	NSTimer         *deferredTaskTimer;
    NSMutableArray  *deferredOperations;
}

// class methods.
+ (void) setup;
+ (void) interpretC:(const char*)sc_code_char;
+ (void) interpret:(NSString *)sc_code;
+ (iSCLogView *) sharedLogView;

+ (iSCController *)sharedInstance;

// instance methods
- (void) interpretSCMessage:(NSString *)string;
   
- (void) performDeferredOperations;
- (void) removeDeferredOperationsFor:(id)object;

@end


typedef iSCController iSC;