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
