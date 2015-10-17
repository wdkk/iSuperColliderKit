//
//  TouchView.m
//  iSCApp
//
//  Created by kengo on 2015/10/17.
//
//

#import "TouchView.h"
#import <objc/message.h>

@implementation TouchView

@synthesize delegate;
@synthesize ev_touches_began;

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.delegate != nil && self.ev_touches_began != nil && [self.delegate respondsToSelector:self.ev_touches_began])
    {
        ((void (*)(id, SEL, NSSet<UITouch *>*, UIEvent *))objc_msgSend)(self.delegate, self.ev_touches_began, touches, event);
    }
}

@end
