//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicTutorial.h"
#import "GameEvent.h"
#import "Monster.h"

float const secondsBeforeFirstTutorial=1;

@implementation BasicTutorial


- (id)init{
    self = [super init];
    if (self)
    {
        [self showTutorialScreen:@"Tutorial/tutorial1" afterDelay:secondsBeforeFirstTutorial];
    }
    return self;
}

-(void)setup{
    [GameEvent subscribe:@"MonsterDefeated" forObject:self withSelector:@selector(continueFirstLevel:)];
    [GameEvent subscribe:@"AimingHand" forObject:self withSelector:@selector(blackoutTutorialLayer)];
    [GameEvent subscribe:@"ReleaseHand" forObject:self withSelector:@selector(unBlackoutTutorialLayer)];
    Monster *tutorialMonster = (Monster *)[CCBReader load:@"Monsters/MonsterGhost"];
    tutorialMonster.position = ccp(350,200);
    tutorialMonster.name = @"firstTutorialMonster";
    [self.monsterList addChild:tutorialMonster];
}

- (void)blackoutTutorialLayer{
    self.lastTutorialNode.visible = NO;
}

- (void)unBlackoutTutorialLayer{
    self.lastTutorialNode.visible = YES;
}

-(void)continueFirstLevel:(Monster *)nodeA{
    if([nodeA.name isEqualToString:@"firstTutorialMonster"]){
        [GameEvent dispatch:@"ResumeMonsters"];
        [GameEvent dispatch:@"GetMana"];
        [self performSelector:@selector(endFirstTutorial) withObject:nil afterDelay:0.2f];
    }
}

- (void)endFirstTutorial{
    [GameEvent unsubscribe:@"AimingHand" forObject:self withSelector:@selector(blackoutTutorialLayer)];
    [GameEvent unsubscribe:@"ReleaseHand" forObject:self withSelector:@selector(unBlackoutTutorialLayer)];
    [self.lastTutorialNode removeFromParent];
}


@end
