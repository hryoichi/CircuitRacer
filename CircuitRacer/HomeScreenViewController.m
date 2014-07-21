//
//  HomeScreenViewController.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/21.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "GameKitHelper.h"
#import "SelectCarViewController.h"
#import "SKTAudio.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Actions

- (IBAction)playButtonDidTouchUpInside:(id)sender {
    [[SKTAudio sharedInstance] playSoundEffect:@"button_press.wav"];

    SelectCarViewController *selectCarVC = [self.storyboard
        instantiateViewControllerWithIdentifier:@"SelectCarViewController"];

    [self.navigationController pushViewController:selectCarVC animated:YES];
}

- (IBAction)gameCenterButtonDidTouchUpInside:(id)sender {
    [[SKTAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    [[GameKitHelper sharedGameKitHelper] showGKGameCenterViewController:self];
}

@end
