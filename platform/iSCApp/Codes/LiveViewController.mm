//
//  LiveViewController.m
//  isclang
//
//  Created by Axel Balley on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LiveViewController.h"
#import <iSCController.h>

@implementation LiveViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{

	}
	return self;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    iSCController *scc = [iSCController sharedInstance];
    [scc interpret:@"a = {SinOsc.ar()}.play"];
}

@end
