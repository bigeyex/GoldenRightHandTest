//
//  FireHand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "FireHand.h"
#import "Monster.h"

@implementation FireHand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
    self.physicsBody.collisionMask = @[@"monster"];
    
    // set up the hand type
    self.range = 800.0;
    self.atk = 10.0;
    _skillRange = 150.0;
    self.skillTimes = 1;
    self.handType = 0;
    _skillDamage = 0.5*self.atk;
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FireHandHitEffect"];
    
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self.parent.parent addChild:fistHitEffect];
}

-(float)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    
    // load hand particle effect
    [self handParticleEffectAtPosition:nodeA.positionInPoints];
    
    // decrease the number of times this skill can be used
    self.skillTimes--;
    
    int numOfMonsters = (int)[monsterList.children count];
    int i;
    for (i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = monsterList.children[i];
        double distance = ccpDistance(_checkNode.positionInPoints,nodeA.positionInPoints);
        if ((distance<self.skillRange)&&(distance>0)){
            BOOL isKilled = [_checkNode receiveHitWithDamage:self.skillDamage];
            if (isKilled){
                [_checkNode removeFromParent];
                i--;
                numOfMonsters--;
            }
        }
    }
    return 0.0;
}

@end
