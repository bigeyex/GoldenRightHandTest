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
    self.handType = @"fire";
    self.range = 800.0;
    self.atk = 20.0;
    _skillRange = 150.0;
    _skillDamage = 0.5*self.atk;
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FireHandHitEffect"];
    
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self.parent.parent addChild:fistHitEffect];
}

-(void)handSkillwithMonsterPosition:(CGPoint)monsterPosition MonsterList: (CCNode *)monsterList{
    
    // load hand particle effect
    [self handParticleEffectAtPosition:monsterPosition];

    int numOfMonsters = (int)[monsterList.children count];
    int i;
    for (i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = monsterList.children[i];
        double distance = ccpDistance(_checkNode.positionInPoints,monsterPosition);
        if (distance<self.skillRange){
            BOOL isKilled = [_checkNode receiveHitWithDamage:self.skillDamage];
            if (isKilled){
                i--;
                numOfMonsters--;
            }
        }
    }

}

@end
