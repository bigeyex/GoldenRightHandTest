//
//  SkillButton.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SkillButtonUI.h"

@implementation SkillButtonUI

-(void)didLoadFromCCB{
    _upperElement = @"none";
    _lowerLeftElement = @"none";
    _lowerRightElement = @"none";
}

-(CCSprite *)addElementToUI:(NSString *)elementName Position:(CGPoint)position{
    CCSprite *skillElement = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"UI/%@.png",elementName]];
    skillElement.position = position;
    return skillElement;
}

-(void) resetElement{
    _upperElement = @"none";
    _lowerLeftElement = @"none";
    _lowerRightElement =@"none";
}

-(void)setUpperElement:(NSString *)newString{
    _upperElement = newString;
    if(![newString isEqualToString:@"none"]){
        [self removeChildByName:@"upper"];
        [self addChild:[self addElementToUI:_upperElement Position:ccp(-50,70)] z:1 name:@"upper"];
    }
}

-(void)setLowerLeftElement:(NSString *)newString{
    _lowerLeftElement = newString;
    if(![newString isEqualToString:@"none"]){
        [self removeChildByName:@"lowerLeft"];
        [self addChild:[self addElementToUI:_lowerLeftElement Position:ccp(-66,40)] z:2 name:@"lowerLeft"];
    }
}

-(void)setLowerRightElement:(NSString *)newString{
    _lowerRightElement = newString;
    if(![newString isEqualToString:@"none"]){
        [self removeChildByName:@"lowerRight"];
        [self addChild:[self addElementToUI:_lowerRightElement Position:ccp(-33,40)] z:3 name:@"lowerRight"];
    }
}


@end
