//
//  LoseScene.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LoseScene.h"

@implementation LoseScene

-(void)back{
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene];
}

@end
