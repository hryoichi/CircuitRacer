//
//  GameKitHelper.h
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import Foundation;
@import GameKit;

UIKIT_EXTERN NSString * const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject

@property (nonatomic, strong, readonly) UIViewController *authenticationViewController;
@property (nonatomic, strong, readonly) NSError *lastError;

+ (instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;
- (void)reportAchievements:(NSArray *)achievements;

@end
