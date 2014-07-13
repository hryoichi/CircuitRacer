//
//  CircuitRacerNavigationController.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "CircuitRacerNavigationController.h"
#import "GameKitHelper.h"

@interface CircuitRacerNavigationController ()

@end

@implementation CircuitRacerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];

    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Observer

- (void)p_showAuthenticationViewController {
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];

    [self.topViewController presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

@end
