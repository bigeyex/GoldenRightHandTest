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
    _hp = 10;
    _atk = 5;
    _elementType = @"fire";
    self.physicsBody.collisionType = @"monster";
}


- (int)receiveHitWithHand:(Hand *)hand{
    _hp = _hp - hand.atk;
    if(_hp<=0){
        [self removeFromParent];
        return 1;
    }
    return 0;
}


- (void)loadMonsterData:(MonsterData *)monsterData{
    
}

@end
