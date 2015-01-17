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
    double _attackTime;
}

- (void)didLoadFromCCB {
    _hp = 10;
    _atk = 5;
    _elementType = 0;
    _speed = 30;
    _isAttacking = NO;
    _atkPeriod = 2.0;
    self.physicsBody.collisionType = @"monster";
    self.physicsBody.collisionMask = @[@"human",@"hand"];
    self.physicsBody.collisionCategories = @[@"monster"];
}


- (BOOL)receiveHitWithDamage:(float)damage{
    _hp = _hp - damage;
    if(_hp<=0){
        [self removeFromParent];
        return YES;
    }
    return NO;
}


- (void)loadMonsterData:(MonsterData *)monsterData{
    
}

-(void)update:(CCTime)delta{
    
    // player position is (145,130). This may be not a good way to assign this value. need improvement.
    //_moveDirection = ccpNormalize(ccpSub(ccp(145,130),self.positionInPoints));
    _moveDirection = ccp(-1,0);
    self.physicsBody.velocity = CGPointMake(self.speed * _moveDirection.x,self.speed * _moveDirection.y);
    
    if(_isAttacking){
        if(_attackTime<_atkPeriod){
            _attackTime = _attackTime + delta;
        }
        else{
            _isAttacking = NO;
        }
    }
    
}

-(void)startAttack{
    _isAttacking = YES;
    _attackTime = 0.0;
}


@end
