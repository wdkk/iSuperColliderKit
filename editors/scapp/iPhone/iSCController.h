//
//  iSCController.h
//  isclang
//
//  Created by Axel Balley on 26/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FileBrowserNaviController.h"
#import "LiveCodingViewController.h"
#import "iSCWindow.h"

@interface iSCController : NSObject
{
	NSTimer *appClockTimer;
	NSTimer *deferredTaskTimer;
    NSMutableArray *deferredOperations;
	MPMoviePlayerController *recordingPlayer;
}

+ (iSCController *) sharedInstance;

- (void) setup;

- (void) start;
- (void) interpret:(NSString *)string;
- (void) doClockTask:(NSTimer*)timer;

- (void) performDeferredOperations;
- (void) removeDeferredOperationsFor:(id)object;

@end
