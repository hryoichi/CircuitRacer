//
//  MyScene.h
//  CircuitRacer
//

//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import SpriteKit;

@interface MyScene : SKScene

@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);

- (instancetype)initWithSize:(CGSize)size carType:(CRCarType)carType level:(CRLevelType)levelType;

@end
