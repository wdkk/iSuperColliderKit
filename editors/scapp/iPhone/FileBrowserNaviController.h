//
//  FileBrowser.h
//  iscsynth
//
//  Created by Axel Balley on 26/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FileBrowserNavigationController : UINavigationController
{
	id target;
	SEL selector;
}

- (void) setTarget:(id)t withSelector:(SEL)s;   // kengo:add
- (void) setPath:(NSString *)p;
- (void) flashScrollIndicators;

@end

@interface FileBrowserPageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    id target;
	SEL selector;
    
	NSArray *array;
	NSString *path;

	IBOutlet UITableView *table;
	IBOutlet UIBarButtonItem *refreshButton;
}

//- (id)init;   // kengo:
- (void) setPath:(NSString *)p;
- (void) refresh;
- (void) triggerRefresh:(id)sender;
- (void) flashScrollIndicators;

- (void) setTarget:(id)t withSelector:(SEL)s;   // kengo:add

@end
