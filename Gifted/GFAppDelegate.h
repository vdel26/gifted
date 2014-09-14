//
//  GFAppDelegate.h
//  Gifted
//
//  Created by Victor Delgado on 11/9/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GFStateMachine.h"

@interface GFAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property NSString *currentFile, *outFile;

- (IBAction)exec:(id)sender;
- (void)openFile;
- (void)prepareForConversion:(NSString *)filePath;

@end
