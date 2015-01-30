//
//  SkillButtonTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SkillButtonTutorial.h"
#import "GameEvent.h"

@implementation SkillButtonTutorial

- (id)init{
    self = [super init];
    if (self)
    {
        [GameEvent subscribe:@"GetSkill" forObject:self withSelector:@selector(showTutorialAfterGettingSkill)];
        
    }
    return self;
}

- (void)showTutorialAfterGettingSkill{
    CCScene *mainScene = [[CCDirector sharedDirector] runningScene];
    CCNode *tutorialArrow = [CCBReader load:@"TutorialArrow"];
//    tutorialArrow.position = ccp(
}

@end
