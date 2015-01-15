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
    NSLog(@"Fire Hand is loaded!");
}

-(void)handParticleEffect{
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FistHitEffect"];
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = self.anchorPointInPoints;
    [self addChild:fistHitEffect];
}

-(void)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterlist{
    NSLog(@"Fire Hand skill is triggered!");
}

@end
