//
//  Hand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hand.h"

@implementation Hand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
    self.physicsBody.collisionMask = @[@"monster"];
    
    // set up the hand type
    _range = 800.0;
    _atk = 5.0;
    _skillTimes = 1;
    _handType = -1;
    
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FistHitEffect"];
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self addChild:fistHitEffect];
}

-(float)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    // load hand particle effect
    [self handParticleEffectAtPosition:self.anchorPointInPoints];
    return 0.0;
}

@end
