//
//  TutorialManager.m
//  RubberMan
//
//  Created by Wang Yu on 1/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TutorialManager.h"
#import "BasicTutorial.h"
#import "SpecialSkillTutorial.h"
#import "BombSausageTutorial.h"
#import "EliteTutorial.h"
#import "LevelLoader.h"
#import "GetManaTutorial.h"
#import "SkillButtonTutorial.h"

@implementation TutorialManager

+ (void)createTutorial:(NSString*)tutorialName withMonsterList:(LevelLoader*)monsterList{
    
    if([tutorialName isEqualToString:@"BasicTutorial"]){
        [BasicTutorial setUpWithLevelLoader:monsterList];
    }
    else if([tutorialName isEqualToString:@"SpecialSkillTutorial"]){
        [SpecialSkillTutorial setUpWithLevelLoader:monsterList];
    }
    else if([tutorialName isEqualToString:@"BombSausageTutorial"]){
        [BombSausageTutorial setUpWithLevelLoader:monsterList];
    }
    else if([tutorialName isEqualToString:@"EliteTutorial"]){
        [EliteTutorial setUpWithLevelLoader:monsterList];
    }
    else if([tutorialName isEqualToString:@"GetManaTutorial"]){
        [GetManaTutorial setUpWithLevelLoader:monsterList];
    }
    else if([tutorialName isEqualToString:@"SkillButtonTutorial"]){
        [SkillButtonTutorial setUpWithLevelLoader:monsterList];
    }
}

@end
