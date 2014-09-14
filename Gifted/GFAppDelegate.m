//
//  GFAppDelegate.m
//  Gifted
//
//  Created by Victor Delgado on 11/9/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import "GFAppDelegate.h"
#import "INAppStoreWindow.h"

@interface GFAppDelegate ()

@property (nonatomic ,readwrite) NSTask *ffmpeg, *convert, *gifsicle;
@property (nonatomic, readwrite) BOOL cancelled;

@end


@implementation GFAppDelegate

@synthesize currentFile, outFile;

# pragma mark - event handlers
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // custom window
    INAppStoreWindow *window = (INAppStoreWindow *)[self window];
    
    // colors
    NSColor *white = [NSColor whiteColor];
    
    // set custom title bar
    [window setTitleBarStartColor:white];
    [window setTitleBarEndColor:white];
    [window setBaselineSeparatorColor:white];
    [window setInactiveTitleBarStartColor:white];
    [window setInactiveTitleBarEndColor:white];
    [window setInactiveBaselineSeparatorColor:white];
    [window setTitle:@"Gifted"];
    [window setShowsTitle:YES];
    
    [window setBackgroundColor:white];
        
    // register for state notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appStateChanged:)
                                                 name:@"AppStateChanged"
                                               object:nil];
}

// button handler
- (IBAction)exec:(id)sender {
    switch ([[GFStateMachine sharedState]currentState]) {
        case FileReady:
            [[GFStateMachine sharedState] transitionTo:Converting];
            [self convert:currentFile];
            break;
        case Converting:
            [[GFStateMachine sharedState] transitionTo:Ready];
            [self stopTasks];
        default:
            break;
    }
    
}

- (void)taskDidTerminate:(NSNotification *)event {
    if (![_gifsicle isRunning]) {
        [[GFStateMachine sharedState] transitionTo:Ready];
        
        if (!_cancelled) {
            NSURL *outFileURL = [NSURL fileURLWithPath:outFile];
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ outFileURL ]];
            _cancelled = NO;
        }
    }
}

- (void)appStateChanged:(NSNotification *)event {
    NSNumber *new = [[event userInfo] objectForKey:@"newState"];
    // NSNumber *old = [[event userInfo] objectForKey:@"previousState"];
    switch ([new intValue]) {
        case 0:
            // a transition to Ready means a conversion has finished
            self.currentFile = nil;
            break;
        case 1:
            break;
        case 2:
            break;
    }
}

#pragma mark - public interface
- (void)openFile {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"mov", @"avi", @"mp4", nil]];
    
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSOKButton) {
            NSLog(@"OK");
            NSString *filePath = [[[panel URLs] objectAtIndex:0] path];
            [self prepareForConversion:filePath];
        } else {
            NSLog(@"NO OK");
        }
    }];
    
}

-(void)prepareForConversion:(NSString *)filePath {
    [[GFStateMachine sharedState] transitionTo:FileReady];
    [self setCurrentFile:filePath];
    NSLog(@"%@", currentFile);
}


#pragma mark - private methods
-(void)convert:(NSString *)filePath {
    outFile = [self outputDirectory:filePath];
    
    NSString *ffmpegPath = [[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:nil];
    NSString *gifsiclePath = [[NSBundle mainBundle] pathForResource:@"gifsicle" ofType:nil];
    
    _ffmpeg = [[NSTask alloc] init];
    _gifsicle = [[NSTask alloc] init];

    _ffmpeg.arguments = [NSArray arrayWithObjects:@"-t", @"0:0:20", @"-i", filePath,
                         @"-r", @"8", @"-s", @"600x400",
                         @"-f", @"gif", @"-", nil];
    _gifsicle.arguments = [NSArray arrayWithObjects:@"--optimize=3", @"--delay=6",
                           @"-o", outFile, nil];

    _ffmpeg.launchPath = ffmpegPath;
    _gifsicle.launchPath = gifsiclePath;
    
    NSPipe *pipeBetween = [NSPipe pipe];
    [_ffmpeg setStandardOutput: pipeBetween];
    [_gifsicle setStandardInput: pipeBetween];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskDidTerminate:)
                                                 name:NSTaskDidTerminateNotification
                                               object:Nil];
    [_ffmpeg launch];
    [_gifsicle launch];

    [[GFStateMachine sharedState] transitionTo:Converting];
}

- (NSString *)outputDirectory:(NSString *)filePath {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *fileName = [[filePath lastPathComponent] stringByAppendingPathExtension:@"gif"];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSArray *urls = [fileMgr URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask];
    NSURL *containerURL = [[urls objectAtIndex:0] URLByAppendingPathComponent:[fileMgr displayNameAtPath:bundlePath]
                                                                  isDirectory:YES];
    // create ~/Pictures/Gifted/ if it doesn't exist
    BOOL isDir;
    if (![fileMgr fileExistsAtPath:[containerURL path] isDirectory:&isDir] || !isDir) {
        [fileMgr createDirectoryAtURL:containerURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [[containerURL URLByAppendingPathComponent:fileName] path];
}

- (void)stopTasks {
    NSLog(@"stopping tasks...");
    _cancelled = YES;
    [_ffmpeg terminate];
    [_gifsicle waitUntilExit];
    [[NSFileManager defaultManager] removeItemAtPath:outFile error:nil];
}


@end
