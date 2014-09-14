//
//  GFStateMachine.m
//  Gifted
//
//  Created by Victor Delgado on 11/10/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import "GFStateMachine.h"

@interface GFStateMachine ()
// internal state variable
@property (readwrite) AppState state;

@end


@implementation GFStateMachine

static GFStateMachine *sharedInstance = nil;

+ (GFStateMachine *)sharedState {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedState];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setState:Ready];
    }
    return self;
}


#pragma mark - main instance methods

- (AppState)currentState {
    return [self state];
}

- (void)transitionTo:(AppState)state {
    NSDictionary *changeInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:[self currentState]], @"previousState",
                                [NSNumber numberWithInt:state], @"newState",
                                nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppStateChanged"
                                                        object:self
                                                      userInfo:changeInfo];
    [self setState:state];
}

@end
