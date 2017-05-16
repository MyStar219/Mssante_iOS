//
//  ELCUIApplication.m
//
//  Created by Brandon Trebitowski on 9/19/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCUIApplication.h"
#import "Constant.h"
#import "AccesToUserDefaults.h"

@implementation ELCUIApplication
@synthesize idleTimer, enableTouchTimer;

- (void)sendEvent:(UIEvent *)event {
        [super sendEvent:event];
        
        // Fire up the timer upon first event
        if(!idleTimer && enableTouchTimer) {
            [self resetIdleTimer];
        }
        
        // Check to see if there was a touch event
        NSSet *allTouches = [event allTouches];
        if ([allTouches count] > 0 && enableTouchTimer) {
            UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
            if (phase == UITouchPhaseBegan) {
                [self resetIdleTimer];         
            }
        }
}

-(void)invalidateTimer{
    if (idleTimer) {
        [idleTimer invalidate];
    }
}

- (void)resetIdleTimer 
{
    [self invalidateTimer];
	// Schedule a timer to fire in kApplicationTimeoutInMinutes * 60
	int timeout = TIMEOUT_LOGOUT_15MIN * 60;
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
												  target:self 
												selector:@selector(idleTimerExceeded) 
												userInfo:nil 
												 repeats:NO];
    [AccesToUserDefaults setUserInfoLastActivityTime:[[NSDate date] timeIntervalSince1970]];
}

- (void)idleTimerExceeded {
	/* Post a notification so anyone who subscribes to it can be notified when
	 * the application times out */ 
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:kApplicationDidTimeoutNotification object:nil];
}


@end
