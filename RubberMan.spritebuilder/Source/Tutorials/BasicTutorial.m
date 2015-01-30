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
    Monster *tutorialMonster = (Monster *)[CCBReader load:@"Monsters/MonsterBat"];
    tutorialMonster.position = ccp(350,200);
    tutorialMonster.name = @"firstTutorialMonster";
    [self.monsterList addChild:tutorialMonster];
}

-(void)continueFirstLevel:(Monster *)nodeA{
    if([nodeA.name isEqualToString:@"firstTutorialMonster"]){
        [GameEvent dispatch:@"ResumeMonsters"];
        [GameEvent dispatch:@"GetMana"];
    }
}


@end
