//
//  JWBasicVideoViewController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/16/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWBasicVideoViewController.h"

#define videoFile @"https://cdn.jwplayer.com/manifests/d0K0B1g6.m3u8"
//#define videoFile @"http://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8"
#define posterImage @"http://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"

@interface JWBasicVideoViewController ()

@end

@implementation JWBasicVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlayer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.view addSubview:self.player.view];
}

- (void)createPlayer
{
    JWConfig *config = [self createConfig];
    self.player = [[JWPlayerController alloc]initWithConfig:config];
    self.player.forceLandscapeOnFullScreen = YES;
    self.player.forceFullScreenOnLandscape = YES;
    self.player.view.center = self.view.center;
    self.player.delegate = self;
}

- (JWConfig *)createConfig
{
    JWConfig* config = [[JWConfig alloc]initWithContentUrl:videoFile];
    config.image = posterImage;
    config.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
    config.autostart = YES;
    config.repeat = YES;
    return config;
}

@end
