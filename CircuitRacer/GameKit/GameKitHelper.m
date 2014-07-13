//
//  GameKitHelper.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "GameKitHelper.h"

NSString * const PresentAuthenticationViewController = @"present_authentication_view_controller";

@interface GameKitHelper ()

@property (nonatomic, assign) BOOL enableGameCenter;

@end

@implementation GameKitHelper

#pragma mark - Lifecycle

+ (instancetype)sharedGameKitHelper {
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });

    return sharedGameKitHelper;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _enableGameCenter = YES;
    }

    return self;
}

#pragma mark - Accessors

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController {
    if (authenticationViewController) {
        _authenticationViewController = authenticationViewController;

        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self userInfo:nil];
    }
}

- (void)setLastError:(NSError *)lastError {
    _lastError = [lastError copy];

    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}

#pragma mark - Public

- (void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        [self setLastError:error];

        if (viewController) {
            [self setAuthenticationViewController:viewController];
        }
        else if ([GKLocalPlayer localPlayer].isAuthenticated) {
            self.enableGameCenter = YES;
        }
        else {
            self.enableGameCenter = NO;
        }
    };
}

- (void)reportAchievements:(NSArray *)achievements {
    if (!self.enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }

    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
    }];
}

@end
