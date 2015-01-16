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

@property int hp;
@property NSString *elementType;
@property int atk;
@property float speed;
@property BOOL isAttacking;
@property int atkPeriod;

- (int)receiveHitWithHand:(Hand *)hand;
- (void)loadMonsterData: (MonsterData*)monsterData;
- (void)startAttack;


@end
