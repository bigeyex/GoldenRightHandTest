//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial.h"
#import "GameEvent.h"
#import "LevelLoader.h"


@implementation Tutorial

+ (void)setUpWithLevelLoader:(LevelLoader*)levelLoader{
    Tutorial *instance =[[self alloc] init];
    if(!instance){
        NSLog(@"Failed to init event");
    }
    instance.monsterList = levelLoader;
    [instance setup];
}

- (id)init{
    self = [super init];
    if (self)
    {
        
        
    }
    return self;
}

- (void)setup{
    
}

- (void)showTutorialScreen:(NSString*)screenName afterDelay:(float)delay{
    [self performSelector:@selector(showTutorialScreen:) withObject:screenName afterDelay:delay];
}

- (void)showTutorialScreen:(NSString*)screenName{
    if(![[CCDirector sharedDirector] isPaused]){
        CCScene* mainScene = [[CCDirector sharedDirector] runningScene];
        CCNode* tutorialLayer = (CCNode*)[CCBReader load:screenName];
        self.lastTutorialNode = tutorialLayer;
        [GameEvent dispatch:@"PauseMonsters" withArgument:nil];
        [mainScene addChild:tutorialLayer];
    }
}

@end
