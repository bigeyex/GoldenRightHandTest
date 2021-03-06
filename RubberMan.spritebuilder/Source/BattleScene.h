//
//  BattleScene.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "SkillButtonUI.h"

@interface BattleScene : CCNode <CCPhysicsCollisionDelegate>

@property NSString *levelName;
@property int levelIndex;
@property CCNode* nextLevelButton;
@property BOOL endlessMode;


+ (void)loadSceneByLevelIndex:(int)levelIndex;
- (SkillButtonUI*)skillButton;

@end
