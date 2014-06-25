//
//  MyScene.h
//  CircuitRacer
//

//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import SpriteKit;

@interface MyScene : SKScene

- (instancetype)initWithSize:(CGSize)size carType:(CRCarType)carType level:(CRLevelType)levelType;

@end
