//
//  SelectCarViewController.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/01.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "SelectCarViewController.h"
#import "SelectLevelViewController.h"
#import "SKTAudio.h"

@interface SelectCarViewController ()

@end

@implementation SelectCarViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[SKTAudio sharedInstance] playBackgroundMusic:@"circuitracer.mp3"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Actions

- (IBAction)carButtonDidTouchUpInside:(UIButton *)sender {
    [[SKTAudio sharedInstance] playSoundEffect:@"button_press.wav"];

    SelectLevelViewController *levelVC = [self.storyboard
        instantiateViewControllerWithIdentifier:NSStringFromClass([SelectLevelViewController class])];
    levelVC.carType = sender.tag;

    [self.navigationController pushViewController:levelVC animated:YES];
}

@end
