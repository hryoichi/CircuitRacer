//
//  AchievementsHelper.m
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

#import "AchievementsHelper.h"

static NSString * const kDestructionHeroAchievementId = @"com.hryoichi.CircuitRacer.destructionhero";
static NSString * const kAmateurAchievementId         = @"com.hryoichi.CircuitRacer.amateurracer";
static NSString * const kIntermediateAchievementId    = @"com.hryoichi.CircuitRacer.intermediateracer";
static NSString * const kProfessionalAchievementId    = @"com.hryoichi.CircuitRacer.professionalracer";

static const NSInteger kMaxCollisions = 20;

@implementation AchievementsHelper

+ (GKAchievement *)collisionAchievement:(NSUInteger)numOfCollisions {
    CGFloat percent = (numOfCollisions / kMaxCollisions) / 100;

    GKAchievement *collisionAchievement = [[GKAchievement alloc] initWithIdentifier:kDestructionHeroAchievementId];
    collisionAchievement.percentComplete = percent;
    collisionAchievement.showsCompletionBanner = YES;

    return collisionAchievement;
}

+ (GKAchievement *)achievementForLevel:(CRLevelType)levelType {
    NSString *achievementId = kAmateurAchievementId;

    if (levelType == CRLevelMedium) {
        achievementId = kIntermediateAchievementId;
    }
    else if (levelType == CRLevelHard) {
        achievementId = kProfessionalAchievementId;
    }

    GKAchievement *levelAchievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    levelAchievement.percentComplete = 100;
    levelAchievement.showsCompletionBanner = YES;

    return levelAchievement;
}

@end
