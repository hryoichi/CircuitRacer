//
//  MyScene.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/06/25.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "MyScene.h"

@interface MyScene ()

@property (nonatomic, assign) CRCarType carType;
@property (nonatomic, assign) CRLevelType levelType;

@end

@implementation MyScene

#pragma mark - Lifecycle

- (instancetype)initWithSize:(CGSize)size carType:(CRCarType)carType level:(CRLevelType)levelType {
    self = [super initWithSize:size];

    if (self) {
        _carType = carType;
        _levelType = levelType;
        [self p_initializeGame];
    }

    return self;
}

#pragma mark - Private

- (void)p_initializeGame {

}

@end
