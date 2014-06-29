//
//  AnalogControl.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/06/27.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "AnalogControl.h"
#import "SKTUtils.h"

@interface AnalogControl ()

@property (nonatomic, strong) UIImageView *knobImageView;

// Store the position that is the neutral position of the control
@property (nonatomic, assign) CGPoint baseCenter;

@end

@implementation AnalogControl

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.userInteractionEnabled = YES;

        UIImageView *baseImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        baseImageView.contentMode = UIViewContentModeScaleAspectFit;
        baseImageView.image = [UIImage imageNamed:@"base"];
        [self addSubview:baseImageView];

        _baseCenter = CGPointMake(CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2);

        _knobImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"knob"]];
        _knobImageView.center = _baseCenter;
        [self addSubview:_knobImageView];

        NSAssert(CGRectContainsRect(self.bounds, _knobImageView.bounds),
                 @"Analog control size should be greater than the knob size");
    }

    return self;
}

#pragma mark - Actions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    [self p_updateKnobWithPosition:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    [self p_updateKnobWithPosition:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self p_updateKnobWithPosition:self.baseCenter];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self p_updateKnobWithPosition:self.baseCenter];
}

#pragma mark - Private

- (void)p_updateKnobWithPosition:(CGPoint)position {
    CGPoint positionToCenter = CGPointSubtract(position, self.baseCenter);
    CGPoint direction;

    if (CGPointEqualToPoint(positionToCenter, CGPointZero)) {
        direction = CGPointZero;
    }
    else {
        direction = CGPointNormalize(positionToCenter);
    }

    CGFloat radius = CGRectGetWidth(self.frame) / 2;
    CGFloat length = CGPointLength(positionToCenter);

    if (length > radius) {
        length = radius;
        positionToCenter = CGPointMultiplyScalar(direction, radius);
    }

    CGPoint relativePosition = CGPointMake(
        direction.x * length / radius,
        direction.y * length / radius
    );

    self.knobImageView.center = CGPointAdd(self.baseCenter, positionToCenter);
    self.relativePosition = relativePosition;
}

@end
