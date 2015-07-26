//
//  AppDelegate.m
//  testMac000_Cocoa
//
//  Created by 渡辺 賢悟 on 12/01/09.
//  Copyright (c) 2012年 けん悟庵. All rights reserved.
//

#import "OSXAppDelegate.h"
#include "PyrSymbol.h"
#include "PyrObject.h"
#include "PyrKernel.h"
#include "InitAlloc.h"
#include <pthread.h>
#include "GC.h"
#include "VMGlobals.h"
#include "SCBase.h"
#include "SC_DirUtils.h"
#include "SC_LanguageClient.h"
#include "SC_WorldOptions.h"

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

@implementation OSXAppDelegate

struct PyrSymbol* s_stop;
struct PyrSymbol* s_interpretPrintCmdLine;

- (id) init {
    self = [super init];
    if(self == nil) { return self; }

    return self;
}

- (void)dealloc
{
    [self releaseSC];
}

- (void) run
{
    [self setupSC];
    
    // create window
    NSWindow *window = [[NSWindow alloc] init];
    [window setFrame:NSMakeRect(0, 0, 400, 400) display:YES];
    // show window.
    [window orderFront:nil];
    
    [self interpret:@"s.boot"];
    [self interpret:@"a = {SinOsc.ar()}.play"];
}

-(void) setupSC
{
    pyr_init_mem_pools(2*1024*1024, 256*1024);
    init_OSC(57120);
    
    schedInit();
    
    compileLibrary();
    runLibrary(s_run);
    
    s_stop = getsym("stop");
    s_interpretPrintCmdLine = getsym("interpretPrintCmdLine");
}

-(void) releaseSC
{
    cleanup_OSC();
}

- (void) interpret:(NSString *)string
{
    int length = (int)[string length];
    char *cmd = (char *) malloc(length+1);
    [string getCString:cmd maxLength:length+1 encoding:NSASCIIStringEncoding];
    setCmdLine(cmd);
    
    if (pthread_mutex_trylock(&gLangMutex) == 0)
    {
        NSLog(@"%d,%s, interpret: runLibary()", __LINE__, __FUNCTION__);
        runLibrary(s_interpretPrintCmdLine);
        pthread_mutex_unlock(&gLangMutex);
    }
    free(cmd);
}

@end
