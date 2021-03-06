//
//  MonsterData.h
//  RubberMan
//
//  Created by Wang Yu on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Monster;
@class MonsterDataModifier;

@interface MonsterData : NSObject

@property (nonatomic, strong) NSString* spriteName;
@property CGFloat enterTime;
@property CGFloat respawnInterval;
@property int number;
@property CGFloat positionY;
@property CGFloat positionX;
@property float health;
@property float speed;
@property BOOL isElite;
@property NSMutableArray *modifiers;

+ (id)fromSpriteName: (NSString*) spriteName;
- (id)initWithSpriteName: (NSString*) spriteName;
- (BOOL)shouldRespawn: (CGFloat)timeSinceGameStarted;
- (BOOL)hasNextUnit;
- (Monster*)respawn;


@end


@interface MonsterDataModifier : NSObject

@property CGFloat maxValue;
@property CGFloat minValue;
@property CGFloat delta;
@property CGFloat variation;
@property NSString* name;


- (void)runModifierForMonsterData:monsterData;

@end
