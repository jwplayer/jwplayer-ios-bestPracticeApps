//
//  JWFriendlyObstructionViewController.m
//  JWFriendlyObstructions
//
//  Created by karim on 5/13/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

#import "JWFriendlyObstructionViewController.h"
#import <JWPlayer_iOS_SDK/JWFriendlyAdObstructions.h>

#define sampleAdTag @"https://pubads.g.doubleclick.net/gampad/ads?iu=/124319096/external/omid_google_samples&env=vp&gdfp_req=1&output=vast&sz=640x480&description_url=http%3A%2F%2Ftest_site.com%2Fhomepage&tfcd=0&npa=0&vpmute=0&vpa=0&vad_format=linear&url=http%3A%2F%2Ftest_site.com&vpos=preroll&unviewed_position_start=1&correlator="

#define playIconName @"play-button.png"
#define pauseIconName @"pause-button.png"

@interface JWFriendlyObstructionViewController ()

@property (nonatomic) UIButton *playbackToggle;
@property (nonatomic) UIImage *playIcon;
@property (nonatomic) UIImage *pauseIcon;

@property (nonatomic) BOOL playingAd;

@end

@implementation JWFriendlyObstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player.delegate = self;
    self.playIcon = [UIImage imageNamed:playIconName];
    self.pauseIcon = [UIImage imageNamed:pauseIconName];
    [self addCustomControl];
    JWFriendlyAdObstructions *friendlyAdObstructions = [[JWFriendlyAdObstructions alloc] initWithPlayer:self.player];
    [friendlyAdObstructions registerView:self.playbackToggle];
}

- (JWConfig *)createConfig
{
    JWConfig *config = [super createConfig];
    config.controls = NO;
    
    JWAdConfig *advertising = [JWAdConfig new];
    advertising.client = JWAdClientGoogima;
    advertising.schedule = @[[JWAdBreak adBreakWithTag:sampleAdTag offset:@"pre"]];
    
    config.advertising = advertising;
    
    return config;
}

- (void)addCustomControl
{
    self.playbackToggle = [UIButton new];
    UIView *playerView = self.player.view;
    CGFloat x = playerView.frame.size.width / 2;
    CGFloat y = playerView.frame.size.height / 2;
    self.playbackToggle.frame = CGRectMake(0, 0, 100, 100);
    self.playbackToggle.center = CGPointMake(x, y);
    [self.playbackToggle addTarget:self action:NSSelectorFromString(@"togglePlayback") forControlEvents:UIControlEventTouchDown];
    [self setPlayIcon];
    [playerView addSubview:self.playbackToggle];
}

- (void)togglePlayback
{
    JWPlayerState state = self.player.state;
    if (state == JWPlayerStatePlaying || state == JWPlayerStateBuffering) {
        [self pausePlayback];
    } else {
        [self resumePlayback];
    }
}

#pragma Mark - Player Delegate methods

- (void)onPlay:(JWEvent<JWStateChangeEvent> *)event
{
    [self setPauseIcon];
}

- (void)onPause:(JWEvent<JWStateChangeEvent> *)event
{
    [self setPlayIcon];
}

- (void)onAdPlay:(JWAdEvent<JWAdStateChangeEvent> *)event
{
    [self setPauseIcon];
}

- (void)onAdPause:(JWAdEvent<JWAdStateChangeEvent> *)event
{
    [self setPlayIcon];
}

- (void)onAdImpression:(JWAdEvent<JWAdImpressionEvent> *)event
{
    self.playingAd = YES;
}

- (void)onAdComplete:(JWAdEvent<JWAdDetailEvent> *)event
{
    self.playingAd = NO;
}

#pragma Mark - Helpers

- (void)setPlayIcon
{
    [self.playbackToggle setImage:self.playIcon forState:UIControlStateNormal];
}

- (void)setPauseIcon
{
    [self.playbackToggle setImage:self.pauseIcon forState:UIControlStateNormal];
}

- (void)pausePlayback
{
    if (self.playingAd) {
        [self.player pauseAd:YES];
    } else {
        [self.player pause];
    }
}

- (void)resumePlayback
{
    if (self.playingAd) {
        [self.player pauseAd:NO];
    } else {
        [self.player play];
    }
}

@end
