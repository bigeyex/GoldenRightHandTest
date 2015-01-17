//
//  Monster.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class MonsterData;
#import "Hand.h"

@interface Monster : CCSprite

@property float hp;
@property int elementType; // 0 for fire, 1 for ice ...
@property float atk;
@property float speed;
@property BOOL isAttacking;
@property float atkPeriod;

- (BOOL)receiveHitWithDamage:(float)Damage;
- (void)loadMonsterData: (MonsterData*)monsterData;
- (void)startAttack;


@end
