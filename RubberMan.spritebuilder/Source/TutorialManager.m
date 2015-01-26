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

@implementation TutorialManager

+ (void)createTutorial:(NSString*)tutorialName{
    
    if([tutorialName isEqualToString:@"BasicTutorial"]){
        [BasicTutorial setUp];
    }
    else if([tutorialName isEqualToString:@"SpecialSkillTutorial"]){
        [SpecialSkillTutorial setUp];
    }
}

@end