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
@property int handType;

-(void)handParticleEffectAtPosition:(CGPoint)pos;
-(void)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterlist;

@end
