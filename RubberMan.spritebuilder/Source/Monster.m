//
//  Monster.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Monster.h"

@implementation Monster{
    CGPoint _moveDirection;
}

- (void)didLoadFromCCB {
    _hp = 10;
    _atk = 5;
    _elementType = @"fire";
    _speed = 10;
    _isAttacking = NO;
    _atkPeriod = 2;
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

-(void)update:(CCTime)delta{
    
    // player position is (145,130). This may be not a good way to assign this value. need improvement.
    _moveDirection = ccpNormalize(ccpSub(ccp(145,130),self.positionInPoints));
    self.physicsBody.velocity = CGPointMake(self.speed * _moveDirection.x,self.speed * _moveDirection.y);
    
}

-(void)startAttack{
    _isAttacking = YES;
}


@end
