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
#import "iSCAppDelegate.h"

@interface iSCController : NSObject
{
	UInt32 routeOverride;
	NSTimer *appClockTimer;
	NSTimer *deferredTaskTimer;
    NSMutableArray *deferredOperations;
	MPMoviePlayerController *recordingPlayer;
}

@property UInt32 routeOverride;

+ (iSCController *) sharedInstance;

- (void) setup;

- (void) start:(id)arg;
- (void) selectFile:(NSString *)string;
- (void) selectPatch:(NSString *)string;
- (void) selectRecording:(NSString *)string;
- (void) interpret:(NSString *)string;
- (void) doClockTask:(NSTimer*) timer;

- (void) triggerStop:(id)sender;
- (void) toggleSpeakers:(id)sender;

- (void) insertWindow:(iSCWindow *)window;
- (void) makeWindowFront:(iSCWindow *)window;
- (void) closeWindow:(iSCWindow *)window;
- (void) defer: (NSInvocation*) action;
- (void) performDeferredOperations;
- (void) removeDeferredOperationsFor:(id)object;

@end
