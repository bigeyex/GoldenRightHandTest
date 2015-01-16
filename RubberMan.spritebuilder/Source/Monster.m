//
//  Monster.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Monster.h"

@implementation Monster

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"monster";
}

- (void)loadMonsterData:(MonsterData *)monsterData{
    
}

@end
