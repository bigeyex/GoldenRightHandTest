//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial.h"
#import "GameEvent.h"


@implementation Tutorial

+ (void)setUp{
    if(![[self alloc] init]){
        NSLog(@"Failed to init event");
    }
}

- (id)init{
    self = [super init];
    if (self)
    {
        
        
    }
    return self;
}

- (void)showTutorialScreen:(NSString*)screenName afterDelay:(float)delay{
    [self performSelector:@selector(showTutorialScreen:) withObject:screenName afterDelay:delay];
}

- (void)showTutorialScreen:(NSString*)screenName{
    if(![[CCDirector sharedDirector] isPaused]){
        CCScene* mainScene = [[CCDirector sharedDirector] runningScene];
        CCNode* tutorialLayer = (CCNode*)[CCBReader load:screenName];
        [GameEvent dispatch:@"PauseMonsters" withArgument:nil];
        [mainScene addChild:tutorialLayer];
    }
}

@end
