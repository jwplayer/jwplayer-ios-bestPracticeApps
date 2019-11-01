//
//  JWAirPlayViewController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/17/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWAirPlayViewController.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JWAirPlayViewController ()

@end

@implementation JWAirPlayViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpAirPlayButton];
}

- (void)setUpAirPlayButton
{
    UIView *buttonView = [[UIView new] init];
    CGRect buttonFrame = CGRectMake(0, 0, 50, 50);
    
    if (@available(iOS 11, *)) {
        // Creating an instance of AVRouteDetector causes AVRoutePickerView to correctly apply
        // the activeTintColor.
        AVRouteDetector *routeDetector = [[AVRouteDetector new] init];
        AVRoutePickerView *airplayButton = [[AVRoutePickerView alloc] initWithFrame: buttonFrame];
        airplayButton.activeTintColor = UIColor.blueColor;
        airplayButton.tintColor = UIColor.grayColor;
        buttonView = airplayButton;
    } else {
        MPVolumeView *airplayButton = [[MPVolumeView alloc] initWithFrame: buttonFrame];
        airplayButton.showsVolumeSlider = false;
        buttonView = airplayButton;
    }
    
    // Before iOS 13 if there are no AirPlay devices available, the button will not be displayed.
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView: buttonView];
    [self.navigationItem setRightBarButtonItem: barButtonItem animated: true];
}

@end
