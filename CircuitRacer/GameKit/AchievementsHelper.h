//
//  AchievementsHelper.h
//  CircuitRacer
//
//  Created by Ryoichi Hara on 2014/07/13.
//  Copyright (c) 2014年 Ryoichi Hara. All rights reserved.
//

@import Foundation;
@import GameKit;

@interface AchievementsHelper : NSObject

+ (GKAchievement *)collisionAchievement:(NSUInteger)numOfCollisions;
+ (GKAchievement *)achievementForLevel:(CRLevelType)levelType;

@end
