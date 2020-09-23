//
//  AppDelegate.m
//  JWLockScreenControls
//
//  Created by Michael Salvador on 5/25/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

#import "AppDelegate.h"
#import "AVKit/AVKit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    NSError *error;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
    [AVAudioSession.sharedInstance setActive:YES error:&error];

    if (error) {
        NSLog(@"Error setting audio session: %@", error);
    }

    return YES;
}

@end
