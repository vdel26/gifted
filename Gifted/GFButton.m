//
//  GFButton.m
//  Gifted
//
//  Created by Victor Delgado on 11/10/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import "GFButton.h"

@implementation GFButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.wantsLayer = YES;
    self.bordered = NO;
    
    CALayer *layer = [self layer];
    layer.borderWidth = 1.0;
    layer.cornerRadius = 4.0;
    layer.borderColor = [[NSColor GFBlueColor] CGColor];
    layer.backgroundColor = [[NSColor whiteColor] CGColor];
    
    // create tracking area
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                        options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:area];
    
    // set initial title
    [self setButtonTitle:@"Start" withColor:[NSColor GFBlueColor]];
    
    // register for state notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appStateChanged:)
                                                 name:@"AppStateChanged"
                                               object:nil];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

#pragma mark - mouse events
- (void)mouseEntered:(NSEvent *)theEvent {
    CALayer *layer = [self layer];
    GFStateMachine *state = [GFStateMachine sharedState];
    
    switch ([state currentState]) {
        case FileReady:
            [layer setBorderColor:[[NSColor GFGreenColor] CGColor]];
            [self setButtonTitle:@"Start" withColor:[NSColor GFGreenColor]];
            break;
        case Converting:
//            [layer setBorderColor:[[NSColor redColor] CGColor]];
//            [self setButtonTitle:@"Cancel" withColor:[NSColor redColor]];
            break;
        default:
            // [layer setBorderColor:[[NSColor GFBlueColor] CGColor]];
            break;
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    CALayer *layer = [self layer];
    GFStateMachine *state = [GFStateMachine sharedState];
    
    switch ([state currentState]) {
        case FileReady:
            [layer setBorderColor:[[NSColor GFBlueColor] CGColor]];
            [self setButtonTitle:@"Start" withColor:[NSColor GFBlueColor]];
            break;
        case Converting:
//            [layer setBorderColor:[[NSColor GFBorderGreyColor] CGColor]];
//            [self setButtonTitle:@"Cancel" withColor:[NSColor GFBorderGreyColor]];
            break;
        default:
            // [layer setBorderColor:[[NSColor GFBlueColor] CGColor]];
            break;
    }
}

#pragma mark - helpers
- (void)setButtonTitle:(NSString *)title withColor:(NSColor *)color {
    NSMutableParagraphStyle *par = [[NSMutableParagraphStyle alloc] init];
    [par setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           par, NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Helvetica" size:16.0], NSFontAttributeName,
                           color, NSForegroundColorAttributeName,
                           nil];
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:title
                                                                  attributes:attrs];
    [self setAttributedTitle:attrStr];
}

- (void)appStateChanged:(NSNotification *)event {
    NSNumber *new = [[event userInfo] objectForKey:@"newState"];
    // NSNumber *old = [[event userInfo] objectForKey:@"previousState"];
    switch ([new intValue]) {
        case 0:
            self.layer.borderColor = [[NSColor GFBlueColor] CGColor];
            [self setButtonTitle:@"Start" withColor:[NSColor GFBlueColor]];
            break;
        case 1:
            // fileready
            break;
        case 2:
            // converting
            self.layer.borderColor = [[NSColor redColor] CGColor];
            [self setButtonTitle:@"Cancel" withColor:[NSColor redColor]];
            break;
    }
}


@end