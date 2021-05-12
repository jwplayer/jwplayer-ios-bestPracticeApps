//
//  JWCastingGCKViewController.m
//  JWCasting-GCKUICastButton
//
//  Created by Michael Salvador on 5/12/21.
//  Copyright © 2021 Karim Mourra. All rights reserved.
//

#import "JWCastingGCKViewController.h"
#import <GoogleCast/GoogleCast.h>

@interface JWCastingGCKViewController ()<UIActionSheetDelegate>

@property (nonatomic) UIButton *castingButton;
@property (nonatomic) UIBarButtonItem *castingItem;

@end

@implementation JWCastingGCKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor =[UIColor grayColor];
    [self setUpCastController];
}

- (void)setUpCastController
{
    self.castController = [[JWCastController alloc]initWithPlayer:self.player];
    self.castController.chromeCastReceiverAppID = kGCKDefaultMediaReceiverApplicationID;
    self.castController.delegate = self;
    [self.castController scanForDevices];
    [self setUpCastingButton];
}

- (void)setUpCastingButton
{
    self.castingButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.castingButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.castingButton];
}

#pragma Mark - JWCastingDelegate

- (void)onCastingDevicesAvailable:(nonnull NSArray<JWCastingDevice *> *)devices {
}

- (void)onConnectedToCastingDevice:(JWCastingDevice *)device
{
    [self.castController cast];
}

- (void)onConnectionRecovered
{
    [self.castController cast];
}

@end
