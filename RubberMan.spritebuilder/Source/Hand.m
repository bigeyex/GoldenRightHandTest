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
    
    // set up the hand type
    _handType = @"normal";
    _range = 500;
    _atk = 10;
    
}

-(void)handParticleEffect{
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FistHitEffect"];
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = self.anchorPointInPoints;
    [self addChild:fistHitEffect];
}

-(void)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    
}

@end
