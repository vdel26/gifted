//
//  GFStateMachine.h
//  Gifted
//
//  Created by Victor Delgado on 11/10/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * valid states
 */
typedef enum {
    Ready,
    FileReady,
    Converting
} AppState;

@interface GFStateMachine : NSObject

/* 
 * get singleton instance
 */
+ (GFStateMachine *)sharedState;

/*
 * state interface
 */
- (AppState)currentState;
- (void)transitionTo:(AppState)state;

@end
