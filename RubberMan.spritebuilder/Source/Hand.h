//
//  Hand.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class Monster;

@interface Hand : CCSprite

@property float range;
@property float atk;
@property int skillTimes;

-(void)handParticleEffectAtPosition:(CGPoint)pos;
-(void)handSkillwithMonsterPosition:(CGPoint)monsterPosition MonsterList: (CCNode *)monsterlist;

@end
