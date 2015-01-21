//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicTutorial.h"
#import "GameEvent.h"

@implementation BasicTutorial

+ (void)setUp{
    if(![[self alloc] init]){
        NSLog(@"Failed to init event");
    }
}

- (id)init{
    self = [super init];
    if (self)
    {
        [self performSelector:@selector(firstTutorial) withObject:nil afterDelay:3];
        
    }
    return self;
}

- (void)firstTutorial{
    CCScene* mainScene = [[CCDirector sharedDirector] runningScene];
    CCNode* tutorialLayer = (CCNode*)[CCBReader load:@"Tutorial/tutorial1"];
    [GameEvent dispatch:@"PauseMonsters" withArgument:nil];
    [mainScene addChild:tutorialLayer];
}

@end
