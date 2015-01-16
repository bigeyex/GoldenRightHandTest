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

@property NSString *handType;
@property int range;
@property int atk;

-(void)handParticleEffect;
-(void)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterlist;

@end
