//
//  TutorialNode.m
//  RubberMan
//
//  Created by Wang Yu on 1/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TutorialNode.h"
#import "GameEvent.h"

@implementation TutorialNode

- (id)init
{
    if (self = [super init])
    {
        // activate touches on this scene
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [GameEvent dispatch:@"ResumeMonsters"];
    [self removeFromParent];
}


@end
