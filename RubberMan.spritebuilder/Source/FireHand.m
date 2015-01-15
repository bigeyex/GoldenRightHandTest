//
//  FireHand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "FireHand.h"

@implementation FireHand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
    
    // set up the hand type
    self.handType = @"fire";
    self.range = 800;
    self.atk = 10;
    _skillRange = 300;
    NSLog(@"Fire Hand is loaded!");
}

-(void)handParticleEffect{
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FireHandHitEffect"];
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = self.anchorPointInPoints;
    [self addChild:fistHitEffect];
}

-(void)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    int numOfMonsters = (int)[monsterList.children count];
    int i;
    for (i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = monsterList.children[i];
        double distance = ccpDistance(_checkNode.positionInPoints,nodeA.positionInPoints);
        if (distance<self.skillRange){
            [_checkNode removeFromParent];
            i--;
            numOfMonsters--;
        }
    }

}

@end
