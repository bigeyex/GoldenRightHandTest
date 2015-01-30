//
//  BasicTutorial.h
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelLoader.h"

@interface Tutorial : NSObject

@property LevelLoader* monsterList;
@property CCNode* lastTutorialNode;

+ (void)setUpWithLevelLoader:(LevelLoader*)levelLoader;
- (void)showTutorialScreen:(NSString*)screenName afterDelay:(float)delay;
- (void)setup;

@end
