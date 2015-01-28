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
    [self removeChildByName:@"upper"];
    
    _lowerLeftElement = @"none";
    [self removeChildByName:@"lowerLeft"];

    _lowerRightElement =@"none";
    [self removeChildByName:@"lowerRight"];
}

-(void)setUpperElement:(NSString *)newString{
    _upperElement = newString;
    if(![newString isEqualToString:@"none"]){
        CCNode* childToBeRemoved = [self getChildByName:@"upper" recursively:NO];
        if(childToBeRemoved != nil){
            [self removeChild:childToBeRemoved];
        }
        id sequence = [CCActionSequence actions:[CCActionDelay actionWithDuration:0.5],[CCActionCallBlock actionWithBlock:^{
                if(![_upperElement isEqualToString:@"none"]){
                    [self addChild:[self addElementToUI:_upperElement Position:ccp(-50,70)] z:1 name:@"upper"];
                }
            }],nil];
        [self runAction:sequence];
    }
}

-(void)setLowerLeftElement:(NSString *)newString{
    _lowerLeftElement = newString;
    if(![newString isEqualToString:@"none"]){
        CCNode* childToBeRemoved = [self getChildByName:@"lowerLeft" recursively:NO];
        if(childToBeRemoved != nil){
            [self removeChild:childToBeRemoved];
        }
        CCSprite *newElement =[self addElementToUI:_lowerLeftElement Position:ccp(-50,70)];
        [self addChild:newElement z:2 name:@"lowerLeft"];
        id elementMotion = [CCActionMoveTo actionWithDuration:0.5 position:ccp(-66,40)];
        [newElement runAction:elementMotion];
    }
}

-(void)setLowerRightElement:(NSString *)newString{
    _lowerRightElement = newString;
    if(![newString isEqualToString:@"none"]){
        CCNode* childToBeRemoved = [self getChildByName:@"lowerRight" recursively:NO];
        if(childToBeRemoved != nil){
            [self removeChild:childToBeRemoved];
        }
        CCSprite *newElement =[self addElementToUI:_lowerLeftElement Position:ccp(-66,40)];
        [self addChild:newElement z:3 name:@"lowerRight"];
        id elementMotion = [CCActionMoveTo actionWithDuration:0.5 position:ccp(-33,40)];
        [newElement runAction:elementMotion];
    }
}


@end
