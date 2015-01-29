//
//  LevelSelectScene.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelSelectScene.h"
#import "BattleScene.h"
#import "GameGlobals.h"

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
    [[GameGlobals sharedInstance] setLevelNames:@[@"level1",@"level2",@"level3",@"level4"]];
    
    // obtain the information of the stars of each comleted level
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int numOfLevels = (int)[_level count];
    for (int i = 0;i<=numOfLevels-1;i++){
        // star = 1,2,3 for one, two and three stars and 0 for not complted levels
         int stars = [[defaults objectForKey:_levelNames[i]] intValue];
        // if the level is not completed, disable the select button
        if(stars == -1){
            if(i<numOfLevels-1){
//                [_level[i+1] setEnabled:NO];
            }
        } else if(stars>=1){
            [self fillStars:_level[i] NumOfStars:stars];
        }
    }
    

    
}

-(void) fillStars:(CCNode *)level NumOfStars:(int)stars{
    float positionX[3] = {16.7,28.3,39};
    for(int i=0;i<stars;i++){
        CCSprite *starSprite = [CCSprite spriteWithImageNamed:@"UI/level-select-star.png"];
        starSprite.position = ccp(positionX[i],19);
        [level addChild:starSprite];
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
    
    [BattleScene loadSceneByLevelIndex:levelNum];
}

- (void)backToTitle{
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
