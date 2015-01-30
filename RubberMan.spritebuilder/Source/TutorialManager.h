//
//  TutorialManager.h
//  RubberMan
//
//  Created by Wang Yu on 1/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelLoader.h"

@interface TutorialManager : NSObject

+ (void)createTutorial:(NSString*)tutorialName withMonsterList:(LevelLoader*)monsterList;

@end
