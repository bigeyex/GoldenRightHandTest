//
//  Hand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hand.h"
#import "GameEvent.h"

@implementation Hand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
    self.physicsBody.collisionMask = @[];
    
    // set up the hand type
    _range = 800.0;
    _atk = 5.0;
    _skillTimes = 1;
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

-(void)playHitSound{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"normalFist.mp3"];
}

- (void)removeParticleEffect{
    
}

@end

@implementation FireHand

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    
    // set up the hand type
    self.atk = 10.0;
    _skillRange = 150.0;
    self.skillTimes = 1;
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
                [GameEvent dispatch:@"MonsterDefeated" withArgument:_checkNode];
                [_checkNode removeFromParent];
                i--;
                numOfMonsters--;
            }
        }
    }
    return 0.0;
}

-(void)playHitSound{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"fireFist.mp3"];
}

@end

@implementation IceHand

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    // set up the hand type
    self.atk = 10;
    _skillRange = 150.0;
    self.skillTimes = 1;
    _skillDuration = 4;
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"IceHandHitEffect"];
    
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self addChild:fistHitEffect];
}

-(float)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    
    // load hand particle effect
    [self handParticleEffectAtPosition:self.anchorPointInPoints];
    
    // decrease the number of times this skill can be used
    self.skillTimes--;
    
    int numOfMonsters = (int)[monsterList.children count];
    int i;
    for (i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = monsterList.children[i];
        double distance = ccpDistance(_checkNode.positionInPoints,nodeA.positionInPoints);
        if (distance<self.skillRange){
            // this is to avoid the ice image being added twice by icehand skill and icestorm skill
            if(!_checkNode.isStopped){
                CCSprite* iceImage = [CCSprite spriteWithImageNamed:@"UI/ice-block.png"];
                iceImage.name = @"iceblock";
                iceImage.position = _checkNode.position;
                [_checkNode addChild:iceImage];
            }
            [_checkNode stopMovingForDuration:_skillDuration];
        }
    }
    return 0.0;
}

-(void)playHitSound{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"iceFist2.mp3"];
}

@end

@implementation DarkHand

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    
    // set up the hand type
    self.atk = 10.0;
    self.skillTimes = 3;
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"DarkHandHitEffect"];
    
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self addChild:fistHitEffect];
}

-(float)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    
    // load hand particle effect
    [self handParticleEffectAtPosition:self.anchorPointInPoints];
    
    // decrease the number of times this skill can be used
    self.skillTimes--;
    
    return MAX(self.atk,nodeA.hp);
}

/*
 -(void)playHitSound{
 // play sound effect
 OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
 [audio playEffect:@"darkFist.mp3"];
 }
 */
@end

@implementation DeathHand

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    
    // set up the hand type
    self.atk = 100.0; // this hand is designed to kill any monster upon hit
    self.skillTimes = 5;
}

-(void)handParticleEffectAtPosition:(CGPoint)pos{
    
    // load particle effect
    CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"DeathHandHitEffect"];
    
    fistHitEffect.autoRemoveOnFinish = TRUE;
    fistHitEffect.position = pos;
    [self addChild:fistHitEffect];
}

-(float)handSkillwithMonster:(Monster *)nodeA MonsterList: (CCNode *)monsterList{
    
    // load hand particle effect
    [self handParticleEffectAtPosition:self.anchorPointInPoints];
    
    // decrease the number of times this skill can be used
    self.skillTimes--;
    
    return 0.0;
}

-(void)playHitSound{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"deathFist2.mp3"];
}

@end
