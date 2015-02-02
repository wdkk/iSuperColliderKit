//
//  iSCSynthController.m
//  iscsynth
//
//  Created by Axel Balley on 21/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "iSCSynthAppDelegate.h"
#import "iSCSynthController.h"

#include "SC_Graph.h"
#include "SC_GraphDef.h"
#include "SC_Prototypes.h"
#include "SC_Node.h"
#include "SC_DirUtils.h"

static iSCSynthController* internal_sc_controller = 0;

int vpost(const char *fmt, va_list ap)
{
	char buf[512];
	vsnprintf(buf, sizeof(buf), fmt, ap);

	if (internal_sc_controller) [internal_sc_controller log:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];
	return 0;
}

@implementation iSCSynthController

- (id) init
{
	if (!internal_sc_controller && (self=[super init]))
	{
		options = kDefaultWorldOptions;
		options.mBufLength = 1024;
		timer = 0;
		world = 0;
		lastNodeID = 1000;

        // kengo:AudioSession to AVAudioSession API.
        // attention - AVAudioSession code building is not completed, please anybody rebuild it again.
        NSError *error;
        AVAudioSession *av_session = [AVAudioSession sharedInstance];
        
        // イヤフォンを挿した場合にはイヤフォンのみから音がするようにしている（kAudioSessionOverrideAudioRoute_None)
		//unsigned long route = kAudioSessionOverrideAudioRoute_None;
		//AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);

        [av_session setActive:YES error:&error];
        
		SetPrintFunc(vpost);
		internal_sc_controller = self;
	}
	
	return self;
}

- (void) awakeFromNib
{
	NSFileManager *manager = [NSFileManager defaultManager];
	CFBundleRef bundle = CFBundleGetMainBundle();
	CFURLRef url = CFBundleCopyBundleURL(bundle);
	CFStringRef s = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
	CFRelease(url);
	
	NSError *error; 
	char supportpath[256];
	sc_GetUserAppSupportDirectory(supportpath, 256);
	NSString *support = [NSString stringWithCString:supportpath encoding:NSASCIIStringEncoding];
	NSString *dir = [support stringByAppendingString:@"/synthdefs"];
	if (![manager fileExistsAtPath:dir])
	{
        NSString *str = (__bridge NSString*)s;
		NSString *from = [str stringByAppendingString:@"/synthdefs"];
		if ([manager fileExistsAtPath:from])
		{
			[manager copyItemAtPath:from toPath:dir error:&error];
		}		
	}
	CFRelease(s);

	logView.font = [logView.font fontWithSize:10.0f];
	logView.textColor = [UIColor blueColor];
	
	[synthdefsViewController setPath:dir];
    
    // kengo:とりあえずバンドルしたsynthdefsフォルダ内を表示させる
    //NSString* synthdef_path = [[NSBundle mainBundle] bundlePath];
    //[synthdefsViewController setPath:synthdef_path];
    
	[synthdefsViewController setTarget:self withSelector:@selector(selectSynthdef:)];
	
	[speakerSwitch setOn:NO];
	[freeAllButton setHidden:YES];
			
//#if !TARGET_IPHONE_SIMULATOR
	[self start];
//#endif
}

- (void) start
{
	if(world) { World_Cleanup(world); }
	world = World_New(&options);
	if(!world || !World_OpenUDP(world, 57110)) { return; }
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

- (void) stop
{
	if(world) { World_Cleanup(world); }
	world = 0;
	if (timer) { [timer invalidate]; }
	timer = 0;
	avgCPULabel.text = @"0.0";
	peakCPULabel.text = @"0.0";
}

- (void) freeAllNodes
{
	//World_FreeAllGraphDefs(world);
	Group *group = World_GetGroup(world, 0);
	Group_DeleteAll(group);
}

- (void) update:(NSTimer *)timer
{
	double avgCPU = world->hw->mAudioDriver->GetAvgCPU();
	avgCPULabel.text = [NSString stringWithFormat:@"%.1f",avgCPU];
	double peakCPU = world->hw->mAudioDriver->GetPeakCPU();
	peakCPULabel.text = [NSString stringWithFormat:@"%.1f",peakCPU];
	synthsLabel.text = [NSString stringWithFormat:@"%d",world->mNumGraphs];
	ugensLabel.text = [NSString stringWithFormat:@"%d",world->mNumUnits];
	
	[freeAllButton setHidden:(BOOL)(!world->mNumGraphs)];
}

- (IBAction) toggleSpeaker:(id)sender
{	
    // kengo:AudioSession to AVAudioSession API.
    // attention - AVAudioSession code building is not completed, please anybody rebuild it again.
    NSError *error;
    AVAudioSession *av_session = [AVAudioSession sharedInstance];
    
    // ONのときはイヤフォン挿していてもスピーカから音がするようにする
    // OFFの時はイヤフォンから音がするようにしている
    //UISwitch *s = (UISwitch *) sender;
	//UInt32 route;
	//if(s.on) { route = kAudioSessionOverrideAudioRoute_Speaker; }
	//else { route = kAudioSessionOverrideAudioRoute_None; }
	//AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
    
    [av_session setActive:YES error:&error];
}

- (IBAction) triggerFreeAll:(id)sender
{
	[self freeAllNodes];
}

- (void) selectSynthdef:(NSString *)string
{
	char defpath[256];
	[string getCString:defpath maxLength:256 encoding:NSASCIIStringEncoding];
				
	GraphDef *def = GraphDef_Load(world, defpath, 0);
	if (!def) return;
	Group *group = World_GetGroup(world, 0);
	Graph *graph = 0;
	int data = 0;
	sc_msg_iter msg(0,(char *) &data);
	Graph_New(world, def, lastNodeID++, &msg, &graph);
	if (graph && group)
	{
		Group_AddTail(group, &graph->mNode);
		Node_StateMsg(&graph->mNode, kNode_Go);
	}	
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if ([viewController isEqual:logViewController])
	{
		[logView flashScrollIndicators];
	}
	else if ([viewController isEqual:synthdefsViewController])
	{
		[synthdefsViewController flashScrollIndicators];
	}
}

- (void) log:(NSString *)string
{
	logView.text = [logView.text stringByAppendingString:string];
	
	int offset = logView.contentSize.height - logView.bounds.size.height;
	if (offset>=0) [logView setContentOffset:CGPointMake(0,offset) animated:NO];
}

- (void) dealloc
{
	if (world) [self stop];
}

@end
