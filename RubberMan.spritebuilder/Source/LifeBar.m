//
//  LifeBar.m
//  RubberMan
//
//  Created by Wang Yu on 1/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LifeBar.h"

float const FillWidth = 21.0;
float const FillHeight = 270.0;


@implementation LifeBar{
    
    CCProgressNode *_progressNode;
}

- (void) didLoadFromCCB{
    CCSprite *_lifeBarFill;
    _lifeBarFill = [CCSprite spriteWithImageNamed:@"UI/lifebar.png"];
    _lifeBarFill.position = ccp(0,0);
    _lifeBarFill.anchorPoint = ccp(0,0);
    _progressNode = [CCProgressNode progressWithSprite:_lifeBarFill];
    _progressNode.position = ccp(0,0);
    _progressNode.anchorPoint = ccp(0,0);
    _progressNode.type = CCProgressNodeTypeBar;
    _progressNode.midpoint = ccp(0,0);
    _progressNode.barChangeRate = ccp(1.0,0.0);
    [self addChild:_progressNode];
    [self setLength:100];
    
}

- (void)setLength: (float)length{
    CCActionProgressFromTo *fromToAction = [CCActionProgressFromTo actionWithDuration:0.5f from:_progressNode.percentage to:length];
    [_progressNode runAction:fromToAction];
}

@end
