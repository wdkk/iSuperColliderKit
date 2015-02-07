//
//  TouchView.h
//  iSCApp
//
//  Created by Kengo Watanabe on 06/02/2015.
//  Copyright (c) 2015 Watanabe-DENKI Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

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
