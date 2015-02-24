/************************************************************************
 *
 * Copyright 2015 Kengo Watanabe <kengo@wdkk.co.jp>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ************************************************************************/

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