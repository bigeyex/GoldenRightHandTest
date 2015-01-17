//
//  IceHand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "IceHand.h"
#import "Monster.h"

@implementation IceHand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
    self.physicsBody.collisionMask = @[@"monster"];
    
    // set up the hand type
    self.range = 800.0;
    self.atk = 10.0;
    _skillRange = 150.0;
    self.skillTimes = 1;
    _skillDuration = 5;
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
    
    int numOfMonsters = (int)[monsterList.children count];
    int i;
    for (i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = monsterList.children[i];
        double distance = ccpDistance(_checkNode.positionInPoints,monsterPosition);
        if (distance<self.skillRange){
            [_checkNode stopMovingForDuration:_skillDuration];
        }
    }

    
}

@end
