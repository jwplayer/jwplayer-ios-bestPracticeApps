//
//  JWLockScreenViewController.m
//  JWLockScreenControls
//
//  Created by Michael Salvador on 5/25/20.
//  Copyright © 2020 Karim Mourra. All rights reserved.
//

#import "JWLockScreenViewController.h"

@interface JWLockScreenViewController ()

@property (nonatomic) JWPlayerController *topPlayer;
@property (nonatomic) JWPlayerController *bottomPlayer;

@end

@implementation JWLockScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createTopPlayer];
    [self createBottomPlayer];

    // After all players have been instantiated, make sure 'displayLockScreenControls' is set to false for all the players
    // you don't want to be affected by lock screen controls. Then, set 'displayLockScreenControls' true
    // for the player you do want the lock screen controls to affect.

    self.bottomPlayer.displayLockScreenControls = NO; // Won't be affected by lock screen controls
    self.topPlayer.displayLockScreenControls = YES; // Will be affected by lock screen controls

    // Note: - If a third player is instantiated, it will take over the current lock screen controls,
    // because 'displayLockScreenControls' defaults to true.
}

- (void)createTopPlayer
{
    NSString *videoURL = @"http://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8";
    NSString *posterImageURL = @"http://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg";
    JWConfig *config = [[JWConfig alloc] initWithContentUrl:videoURL];
    config.image = posterImageURL;
    config.title = @"Top Player";
    config.autostart = YES;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    config.size = CGSizeMake(viewWidth, viewHeight/2);
    self.topPlayer = [[JWPlayerController alloc] initWithConfig:config];
    [self.view addSubview:self.topPlayer.view];
    CGFloat midX = self.view.frame.size.width / 2;
    CGFloat midY = self.view.frame.size.height / 2;
    self.topPlayer.view.center = CGPointMake(midX, midY - (config.size.height/2));
}

- (void)createBottomPlayer
{
    NSString *videoURL = @"https://playertest.longtailvideo.com/adaptive/bipbop/bipbopall.m3u8";
    NSString *posterImageURL = @"http://d3el35u4qe4frz.cloudfront.net/3XnJSIm4-480.jpg";
    JWConfig *config = [[JWConfig alloc] initWithContentUrl:videoURL];
    config.image = posterImageURL;
    config.title = @"Bottom Player";
    config.autostart = YES;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    config.size = CGSizeMake(viewWidth, viewHeight/2);
    self.bottomPlayer = [[JWPlayerController alloc] initWithConfig:config];
    [self.view addSubview:self.bottomPlayer.view];
    CGFloat midX = self.view.frame.size.width / 2;
    CGFloat midY = self.view.frame.size.height / 2;
    self.bottomPlayer.view.center = CGPointMake(midX, midY + (config.size.height/2));
}


@end
