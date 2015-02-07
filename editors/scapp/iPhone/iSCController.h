//
//  iSCController.h
//  isclang
//
//  Created by Axel Balley on 26/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "iSCWindow.h"

@class iSCLogView;

@interface iSCController : NSObject
{
	NSTimer         *appClockTimer;
	NSTimer         *deferredTaskTimer;
    NSMutableArray  *deferredOperations;
    iSCLogView      *log_view;
}

+ (iSCController *) sharedInstance;
+ (iSCLogView *)    logView;

- (void) setup;
- (void) start;
- (void) interpret:(NSString *)string;

- (void) performDeferredOperations;
- (void) removeDeferredOperationsFor:(id)object;

@end

@interface iSCLogView : UITextView

@end
