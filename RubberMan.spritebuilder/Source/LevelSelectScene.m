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
    
    // obtain the information the stars of each comleted level
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int numOfLevels = 4;
    for (int i = 0;i<=numOfLevels-1;i++){
        // star = 1,2,3 for one, two and three stars and 0 for not complted levels
         int stars = [[defaults objectForKey:_levelNames[i]] intValue];
        // if the level is not completed, disable the select button
        if(stars == 0){
            if(i<numOfLevels-1){
                [_level[i+1] setEnabled:NO];
            }
        }
    }
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
