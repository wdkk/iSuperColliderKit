#import <Cocoa/Cocoa.h>
#import "OSXAppDelegate.h"

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {        
        // create NSApplication Singleton.
        NSApplication* app = [NSApplication sharedApplication];
        
        // setup osx app delegate.
        OSXAppDelegate* apdl  = [[OSXAppDelegate alloc] init];
        [apdl run];
        
        // Go to run loop.
        [app run];
        
        return 0;
        //return NSApplicationMain(argc, argv);
    }
}