//
//  LevelLoader.h
//  RubberMan
//
//  Created by Wang Yu on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface LevelLoader : CCNode

- (int)loadLevel:(NSString*)levelName;
- (BOOL)hasMoreMonsters;

@end
