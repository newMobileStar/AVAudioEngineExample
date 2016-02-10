//
//  AppDelegate.m
//  AVAudioEngineCompletion
//
//  Created by Nicholas Riley on 9/19/15.
//  Copyright © 2015 Nicholas Riley. All rights reserved.
//

#import "AppDelegate.h"

@import AVFoundation;
@import AudioUnit;

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    AVAudioEngine *engine = [[AVAudioEngine alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"/System/Library/Sounds/Ping.aiff"];
    NSError *error = nil;
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:url error:&error];
    if (file == nil) { NSLog(@"AVAudioFile error: %@", error); return; }
    
    AVAudioPlayerNode *player = [[AVAudioPlayerNode alloc] init];
    [engine attachNode:player];
    [engine connect:player to:engine.outputNode format:nil];

    // NSLog(@"engine: %@", engine);

    if (![engine startAndReturnError:&error]) {
        NSLog(@"engine failed to start: %@", error);
        return;
    }
    
    for (NSUInteger repetition = 0; repetition < 10; repetition++) {
        [player scheduleFile:file atTime:nil completionHandler:^{
            if (player.playing)
                NSLog(@"playing %d %@", (unsigned)repetition, player.lastRenderTime);
        }];
    }
    
    for (NSUInteger seconds = 1; seconds < 7; seconds++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (player.playing)
                NSLog(@"%u - %@", (unsigned)seconds, player.lastRenderTime);
            else {
                NSLog(@"player not playing");
            }
        });
    }
    
    [player play];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
