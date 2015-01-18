//
//  LevelSelectScene.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelSelectScene.h"
#import "BattleScene.h"

@implementation LevelSelectScene{
    CCButton *_level1;
    CCButton *_level2;
    CCButton *_level3;
    CCButton *_level4;
    NSMutableArray *_level;
    NSMutableArray *_levelNames;
}

- (void)didLoadFromCCB {
    _level = [NSMutableArray arrayWithObjects:_level1,_level2,_level3,_level4,nil];
    _levelNames = [NSMutableArray arrayWithObjects:@"level1",@"level2",@"level3",@"level4",nil];
}

-(void) startLevel{
    int levelNum = 0;
    if(_level1.highlighted){
        levelNum = 0;
    } else if(_level2.highlighted){
        levelNum = 1;
    } else if(_level3.highlighted){
        levelNum = 2;
    } else if(_level4.highlighted){
        levelNum = 3;
    }
    CCScene *battleScene = [CCBReader loadAsScene:@"BattleScene"];
    BattleScene *sceneNode = [[battleScene children] firstObject];
    sceneNode.levelName = _levelNames[levelNum];
    [[CCDirector sharedDirector] replaceScene:battleScene];
}

@end
