//
//  SelectLevelViewController.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/01.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "SelectLevelViewController.h"
#import "ViewController.h"
#import "SKTAudio.h"

@interface SelectLevelViewController ()

@end

@implementation SelectLevelViewController

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

- (IBAction)backButtonDidTouchUpInside:(id)sender {
    [[SKTAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)levelButtonDidTouchUpInside:(UIButton *)sender {
    [[SKTAudio sharedInstance] playSoundEffect:@"button_press.wav"];

    ViewController *gameVC = [self.storyboard
        instantiateViewControllerWithIdentifier:NSStringFromClass([ViewController class])];
    gameVC.carType = self.carType;
    gameVC.levelType = sender.tag;

    [self.navigationController pushViewController:gameVC animated:YES];
}

@end
