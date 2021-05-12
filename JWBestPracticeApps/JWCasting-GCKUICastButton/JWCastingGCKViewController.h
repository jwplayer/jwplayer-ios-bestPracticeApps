//
//  JWCastingGCKViewController.h
//  JWCasting-GCKUICastButton
//
//  Created by Michael Salvador on 5/12/21.
//  Copyright © 2021 Karim Mourra. All rights reserved.
//

#import "JWBasicVideoViewController.h"

@interface JWCastingGCKViewController : JWBasicVideoViewController <JWCastingDelegate>

@property (nonatomic) JWCastController *castController;

@end

