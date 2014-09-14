//
//  GFDropView.h
//  Gifted
//
//  Created by Victor Delgado on 11/9/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GFStateMachine.h"
#import "NSColor+GFColors.h"

@interface GFDropView : NSImageView <NSDraggingDestination>

@property NSTextField *msgReady, *msgTaskEnded;
@property NSImageView *fileIcon;

@end
