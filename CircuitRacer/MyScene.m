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
#import "AchievementsHelper.h"
#import "GameKitHelper.h"

typedef NS_OPTIONS(NSUInteger, CRPhysicsCategory) {
    CRBodyCar = 1 << 0,  // 0000001 = 1
    CRBodyBox = 1 << 1,  // 0000010 = 2
};

@interface MyScene () <SKPhysicsContactDelegate>

@property (nonatomic, assign) CRCarType carType;
@property (nonatomic, assign) CRLevelType levelType;
@property (nonatomic, assign) NSTimeInterval timeInSeconds;
@property (nonatomic, assign) NSInteger numOfLaps;
@property (nonatomic, strong) SKSpriteNode *car;
@property (nonatomic, strong) SKLabelNode *laps, *time;
@property (nonatomic, assign) NSInteger maxSpeed;
@property (nonatomic, assign) CGPoint trackCenter;
@property (nonatomic, assign) NSTimeInterval previousTimeInterval;
@property (nonatomic, assign) NSUInteger numOfCollisionsWithBoxes;

// Sound effects
@property (nonatomic, strong) SKAction *boxSoundAction;
@property (nonatomic, strong) SKAction *hornSoundAction;
@property (nonatomic, strong) SKAction *lapSoundAction;
@property (nonatomic, strong) SKAction *nitroSoundAction;

@end

@implementation MyScene

#pragma mark - Lifecycle

- (instancetype)initWithSize:(CGSize)size carType:(CRCarType)carType level:(CRLevelType)levelType {
    self = [super initWithSize:size];

    if (self) {
        _carType = carType;
        _levelType = levelType;
        _numOfCollisionsWithBoxes = 0;
        [self p_initializeGame];
    }

    return self;
}

- (void)update:(NSTimeInterval)currentTime {
    if (self.previousTimeInterval == 0) {
        self.previousTimeInterval = currentTime;
    }

    if (self.isPaused) {
        self.previousTimeInterval = currentTime;
        return;
    }

    if (currentTime - self.previousTimeInterval > 1) {
        self.timeInSeconds -= (currentTime - self.previousTimeInterval);
        self.previousTimeInterval = currentTime;
        self.time.text = [NSString stringWithFormat:@"Time: %.lf", self.timeInSeconds];
    }

    static CGFloat nextProgressAngle = M_PI;
    CGPoint vector = CGPointSubtract(self.car.position, self.trackCenter);
    CGFloat progressAngle = CGPointToAngle(vector) + M_PI;

    if (progressAngle > nextProgressAngle && (progressAngle - nextProgressAngle) < M_PI_4) {
        nextProgressAngle += M_PI_2;

        if (nextProgressAngle > 2 * M_PI) {
            nextProgressAngle = 0;
        }

        if (fabsf(nextProgressAngle - M_PI) < FLT_EPSILON) {
            self.numOfLaps -= 1;
            self.laps.text = [NSString stringWithFormat:@"Laps: %li", (long)self.numOfLaps];

            [self runAction:self.lapSoundAction];
        }
    }

    if (self.timeInSeconds < 0 || self.numOfLaps == 0) {
        self.paused = YES;
        BOOL hasWon = self.numOfLaps == 0;

        [self p_reportAchievementsForGameState:hasWon];
        self.gameOverBlock(hasWon);
    }
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

    _trackCenter = track.position;

    _boxSoundAction = [SKAction playSoundFileNamed:@"box.wav" waitForCompletion:NO];
    _hornSoundAction = [SKAction playSoundFileNamed:@"horn.wav" waitForCompletion:NO];
    _lapSoundAction = [SKAction playSoundFileNamed:@"lap.wav" waitForCompletion:NO];
    _nitroSoundAction = [SKAction playSoundFileNamed:@"nitro.wav" waitForCompletion:NO];

    self.physicsWorld.contactDelegate = self;
}

- (void)p_loadLevel {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LevelDetails" ofType:@"plist"];
    NSArray *level = [NSArray arrayWithContentsOfFile:filePath];

    NSNumber *timeInSeconds = level[_levelType - 1][@"time"];
    _timeInSeconds = [timeInSeconds doubleValue];

    NSNumber *laps = level[_levelType - 1][@"laps"];
    _numOfLaps = [laps integerValue];
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
    _laps.text = [NSString stringWithFormat:@"Laps: %li", (long)_numOfLaps];
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

- (void)p_reportAchievementsForGameState:(BOOL)hasWon {
    NSMutableArray *achievements = [@[] mutableCopy];

    [achievements addObject:[AchievementsHelper collisionAchievement:self.numOfCollisionsWithBoxes]];

    if (hasWon) {
        [achievements addObject:[AchievementsHelper achievementForLevel:self.levelType]];
    }

    [[GameKitHelper sharedGameKitHelper] reportAchievements:achievements];
}

#pragma mark - Key-Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"relativePosition"]) {
        [self p_analogControlUpdated:object];
    }
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask == CRBodyCar + CRBodyBox) {
        self.numOfCollisionsWithBoxes += 1;

        [self runAction:self.boxSoundAction];
    }
}

@end
