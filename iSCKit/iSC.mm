/*
 
 iSuperCollider Kit (iSCKit) - SuperCollider for iOS 7 later
 Copyright (c) 2015 Kengo Watanabe <kengo@wdkk.co.jp>. All rights reserved.
	http://wdkk.co.jp/
 
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


#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

/*
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
*/

#import "iSC.h"
#include <pthread.h>
#include "PyrObject.h"
#include "PyrKernel.h"
#include "GC.h"
#include "VMGlobals.h"
#include "SCBase.h"
#include "SC_DirUtils.h"
#include "SC_LanguageClient.h"
#include "SC_WorldOptions.h"

#define START_HTTP_SERVER

extern PyrSymbol* s_interpretCmdLine;
extern PyrSymbol* s_run;
extern PyrSymbol* s_tick;

PyrSymbol* s_stop;
PyrSymbol* s_interpretPrintCmdLine;

static iSC* internal_sc_controller = 0;
static iSCLogView   * internal_log_view = 0;

void closeAllGUIScreens()
{
}

void initRendezvousPrimitives()
{
}

//////////////// queue

struct PostBuf
{
	char *buf;
	long wrpos;
	long rdpos;
	pthread_mutex_t mutex;

	void Init();
	void Flush(UITextView *view);
};

static PostBuf mainPostBuf;

#define POSTBUFLEN  131072
#define POSTBUFMASK 131071

void PostBuf::Init()
{
	buf = (char *)malloc(POSTBUFLEN);
	wrpos = 0;
	rdpos = 0;
    pthread_mutex_init(&mutex, NULL);
}

void PostBuf::Flush(UITextView *logView)
{
    if(logView == nil) { return; }
    
	long numtoread;
	long localwritepos = wrpos;

    NSString *log_text = [logView text] ? [logView text] : @"";
    
	if (localwritepos >= rdpos) {
		numtoread = localwritepos - rdpos;
	}
    else {
		numtoread = POSTBUFLEN - (rdpos - localwritepos);
	}
    
	if (numtoread > 0) {
		long endpos;
		endpos = rdpos + numtoread;
		if (endpos > POSTBUFLEN) {
			// wrap around end in two copies
			long firstpart, secondpart;

			firstpart = POSTBUFLEN - rdpos;
			endpos -= POSTBUFLEN;
			secondpart = endpos;

            NSString *c_to_str = [[NSString alloc] initWithUTF8String: buf + rdpos];
            if(c_to_str)
            {
                NSString *s = [log_text stringByAppendingString:[NSString stringWithUTF8String: buf + rdpos]];
                NSString *s2 = [s stringByAppendingString:[NSString stringWithUTF8String:buf]];
                [logView setText:s2];
            }
            
			rdpos = endpos;
		} else {
            NSString *c_to_str = [[NSString alloc] initWithUTF8String: buf + rdpos];
            if(c_to_str)
            {
                NSString *s = [log_text stringByAppendingString:c_to_str];
                [logView setText:s];
            }
            
			if (endpos == POSTBUFLEN) rdpos = 0;
			else rdpos = endpos;
		}
        
        int offset = [logView contentSize].height - [logView bounds].size.height;
        if (offset>=0) [logView setContentOffset:CGPointMake(0,offset) animated:NO];
	}
}

//void initPostBuffer();
void initPostBuffer()
{
	mainPostBuf.Init();
}

//void vposttext(const char *str, int length);
void vposttext(const char *str, int length)
{
	pthread_mutex_lock(&mainPostBuf.mutex);

	for (int i=0; i<length && str[i]; ++i)
    {
		if (((mainPostBuf.wrpos+1) & POSTBUFMASK) == mainPostBuf.rdpos)
        {
			break;
			//mainPostBuf.Flush(); CANNOT DO THIS FROM OTHER THAN COCOA'S THREAD!
		}
		mainPostBuf.buf[mainPostBuf.wrpos] = str[i];
		mainPostBuf.wrpos = (mainPostBuf.wrpos+1) & POSTBUFMASK;
	}
	pthread_mutex_unlock(&mainPostBuf.mutex);
}

void postfl(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);

	char buf[512];
	int len = vsnprintf(buf, sizeof(buf), fmt, ap);

	vposttext(buf, len);
}

void post(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);

	char buf[512];
	int len = vsnprintf(buf, sizeof(buf), fmt, ap);

	vposttext(buf, len);
}

void error(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);

	char buf[512];
	int len = vsnprintf(buf, sizeof(buf), fmt, ap);

	vposttext(buf, len);
}

void postText(const char *text, long length)
{
	char buf[512];
	strncpy(buf, text, length);
	buf[length] = 0;

	vposttext(buf, (int)length);
}

void postChar(char c)
{
	char buf[2];
	buf[0] = c;
	buf[1] = 0;

	vposttext(buf, 1);
}

void flushPostBuf()
{
    if(internal_sc_controller)
    {
        mainPostBuf.Flush([iSC sharedLogView]);
    }
}

void setPostFile(FILE* file)
{
}

int vpost(const char *fmt, va_list ap)
{
	char buf[512];
	int len = vsnprintf(buf, sizeof(buf), fmt, ap);

	vposttext(buf, len);
	return 0;
}

void setCmdLine(const char *buf)
{
	int size = (int)strlen(buf);
	if (compiledOK) {
		pthread_mutex_lock(&gLangMutex);
		if (compiledOK) {
			VMGlobals *g = gMainVMGlobals;

			PyrString* strobj = newPyrStringN(g->gc, size, 0, true);
			memcpy(strobj->s, buf, size);

			SetObject(&slotRawInterpreter(&g->process->interpreter)->cmdLine, strobj);
			g->gc->GCWrite(slotRawObject(&g->process->interpreter), strobj);
		}
		pthread_mutex_unlock(&gLangMutex);
	}
}

@implementation iSC

// public class methods.
+ (void) setup
{
    [iSC sharedInstance];
}

+ (void) interpretC:(const char*)sc_code_char
{
    [internal_sc_controller interpretSCMessage:[NSString stringWithUTF8String:sc_code_char]];
}

+ (void) interpret:(NSString *)sc_code
{
    [internal_sc_controller interpretSCMessage:sc_code];
}

+ (void) interpretFile:(NSString*)path_arg
{
    NSError *error;
    NSString *file_str = [NSString stringWithContentsOfFile:path_arg encoding:NSUTF8StringEncoding error:&error];
    if(error != nil) { NSLog(@"%@", error.description); return; }
    
    [internal_sc_controller interpretSCMessage:file_str];
}

+ (iSCLogView *)sharedLogView
{
    return internal_log_view;
}


// local class methods.
+ (iSC *)sharedInstance
{
    if(!internal_sc_controller)
    {
        internal_sc_controller = [[iSC alloc] init];
        [internal_sc_controller setupController];
    }
    return internal_sc_controller;
}

+ (void)outputSpeaker
{
    // kengo: add
    NSError *error = nil;
    AVAudioSession *av_session = [AVAudioSession sharedInstance];
    
    [av_session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(error) { 
        NSLog(@"audioSession: %@, %ld, %@", [error domain], (long)[error code], [[error userInfo] description]);
    }
    
    [av_session setActive:YES error:&error];
    if(error) { 
        NSLog(@"audioSession: %@, %ld, %@", [error domain], (long)[error code], [[error userInfo] description]);
    }
}

- (id) init
{
	if (self = [super init])
	{
		internal_sc_controller = self;
		deferredOperations = [NSMutableArray arrayWithCapacity:8];
        
        internal_log_view = [[iSCLogView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        internal_log_view.textColor = [UIColor blueColor];
        internal_log_view.font = [UIFont systemFontOfSize:10.0];
#if !defined(SC_TVOS)
        internal_log_view.editable = NO;
#endif
        [internal_log_view setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [internal_log_view setAutocorrectionType:UITextAutocorrectionTypeNo];
	}
	return self;
}

- (void) setupController
{
	NSFileManager *manager = [NSFileManager defaultManager];
	CFBundleRef bundle = CFBundleGetMainBundle();
	CFURLRef url = CFBundleCopyBundleURL(bundle);
	NSString *s = (NSString *) CFBridgingRelease(CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle));
    s = [s stringByAppendingString:@"/SCClassLibrary"];
    CFRelease(url);
    
	NSError *error;
	char supportpath[256];
	sc_GetUserAppSupportDirectory(supportpath, 256);
	NSString *support = [NSString stringWithCString:supportpath encoding:NSASCIIStringEncoding];

    if (![manager fileExistsAtPath:support])
    {
        [manager createDirectoryAtPath:support withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
	NSString *dir = [support stringByAppendingString:@"/SCClassLibrary"];
	if (![manager fileExistsAtPath:dir])
	{
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];

		NSString *from, *dest;
		from = [s stringByAppendingString:@"/Common"];
		dest = [dir stringByAppendingString:@"/Common"];
		[manager copyItemAtPath:from toPath:dest error:&error];
        
		from = [s stringByAppendingString:@"/DefaultLibrary"];
		dest = [dir stringByAppendingString:@"/DefaultLibrary"];
		[manager copyItemAtPath:from toPath:dest error:&error];
        
		from = [s stringByAppendingString:@"/Platform"];
		dest = [dir stringByAppendingString:@"/Platform"];
		[manager copyItemAtPath:from toPath:dest error:&error];
        
		from = [s stringByAppendingString:@"/backwards_compatibility"];
		dest = [dir stringByAppendingString:@"/backwards_compatibility"];
		[manager copyItemAtPath:from toPath:dest error:&error];
        
		from = [s stringByAppendingString:@"/JITLib"];
		dest = [dir stringByAppendingString:@"/JITLib"];
		[manager copyItemAtPath:from toPath:dest error:&error];
        
		from = [s stringByAppendingString:@"/SCDoc"];
		dest = [dir stringByAppendingString:@"/SCDoc"];
		[manager copyItemAtPath:from toPath:dest error:&error];
	}
	dir = [support stringByAppendingString:@"/sounds"];
	if (![manager fileExistsAtPath:dir])
	{
		NSString *from = [s stringByAppendingString:@"/sounds"];
		if ([manager fileExistsAtPath:from])
		{
			[manager copyItemAtPath:from toPath:dir error:&error];
		}
	}
	dir = [support stringByAppendingString:@"/Extensions"];
	if (![manager fileExistsAtPath:dir])
	{
		NSString *from = [s stringByAppendingString:@"/Extensions"];
		if ([manager fileExistsAtPath:from])
		{
			[manager copyItemAtPath:from toPath:dir error:&error];
		}
	}
	dir = [support stringByAppendingString:@"/plugins"];
	if (![manager fileExistsAtPath:dir])
	{
		NSString *from = [s stringByAppendingString:@"/plugins"];
		if ([manager fileExistsAtPath:from])
		{
			[manager copyItemAtPath:from toPath:dir error:&error];
		}
	}
	dir = [support stringByAppendingString:@"/patches_ios"];
    if(![manager fileExistsAtPath:dir])
    {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *patches_dir = [s stringByAppendingString:@"/patches_ios"];
	NSArray *patches = [manager contentsOfDirectoryAtPath:patches_dir error:nil];
	for (NSString *patch in patches)
	{
		NSString *origin = [patches_dir stringByAppendingPathComponent:patch];
		NSString *destination = [dir stringByAppendingPathComponent:patch];
		if ([manager fileExistsAtPath:destination]) [manager removeItemAtPath:destination error:nil];
		[manager copyItemAtPath:origin toPath:destination error:&error];
	}
	dir = [support stringByAppendingString:@"/Recordings"];
	if (![manager fileExistsAtPath:dir])
	{
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
	}
	dir = [support stringByAppendingString:@"/synthdefs"];
	if (![manager fileExistsAtPath:dir])
	{
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
	}
	dir = [support stringByAppendingString:@"/tmp"];
	if ([manager fileExistsAtPath:dir]) { [manager removeItemAtPath:dir error:&error]; }
    [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    
    initPostBuffer();
    
/*
#ifdef START_HTTP_SERVER
	HTTPServer *httpServer = [HTTPServer new];
	//[httpServer setType:@"_webdav._tcp."];
	[httpServer setPort:8080];
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	[httpServer setDocumentRoot:[NSURL fileURLWithPath:support]];
	[httpServer start:&error];
#endif
*/

    [self start];
}

- (void) start
{
	pyr_init_mem_pools(2*1024*1024, 256*1024);
	init_OSC(57120);
	schedInit();

	compileLibrary();

	appClockTimer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(doClockTask:) userInfo:nil repeats:YES];
	deferredTaskTimer = [NSTimer scheduledTimerWithTimeInterval:0.038 target:self selector:@selector(doPeriodicTask:) userInfo: nil repeats: YES];

	s_stop = getsym("stop");
	s_interpretPrintCmdLine = getsym("interpretPrintCmdLine");
}

- (void) interpretSCMessage:(NSString *)string
{
	int length = (int)[string length];
	char *cmd = (char *) malloc(length+1);
	[string getCString:cmd maxLength:length+1 encoding:NSASCIIStringEncoding];
	setCmdLine(cmd);

	if (pthread_mutex_trylock(&gLangMutex) == 0)
	{
        //NSLog(@"%d,%s, interpret: runLibary()", __LINE__, __FUNCTION__);
		runLibrary(s_interpretPrintCmdLine);
		pthread_mutex_unlock(&gLangMutex);
	}
	free(cmd);
}

- (void)doPeriodicTask:(NSTimer*)timer
{
	[self performDeferredOperations];
	flushPostBuf();
}

- (void)doClockTask:(NSTimer*)timer
{
	if (pthread_mutex_trylock(&gLangMutex) == 0)
	{
		if (compiledOK) runLibrary(s_tick);
		pthread_mutex_unlock(&gLangMutex);
    }
    flushPostBuf();
}

- (void)defer: (NSInvocation*) action
{
    [deferredOperations addObject: action];
}

- (void)removeDeferredOperationsFor:(id) object
{
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity: 8];
	for (unsigned int i=0; i<[deferredOperations count]; ++i)
    {
		NSInvocation* action = (NSInvocation*)[deferredOperations objectAtIndex: i];
		if ([action target] != object)
        {
			[newArray addObject: action];
		}
	}
	deferredOperations = newArray;
}

- (void)performDeferredOperations
{
    while ([deferredOperations count])
    {
		NSInvocation* action = (NSInvocation*)[deferredOperations objectAtIndex: 0];
        [deferredOperations removeObjectAtIndex: 0];
        [action invoke];
    }
}

- (void) dealloc
{
	deferredOperations = nil;
}

@end

