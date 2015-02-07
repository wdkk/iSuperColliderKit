//
//  TouchView.m
//  iSCApp
//
//  Created by Kengo Watanabe on 06/02/2015.
//  Copyright (c) 2015 Watanabe-DENKI Inc. All rights reserved.
//

#import "TouchView.h"
#import <objc/message.h>

@implementation TouchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) { return nil; }

    self.responder_once = false;
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if(self.delegate_touches && [self.delegate_touches respondsToSelector:self.sel_touches_began])
    {
        ((void (*)(id, SEL, NSSet*, UIEvent*))objc_msgSend)(self.delegate_touches, self.sel_touches_began, touches, event);
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch   = (UITouch*)[touches anyObject];
    CGPoint position = [touch locationInView:self];
    
    if(self.delegate_touches && [self.delegate_touches respondsToSelector:self.sel_touches_moved])
    {
        ((void (*)(id, SEL, NSSet*, UIEvent*))objc_msgSend)(self.delegate_touches, self.sel_touches_moved, touches, event);
    }
    
    if(self.delegate_touches && [self.delegate_touches respondsToSelector:self.sel_touches_moved_outside])
    {
        if(position.x < 0 || self.frame.size.width <= position.x ||
           position.y < 0 || self.frame.size.height <= position.y)
        {
            ((void (*)(id, SEL, NSSet*, UIEvent*))objc_msgSend)(self.delegate_touches, self.sel_touches_moved_outside, touches, event);
        }
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch   = (UITouch*)[touches anyObject];
    CGPoint position = [touch locationInView:self];
    
    if(self.delegate_touches && [self.delegate_touches respondsToSelector:self.sel_touches_ended])
    {
        ((void (*)(id, SEL, NSSet*, UIEvent*))objc_msgSend)(self.delegate_touches, self.sel_touches_ended, touches, event);
    }
    
    if(self.delegate_touches && [self.delegate_touches respondsToSelector:self.sel_touches_ended_inside])
    {
        if(0 <= position.x && position.x < self.frame.size.width &&
           0 <= position.y && position.y < self.frame.size.height)
        {
            ((void (*)(id, SEL, NSSet*, UIEvent*))objc_msgSend)(self.delegate_touches, self.sel_touches_ended_inside, touches, event);
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if(self.delegate_touches && [self.delegate_touches respondsToSelector:self.sel_touches_cancelled])
    {
        ((void (*)(id, SEL, NSSet*, UIEvent*))objc_msgSend)(self.delegate_touches, self.sel_touches_cancelled, touches, event);
    }
}

-(UIResponder*) nextResponder
{
    if(self.responder_once) { return nil; }
    else { return [super nextResponder]; }
}

@end
