//
//  MyScene.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/06/25.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "MyScene.h"
#import "AnalogControl.h"
#import "SKTUtils.h"

typedef NS_OPTIONS(NSUInteger, CRPhysicsCategory) {
    CRBodyCar = 1 << 0,  // 0000001 = 1
    CRBodyBox = 1 << 1,  // 0000010 = 2
};

@interface MyScene ()

@property (nonatomic, assign) CRCarType carType;
@property (nonatomic, assign) CRLevelType levelType;
@property (nonatomic, assign) NSTimeInterval timeInSeconds;
@property (nonatomic, assign) NSInteger noOfLabs;
@property (nonatomic, strong) SKSpriteNode *car;
@property (nonatomic, strong) SKLabelNode *laps, *time;
@property (nonatomic, assign) NSInteger maxSpeed;

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
    [self p_loadLevel];

    SKSpriteNode *track = ({
        NSString *imageName = [NSString stringWithFormat:@"track_%i", _levelType];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        sprite;
    });
    [self addChild:track];

    [self p_addCarAtPosition:CGPointMake(CGRectGetMidX(track.frame), 50.0f)];

    // Turn off the world's gravity
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsBody = ({
        CGRect frame = CGRectInset(track.frame, 40.0f, 0.0f);
        SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeLoopFromRect:frame];
        body;
    });

    [self p_addObjectsForTrack:track];
    [self p_addGameUIForTrack:track];

    _maxSpeed = 125 * (1 + _carType);
}

- (void)p_loadLevel {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LevelDetails" ofType:@"plist"];
    NSArray *level = [NSArray arrayWithContentsOfFile:filePath];

    NSNumber *timeInSeconds = level[_levelType - 1][@"time"];
    _timeInSeconds = [timeInSeconds doubleValue];

    NSNumber *laps = level[_levelType - 1][@"laps"];
    _noOfLabs = [laps integerValue];
}

- (void)p_addCarAtPosition:(CGPoint)startPosition {
    _car = ({
        NSString *imageName = [NSString stringWithFormat:@"car_%i", _carType];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        sprite.position = startPosition;
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.frame.size];
        sprite.physicsBody.categoryBitMask    = CRBodyCar;
        sprite.physicsBody.collisionBitMask   = CRBodyBox;
        sprite.physicsBody.contactTestBitMask = CRBodyBox;
        sprite.physicsBody.allowsRotation = NO;
        sprite;
    });
    [self addChild:_car];
}


- (void)p_addBoxAt:(CGPoint)point {
    SKSpriteNode *box = [SKSpriteNode spriteNodeWithImageNamed:@"box"];
    box.position = point;
    box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:box.size];
    box.physicsBody.categoryBitMask = CRBodyBox;

    // Simulate friction and prevent the boxes from continuously sliding around
    box.physicsBody.linearDamping = 1.0f;
    box.physicsBody.angularDamping = 1.0f;

    [self addChild:box];
}

- (void)p_addObjectsForTrack:(SKSpriteNode *)track {
    SKNode *innerBoundary = [SKNode node];
    innerBoundary.position = track.position;
    [self addChild:innerBoundary];

    innerBoundary.physicsBody = [SKPhysicsBody
        bodyWithRectangleOfSize:CGSizeMake(180.0f, 120.0f)];
    innerBoundary.physicsBody.dynamic = NO;

    [self p_addBoxAt:CGPointMake(track.position.x + 130.0f, track.position.y)];
    [self p_addBoxAt:CGPointMake(track.position.x - 200.0f, track.position.y)];
}

- (void)p_addGameUIForTrack:(SKSpriteNode *)track {
    // Displays the laps to go as set from LevelDetails.plist
    _laps = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _laps.text = [NSString stringWithFormat:@"Laps: %li", (long)_noOfLabs];
    _laps.fontSize = 28.0f;
    _laps.fontColor = [UIColor whiteColor];
    _laps.position = CGPointMake(track.position.x, track.position.y + 20.0f);
    [self addChild:_laps];

    // Shows the time left to finish the laps remaining
    _time = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _time.text = [NSString stringWithFormat:@"Time: %li", (long)_timeInSeconds];
    _time.fontSize = 28.0f;
    _time.fontColor = [UIColor whiteColor];
    _time.position = CGPointMake(track.position.x, track.position.y - 10.0f);
    [self addChild:_time];
}

- (void)p_analogControlUpdated:(AnalogControl *)analogControl {
    // Negate the y-axis to bridge a gap between SpriteKit and UIKit
    self.car.physicsBody.velocity = CGVectorMake(
        analogControl.relativePosition.x * self.maxSpeed,
        -analogControl.relativePosition.y * self.maxSpeed
    );

    if (!CGPointEqualToPoint(analogControl.relativePosition, CGPointZero)) {
        self.car.zRotation = ({
            CGPoint point = CGPointMake(
                analogControl.relativePosition.x,
                -analogControl.relativePosition.y
            );

            CGFloat angle = CGPointToAngle(point);
            angle;
        });
    }
}

#pragma mark - Key-Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"relativePosition"]) {
        [self p_analogControlUpdated:object];
    }
}

@end
