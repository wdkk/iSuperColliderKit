//
//  FileBrowserNavigationController.m
//  iscsynth
//
//  Created by Axel Balley on 26/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FileBrowserNaviController.h"

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <fcntl.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>


@implementation FileBrowserNavigationController

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
	{
		target = 0;
		selector = 0;
		[self setup];
	}
    return self;
}

- (id) initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
    if (self = [super initWithNibName:name bundle:bundle])
	{
		target = 0;
		selector = 0;
		[self setup];
	}
    return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void) setup
{
	FileBrowserPageViewController *m = [[FileBrowserPageViewController alloc] initWithNibName:@"SuperCollider_BrowserPage"
                                                                                       bundle:nil];
	[self pushViewController:m animated:NO];
}

- (void) setPath:(NSString *)p
{
	FileBrowserPageViewController *m = (FileBrowserPageViewController *) [self.viewControllers objectAtIndex:0];
	if (m)
	{
		[m setPath:p];
		m.title = @"Documents";
	}
}

- (void) setTarget:(id)t withSelector:(SEL)s
{
	target = t;
	selector = s;
}

- (void) didSelect:(NSString *) path
{
// kengo: hidden warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if (target && [target respondsToSelector:selector])
    {
        [target performSelector:selector withObject:path];
    }
#pragma clang diagnostic pop
}

// kengo:add
- (void) flashScrollIndicators
{
	//[table flashScrollIndicators];
}

- (void) dealloc
{
	if (target) { target = nil; } // kengo:
}

@end

@implementation FileBrowserPageViewController

- (id) initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
    if (self = [super initWithNibName:name bundle:bundle])
	{
		array = 0;
		path = 0;
	}
    return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void) setPath:(NSString *)p
{
	if (path) { path = nil; }
	path = p;

	self.title = [path lastPathComponent];
	
	[self refresh];
}

- (void) viewDidLoad
{
	self.navigationItem.rightBarButtonItem = refreshButton;
	
	[self refresh];
}

- (void) refresh
{
	if (!path) return;
	if (array) { array = nil; }
	array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
		
	[table reloadData];
}

- (void) setTarget:(id)t withSelector:(SEL)s
{
	target = t;
	selector = s;
}

- (void) triggerRefresh:(id)sender
{
	[self refresh];
}

- (void) flashScrollIndicators
{
	[table flashScrollIndicators];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [array count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
	}
	NSString *item = (NSString *)[array objectAtIndex:indexPath.row];
	cell.textLabel.text = item; // kengo:
	NSString *fullpath = [path stringByAppendingPathComponent:item];
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullpath error:nil];
	if ([attributes objectForKey:NSFileType]==NSFileTypeDirectory)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	NSString *fullpath = [path stringByAppendingPathComponent:[array objectAtIndex:newIndexPath.row]];
	
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullpath error:nil];
	if ([attributes objectForKey:NSFileType]==NSFileTypeDirectory)
	{
		[tableView deselectRowAtIndexPath:newIndexPath animated:NO];
		FileBrowserPageViewController *c = [[FileBrowserPageViewController alloc] initWithNibName:@"SuperCollider_BrowserPage"
                                                                                           bundle:nil];
		[c setPath:fullpath];
		[self.navigationController pushViewController:c animated:YES];
		return;
	}
	
	[tableView deselectRowAtIndexPath:newIndexPath animated:YES];
	[(FileBrowserNavigationController *) self.navigationController didSelect:fullpath];
}

- (void)dealloc
{
	if (path) { path = nil; }
}


@end
