//
//  SkillButtonTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SkillButtonTutorial.h"
#import "GameEvent.h"
#import "BattleScene.h"

@implementation SkillButtonTutorial{
    CCNode* tutorialArrow;
}

- (id)init{
    self = [super init];
    if (self)
    {
        [GameEvent subscribe:@"GetSkill" forObject:self withSelector:@selector(showTutorialAfterGettingSkill)];
        [GameEvent subscribe:@"UseSkill" forObject:self withSelector:@selector(hideTutorialAfterUsingSkill)];
        tutorialArrow = nil;
    }
    return self;
}

- (void)showTutorialAfterGettingSkill{
    if(tutorialArrow==nil){
        BattleScene *mainScene = (BattleScene*)[[CCDirector sharedDirector] runningScene];
        tutorialArrow = [CCBReader load:@"TutorialArrow"];
        tutorialArrow.position = ccp(516, 106);
        [mainScene addChild:tutorialArrow];
    }
}

- (void)hideTutorialAfterUsingSkill{
    if(tutorialArrow != nil){
        [tutorialArrow removeFromParent];
        tutorialArrow = nil;
    }
}

@end
