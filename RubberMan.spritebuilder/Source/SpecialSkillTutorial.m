//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpecialSkillTutorial.h"
#import "GameEvent.h"

float const secondsBeforeTutorialScreen=0.5f;

@implementation SpecialSkillTutorial


- (id)init{
    self = [super init];
    if (self)
    {
        [GameEvent subscribe:@"GetSkill" forObject:self withSelector:@selector(showTutorialAfterGettingSkill)];
        
    }
    return self;
}

- (void)showTutorialAfterGettingSkill{
    [self performSelector:@selector(unsubscribeEvent) withObject:nil afterDelay:0.2f];
    [self showTutorialScreen:@"Tutorial/tutorial2" afterDelay:secondsBeforeTutorialScreen];
}

- (void)unsubscribeEvent{
    [GameEvent unsubscribe:@"GetSkill" forObject:self withSelector:@selector(showTutorialAfterGettingSkill)];
}


@end
