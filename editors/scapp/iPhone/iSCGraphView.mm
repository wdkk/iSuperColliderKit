/*
	SuperCollider real time audio synthesis system
    Copyright (c) 2002 James McCartney. All rights reserved.
	http://www.audiosynth.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import "iSCGraphView.h"
#import "iSCController.h"
#include "PyrInterpreter.h"
#include "PyrKernel.h"
#include "PyrMessage.h"
#include "VMGlobals.h"
#include "PyrSched.h"
#include "SC_BoundsMacros.h"
#include "GC.h"
#import <UIKit/UIKit.h>

extern PyrSymbol *s_draw;
extern PyrSymbol *s_scview;
extern PyrSymbol *s_closed;
extern PyrSymbol *s_callDrawFunc;
extern PyrSymbol *s_toggleEditMode;

@implementation iSCGraphView

- (void)setAcceptsClickThrough:(BOOL)boo
{
	acceptsClickThrough = boo;
}

- (void)setAutoScrolls:(BOOL)boo;
{
	autoScrolls = boo;
}

// kengo:reborn
- (BOOL)isFlipped
{
	return YES;
}

// kengo:reborn
- (BOOL)mouseDownCanMoveWindow
{
	return NO;
}

static CGRect SCtoCGRect(SCRect screct)
{
    CGRect nsrect;
    nsrect.origin.x = screct.x;
    nsrect.origin.y = screct.y;
    nsrect.size.width = screct.width;
    nsrect.size.height = screct.height;
    return nsrect;
}

//static NSString *sSCObjType = @"SuperCollider object address";    // kengo:comment out

- (id)initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
	mDragStarted = NO;
	mMenuView = 0;
	mWindowObj = 0;
	mTopView = 0;
    windowShouldClose = YES;
	acceptsClickThrough = YES;
	autoScrolls = YES;
	[self setBackgroundColor:[UIColor whiteColor]];
    return self;
}

- (void) touch:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{	
		CGPoint mouseLoc;
		if (!mTopView) return;
		mouseLoc = [touch locationInView:self];
		SCPoint scpoint = SCMakePoint(mouseLoc.x, mouseLoc.y);
		SCView *view = mTopView->findView(scpoint);
		if (view)
		{
			mDragStarted = NO;
			mMenuView = 0;
			view->makeFocus(true);
			bool constructionmode = mTopView->ConstructionMode();
			if(!constructionmode)
			{
				UITouchPhase phase = [touch phase];
				if (phase==UITouchPhaseBegan)
				{
					view->touchDownAction(scpoint, touch);
					view->touchBeginTrack(scpoint, touch);
				}
				else if (phase==UITouchPhaseMoved)
				{
					view->touchTrack(scpoint, touch);
					view->touchMoveAction(scpoint, touch);
				}
				else if (phase==UITouchPhaseEnded)
				{
					view->touchUpAction(scpoint, touch);
					view->touchEndTrack(scpoint, touch);			
				}
			}
		}
	}	
	
	mMenuView = 0;
    return;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touch:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[self touch:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[self touch:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
	printf("touches cancelled\n");
}

- (void)setSCObject: (struct PyrObject*)inObject;
{
    mWindowObj = inObject;
}
    
- (struct PyrObject*)getSCObject
{
    return mWindowObj;
}

void damageFunc(SCRect inRect, void* inData)
{
    iSCGraphView *view = (__bridge iSCGraphView*)inData;
    
    [view setNeedsDisplayInRect: SCtoCGRect(inRect)];
}

void dragFunc(SCPoint where, PyrSlot *inSlot, NSString* inString, NSString* label, void* inData)
{
    iSCGraphView *view = (__bridge iSCGraphView*)inData;
    CGPoint point = CGPointMake(where.x, where.y);
    [view beginDragFrom:point of:inSlot string:inString/*label:label*/];    // kengo:
}


- (void) beginDragFrom: (CGPoint)where of: (PyrSlot*)slot string:(NSString*)string
{
    NSLog(@"iiSCGraphViewのbeginDragFrom:of:stringが呼ばれましたが、処理をスキップします");
}

- (void)setSCTopView: (SCTopView*)inView
{
    mTopView = inView;
    mTopView->setDamageCallback(damageFunc, (__bridge void*)self);  // kengo:
    mTopView->setDragCallback(dragFunc);
	mTopView->SetUIView(self);
}

- (void)dealloc
{
	//printf("dealloc %08X mTopView %08X\n", self, mTopView);
    delete mTopView;
	mTopView = 0;
}


- (void)closeWindow
{
	iSCWindow *w = (iSCWindow*)[self superview];  // kengo:casting.
	[w close];
}

- (void)removeFromSuperview
{
	[[iSCController sharedInstance] removeDeferredOperationsFor: self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super removeFromSuperview];
}

- (void)willClose
{    
	[[iSCController sharedInstance] removeDeferredOperationsFor: self];
	[[iSCController sharedInstance] removeDeferredOperationsFor: [self window]];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    pthread_mutex_lock (&gLangMutex);
    if (mWindowObj) {
        SetPtr(mWindowObj->slots + 0, (__bridge void*)self);    // kengo:
        VMGlobals *g = gMainVMGlobals;
        g->canCallOS = true;
        ++g->sp;  SetObject(g->sp, mWindowObj); // push window obj
        runInterpreter(g, s_closed, 1);
        g->canCallOS = false;
        mWindowObj = 0;
    }
    pthread_mutex_unlock (&gLangMutex);
    
    delete mTopView;
	mTopView = 0;
}

/*  from command-w, scvm is the delegate */
- (void)setWindowShouldClose:(BOOL)boo
{
    windowShouldClose = boo;
}

- (BOOL)windowShouldClose
{
    return windowShouldClose;
}

- (void)drawRect: (CGRect)drawBounds
{
	if (mTopView) {
        
        SCRect screct;
        
		CGRect bounds = [self bounds];
		screct.x = bounds.origin.x;
		screct.y = bounds.origin.y;
		screct.width = bounds.size.width;
		screct.height = bounds.size.height;
		mTopView->setInternalBounds(screct);
        
        screct.x = drawBounds.origin.x;
        screct.y = drawBounds.origin.y;
        screct.width = drawBounds.size.width;
        screct.height = drawBounds.size.height;
	
		if(mTopView->isSubViewScroller()) {
			((SCScrollView*)mTopView)->drawSubViewIfNecessary(screct);
		} else {
			mTopView->drawIfNecessary(screct);
		} 
	   }
    pthread_mutex_lock (&gLangMutex);
    if (mWindowObj && NotNil(mWindowObj->slots+6)) {
        CGRect cgrect = *(CGRect*)&drawBounds;
        CGContextRef cgc = (CGContextRef)UIGraphicsGetCurrentContext();
        CGContextSaveGState(cgc);
        CGContextClipToRect(cgc, cgrect);

        VMGlobals *g = gMainVMGlobals;
        g->canCallOS = true;
        ++g->sp;  SetObject(g->sp, mWindowObj); // push window obj
        runInterpreter(g, s_callDrawFunc, 1);
        g->canCallOS = false;

        CGContextRestoreGState(cgc);
    }
    pthread_mutex_unlock (&gLangMutex);
}

int nsStringDrawInRect(NSString *string, SCRect screct, char *cFontName, float fontSize, SCColor sccolor)
{
    [string drawInRect:CGRectMake(screct.x, screct.y, screct.width, screct.height)
        withAttributes:@{
                         NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                         NSForegroundColorAttributeName:[UIColor colorWithRed:sccolor.red
                                                                        green:sccolor.green
                                                                         blue:sccolor.blue
                                                                        alpha:sccolor.alpha]}
     ];
    
    return errNone;
}

CGSize nsStringSize(NSString *nsstring, char *cFontName, float fontSize, SCColor sccolor)
{
	return CGSizeMake(0,0);
}

int nsStringDrawInRectAlign(NSString *nsstring, SCRect screct, char *cFontName, float fontSize, SCColor sccolor, 
	int hAlign, int vAlign, CGSize *outSize)
{
	return nsStringDrawInRect(nsstring, screct, cFontName, fontSize, sccolor);
}


int stringDrawInRect(char *cString, SCRect screct, char *cFontName, float fontSize, SCColor sccolor)
{
	NSString *nsstring = [NSString stringWithUTF8String: cString];
	return nsStringDrawInRect(nsstring, screct, cFontName, fontSize, sccolor);
}

int stringDrawCenteredInRect(char *cString, SCRect screct, char *cFontName, float fontSize, SCColor sccolor)
{
	NSString *nsstring = [NSString stringWithUTF8String: cString];
	return nsStringDrawInRectAlign(nsstring, screct, cFontName, fontSize, sccolor, 0, 0, NULL);
}

int stringDrawLeftInRect(char *cString, SCRect screct, char *cFontName, float fontSize, SCColor sccolor)
{
	NSString *nsstring = [NSString stringWithUTF8String: cString];
	return nsStringDrawInRectAlign(nsstring, screct, cFontName, fontSize, sccolor, -1, 0, NULL);
}

int stringDrawRightInRect(char *cString, SCRect screct, char *cFontName, float fontSize, SCColor sccolor)
{
	NSString *nsstring = [NSString stringWithUTF8String: cString];
	return nsStringDrawInRectAlign(nsstring, screct, cFontName, fontSize, sccolor, 1, 0, NULL);
}


SCColor blendColor(float blend, SCColor a, SCColor b)
{
   SCColor c;
   c.red = a.red + blend * (b.red - a.red);
   c.green = a.green + blend * (b.green - a.green);
   c.blue = a.blue + blend * (b.blue - a.blue);
   c.alpha = a.alpha + blend * (b.alpha - a.alpha);
   return c;
}

void vPaintGradient(CGContextRef cgc, CGRect bounds, SCColor startColor, SCColor endColor, int numSteps)
{
    numSteps = (int)sc_min(numSteps, floor(bounds.size.height));
    float rNumSteps1 = 1. / (numSteps - 1.);
    
    CGRect rect;
    rect.origin.x    = bounds.origin.x;
    rect.size.width  = bounds.size.width;
    float step = bounds.size.height / numSteps;
    rect.size.height = ceil(step);
    
    for (int i=0; i<numSteps; ++i) {
        float blend = i * rNumSteps1;
        SCColor color = blendColor(blend, startColor, endColor);
        CGContextSetRGBFillColor(cgc, color.red, color.green, color.blue, color.alpha);

        rect.origin.y = bounds.origin.y + floor(i * step);
        rect.size.height = ceil(bounds.origin.y + (i + 1) * step) - rect.origin.y;
        
        CGContextFillRect(cgc, rect);
    }
}

void hPaintGradient(CGContextRef cgc, CGRect bounds, SCColor startColor, SCColor endColor, int numSteps)
{
    numSteps = (int)sc_min(numSteps, floor(bounds.size.width));
    float rNumSteps1 = 1. / (numSteps - 1.);
    
    CGRect rect;
    rect.origin.y    = bounds.origin.y;
    rect.size.height = bounds.size.height;
    float step = bounds.size.width / numSteps;
    rect.size.width = ceil(step);
    
    for (int i=0; i<numSteps; ++i) {
        float blend = i * rNumSteps1;
        SCColor color = blendColor(blend, startColor, endColor);
        CGContextSetRGBFillColor(cgc, color.red, color.green, color.blue, color.alpha);

        rect.origin.x = bounds.origin.x + floor(i * step);
        rect.size.width = ceil(bounds.origin.x + (i + 1) * step) - rect.origin.x;
       
        CGContextFillRect(cgc, rect);
    }
}

void QDDrawBevelRect(CGContextRef cgc, CGRect bounds, float width, bool inout)
{
    if (inout) {
        CGContextSetRGBFillColor(cgc, 0, 0, 0, 0.5);
    } else {
        CGContextSetRGBFillColor(cgc, 1, 1, 1, 0.5);
    }
    CGContextMoveToPoint(cgc, bounds.origin.x, bounds.origin.y);
    CGContextAddLineToPoint(cgc, bounds.origin.x + bounds.size.width, bounds.origin.y);
    CGContextAddLineToPoint(cgc, bounds.origin.x + bounds.size.width - width, bounds.origin.y + width);
    CGContextAddLineToPoint(cgc, bounds.origin.x + width, bounds.origin.y + width);
    CGContextAddLineToPoint(cgc, bounds.origin.x + width, bounds.origin.y + bounds.size.height - width);
    CGContextAddLineToPoint(cgc, bounds.origin.x, bounds.origin.y + bounds.size.height);
    CGContextAddLineToPoint(cgc, bounds.origin.x, bounds.origin.y);
    CGContextFillPath(cgc);

    if (inout) {
        CGContextSetRGBFillColor(cgc, 1, 1, 1, 0.5);
    } else {
        CGContextSetRGBFillColor(cgc, 0, 0, 0, 0.5);
    }
    CGContextMoveToPoint(cgc, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
    CGContextAddLineToPoint(cgc, bounds.origin.x, bounds.origin.y + bounds.size.height);
    CGContextAddLineToPoint(cgc, bounds.origin.x + width, bounds.origin.y + bounds.size.height - width);
    CGContextAddLineToPoint(cgc, 
        bounds.origin.x + bounds.size.width - width, bounds.origin.y + bounds.size.height - width);
    CGContextAddLineToPoint(cgc, bounds.origin.x + bounds.size.width - width, bounds.origin.y + width);
    CGContextAddLineToPoint(cgc, bounds.origin.x + bounds.size.width, bounds.origin.y);
    CGContextAddLineToPoint(cgc, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
    CGContextFillPath(cgc);    
}

- (void)startMenuTracking: (SCView*) inView
{
	mMenuView = inView;
}

- (void)scrollViewResized:(NSNotification *)notification
{

}

extern PyrSymbol* s_doaction;

- (void)userScrolled:(NSNotification *)notification
{
	// if this happens from a visibleOrigin method we can't use sendMessage, so the action gets called from the lang
	// similarly, this blocks the action from being fired due to scrolling because of incidental resize (i.e. remove a child)
	if(!((SCScrollTopView*)mTopView)->isInSetClipViewOrigin()) {
		mTopView->sendMessage(s_doaction, 0, 0, 0); // this must be a scroll view
	}
}
@end
