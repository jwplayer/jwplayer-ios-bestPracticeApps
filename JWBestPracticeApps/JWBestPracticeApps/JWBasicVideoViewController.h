//
//  JWBasicVideoViewController.h
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/16/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JWPlayer_iOS_SDK/JWPlayerController.h>

@interface JWBasicVideoViewController : UIViewController<JWPlayerDelegate>

@property (nonatomic) JWPlayerController *player;

@end
