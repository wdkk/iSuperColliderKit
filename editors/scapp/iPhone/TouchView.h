//
//  TouchView.h
//
//  Created by Kengo Watanabe on 2014/06/20.
//  Copyright (c) 2014 Watanabe-DENKI Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 
@interface TouchView : UIView

@property (nonatomic) id  delegate_touches;
@property (nonatomic) SEL sel_touches_began;
@property (nonatomic) SEL sel_touches_moved;
@property (nonatomic) SEL sel_touches_ended;
@property (nonatomic) SEL sel_touches_cancelled;
@property (nonatomic) SEL sel_touches_ended_inside;
@property (nonatomic) SEL sel_touches_moved_outside;

@property (nonatomic) bool responder_once;

@end
