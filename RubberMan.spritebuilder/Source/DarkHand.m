//
//  DarkHand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "DarkHand.h"
#import "Monster.h"

@implementation DarkHand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
    self.physicsBody.collisionMask = @[@"monster"];
    
    // set up the hand type
    self.range = 800.0;
    self.atk = 10.0;
    self.skillTimes = 1;
    self.handType = 2;
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"IceHandHitEffect"];
    
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self addChild:fistHitEffect];
}

-(void)handSkillwithMonsterPosition:(CGPoint)monsterPosition MonsterList: (CCNode *)monsterList{
    
    // load hand particle effect
    [self handParticleEffectAtPosition:self.anchorPointInPoints];
    
    // decrease the number of times this skill can be used
    self.skillTimes--;
    
}

@end
