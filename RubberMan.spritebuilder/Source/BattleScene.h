//
//  BattleScene.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface BattleScene : CCNode <CCPhysicsCollisionDelegate>

@property NSString *levelName;
@property int levelIndex;
@property CCNode* nextLevelButton;


+ (void)loadSceneByLevelIndex:(int)levelIndex;

@end
