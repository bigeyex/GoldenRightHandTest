//
//  Monster.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class MonsterData;

@interface Monster : CCSprite

@property float hp;
@property NSString *elementType; // fire, ice and dark
@property float atk;
@property float speed;
@property BOOL isAttacking;
@property float atkPeriod;
@property BOOL isEvading;
@property BOOL isStopped;
@property (nonatomic) BOOL isElite;
@property float spdBuff;
@property BOOL isAlive;

@property CCNode* rankIcon;

- (BOOL)receiveHitWithDamage:(float)Damage;
- (void)loadMonsterData: (MonsterData*)monsterData;
- (void)startAttack;
- (void)stopMovingForDuration:(float)duration;
- (void)monsterEvade;
- (void)monsterCharge;
- (void)monsterChargeCancel;
- (void)seekProtection:(CCNode *)monsterList;
- (BOOL)protectMonsters:(Monster *)nodeA;

@end

@interface MonsterWalker : Monster

@end

@interface MonsterBat : Monster

@end

@interface MonsterGhost : Monster

@end

@interface MonsterBomb : Monster

@property CCNode* enlargedEye;

@end

@interface MonsterSausage : Monster

@end