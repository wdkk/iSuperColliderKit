/*
 *  iSCWindow.mm
 *  xSC3lang
 *
 *  Created by jan truetzschler on 4/12/06.
 *  Copyright (c) 2006 jan truetzschler. All rights reserved.

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
 *
 */

#import "iSCWindow.h"
#import "iSCGraphView.h"

@interface iSCWindowViewController : UIViewController
{
}
@end

@implementation iSCWindowViewController

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end

@implementation iSCWindow
- (id) initWithFrame:(CGRect)bounds
{
	if (self=[super initWithFrame:bounds])
	{
		title = 0;
		viewController = [[iSCWindowViewController alloc] init];
		viewController.view = self;
		viewController.tabBarItem.image = nil;
		[self setBackgroundColor:[UIColor grayColor]];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

- (BOOL) canBecomeKeyWindow { return YES; }

- (BOOL) hasBorders {return mHasBorders;}

- (void) setHasBorders: (BOOL) flag {mHasBorders = flag;}

- (void) setiSCGraphView: (UIView*)view {miSCGraphView = view;}

- (UIView*) getiSCGraphView {return miSCGraphView;}

- (void) setTitle:(NSString *)s
{
    // kengo:
	title = [NSString stringWithString:s];
	//viewController.title = title;
}

- (NSString *) title {return title;}

- (UIViewController *) controller { return viewController; }

- (void) close
{
    [(iSCGraphView *) miSCGraphView willClose];
	viewController = 0;
}

- (void) dealloc
{
    // kengo:
	if (viewController) viewController = nil;
}
@end
