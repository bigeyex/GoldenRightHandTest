//
//  Hand.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Monster.h"

@interface Hand : CCSprite

@property float range;
@property float atk;
@property int skillTimes;

-(void)handParticleEffectAtPosition:(CGPoint)pos;
-(float)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterlist;
-(void)playHitSound;

@end

@interface FireHand : Hand

@property float skillRange;
@property float skillDamage;

@end

@interface IceHand : Hand

@property float skillRange;
@property float skillDuration;

@end

@interface DarkHand : Hand

@end

@interface DeathHand : Hand

@end


