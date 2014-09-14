//
//  GFDropView.m
//  Gifted
//
//  Created by Victor Delgado on 11/9/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import "GFDropView.h"
#import "GFAppDelegate.h"

@interface GFDropView ()
{
    NSImage *movieIconActive, *movieIconCancel;
    NSProgressIndicator *spinner;
}
@end

@implementation GFDropView

@synthesize msgReady, msgTaskEnded, fileIcon;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set initial state of layer
        [self setWantsLayer:YES];
        [[self layer] setBorderColor:[[NSColor GFBorderGreyColor] CGColor]];
        [[self layer] setBorderWidth:1.0];
        [[self layer] setCornerRadius:4.0];
        [[self layer] setBackgroundColor:[[NSColor GFBgGreyColor] CGColor]];
                
        // create tracking area
        NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                            options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow
                                                              owner:self
                                                           userInfo:nil];
        [self addTrackingArea:area];
        
        // make it responsive to dragging over
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
        
        // text message for state Ready
        msgReady = [self createLabel:@"Drop a movie or click here to pick one"
                             inFrame:NSMakeRect(34, 65, 142, 46)];
        msgReady.font = [NSFont fontWithName:@"Helvetica" size:14.0];
        msgReady.textColor = [NSColor GFBorderGreyColor];
        [self addSubview:msgReady];
        
        // set images for all states
        movieIconActive = [NSImage imageNamed:@"movieIconActive.png"];
        movieIconCancel = [NSImage imageNamed:@"movieIconCancel.png"];
        
        // image for FileReady
        NSRect imgRect = NSMakeRect(68, self.bounds.size.height + 50, 74, 60);
        fileIcon = [[NSImageView alloc] initWithFrame:imgRect];
        fileIcon.image = movieIconActive;
        [self addSubview:fileIcon];
        
        // set up spinner
        spinner = [[NSProgressIndicator alloc]
                   initWithFrame:NSMakeRect(self.bounds.size.width/2 - 25, self.bounds.size.height/2 - 25, 50, 50)];
        spinner.bezeled = FALSE;
        spinner.style = NSProgressIndicatorSpinningStyle;
        [spinner setDisplayedWhenStopped:NO];
        [self addSubview:spinner];
        
        // register for state notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appStateChanged:)
                                                     name:@"AppStateChanged"
                                                   object:nil];
    }
    return self;
}

- (NSTextField *)createLabel:(NSString *)text inFrame:(NSRect)rect {
    NSTextField *label = [[NSTextField alloc] initWithFrame:rect];
    [label setStringValue:text];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setDrawsBackground:NO];
    [label setBezeled:NO];
    [label resignFirstResponder];
    [label setAlignment:NSCenterTextAlignment];
    return label;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    // Drawing code here.
}

#pragma mark - utilities
- (void)appStateChanged:(NSNotification *)event {
    NSNumber *new = [[event userInfo] objectForKey:@"newState"];
    // NSNumber *old = [[event userInfo] objectForKey:@"previousState"];
    switch ([new intValue]) {
        case 0:
            NSLog(@"case 0");
            [spinner stopAnimation:self];
            fileIcon.alphaValue = 1.0;
            msgReady.animator.frame = NSMakeRect(34, 65, 142, 46);
            fileIcon.animator.frame = NSMakeRect(68, self.bounds.size.height + 50, 74, 60);
            break;
        case 1:
            NSLog(@"case 1");
            msgReady.animator.frame = NSMakeRect(34, -50, 142, 46);
            fileIcon.animator.frame = NSMakeRect(68, 60, 74, 60);
            break;
        case 2:
            NSLog(@"case 2");
            fileIcon.animator.alphaValue = 0.0;
            [spinner startAnimation:self];
            break;
    }
}

-(void)showFeedbackHighlight:(NSColor *)color {
    [[self layer] setBorderColor:[color CGColor]];
}

- (BOOL)isMovie:(NSURL *)fileUrl {
    NSString *extension = [fileUrl pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                 (__bridge CFStringRef)(extension),
                                                                 nil);
    if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
        CFRelease(fileUTI);
        return TRUE;
    }
    else {
        NSLog(@"file is not a movie");
        CFRelease(fileUTI);
        return FALSE;
    }
}

#pragma mark - mouse event handlers
- (void)mouseUp:(NSEvent *)theEvent {
    switch ([[GFStateMachine sharedState] currentState]) {
        case Ready:
            [[NSApp delegate] openFile];
            break;
        case FileReady:
            [[GFStateMachine sharedState] transitionTo:Ready];
            [[NSApp delegate] setCurrentFile:nil];
            break;
        default:
            break;
    }
}

- (void) mouseEntered:(NSEvent *)theEvent {
    switch ([[GFStateMachine sharedState] currentState]) {
        case Ready:
            [[NSCursor pointingHandCursor] set];
            break;
        case FileReady:
            [[NSCursor pointingHandCursor] set];
            self.toolTip = @"Click to remove file";
            fileIcon.image = movieIconCancel;
            break;
        default:
            break;
    }
}

- (void) mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    switch ([[GFStateMachine sharedState] currentState]) {
        case Ready:
            break;
        case FileReady:
            self.toolTip = nil;
            fileIcon.image = movieIconActive;
            break;
        default:
            break;
    }
}

#pragma mark - dragging
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] indexOfObject:NSURLPboardType] != NSNotFound) {
        NSLog(@"link");
        NSURL *fileUrl = [NSURL URLFromPasteboard:pboard];
        if (![self isMovie:fileUrl]) {
            [self showFeedbackHighlight:[NSColor redColor]];
        } else {
            [self showFeedbackHighlight:[NSColor GFGreenColor]];
        }
        return NSDragOperationLink;
    }
    else {
        NSLog(@"none");
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self showFeedbackHighlight:[NSColor GFBorderGreyColor]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] indexOfObject:NSURLPboardType] != NSNotFound) {
        NSURL *fileUrl = [NSURL URLFromPasteboard:pboard];
        [self showFeedbackHighlight:[NSColor GFBorderGreyColor]];
        if (![self isMovie:fileUrl]) {
            return FALSE;
        }
        NSString *filePath = [fileUrl path];
        [[NSApp delegate] prepareForConversion:filePath];
        NSLog(@"Drag ok!");
        return TRUE;
    }
    return FALSE;
}

@end