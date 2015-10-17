//
//  TouchView.h
//  iSCApp
//
//  Created by kengo on 2015/10/17.
//
//

#import <UIKit/UIKit.h>

@interface TouchView : UIView

@property id  delegate;
@property SEL ev_touches_began;

@end
