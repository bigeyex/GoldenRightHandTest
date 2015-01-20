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
    CGPoint _attackPosition;
    double _attackTime;
    BOOL _isStopped;
    float _stopDuration;
}

- (void)didLoadFromCCB {
    _hp = 10;
    _atk = 5;
    _elementType = 1;
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
        return YES;
    }
    return NO;
}

- (void)stopMovingForDuration:(float)duration{
    _isStopped = YES;
    _stopDuration = duration;
}


- (void)loadMonsterData:(MonsterData *)monsterData{
    
}

-(void)update:(CCTime)delta{
    
    //_moveDirection = ccpNormalize(ccpSub(ccp(145,130),self.positionInPoints));
    _moveDirection = ccp(-1,0);
    self.physicsBody.velocity = CGPointMake((_isStopped?0:1)*self.speed * _moveDirection.x,(_isStopped?0:1)*self.speed * _moveDirection.y);
    
    if(_isAttacking){
        if(_attackTime<_atkPeriod){
            _attackTime = _attackTime + delta;
        }
        else{
            // ensure the monster goes back to the original attack position, prevent drifting
            self.position = _attackPosition;
            _isAttacking = NO;
        }
    }
    
    if(_isStopped){
        _stopDuration = _stopDuration - delta;
        if(_stopDuration<=0){
            _isStopped = NO;
        }
    }
}

-(void)startAttack{
    
    // back up the attack position
    _attackPosition = self.position;
    _isAttacking = YES;
    _attackTime = 0.0;
    
    // running attacking animations
    [self.animationManager runAnimationsForSequenceNamed:@"attacking"];
    
    // when the attacking animation is completed, runing the moving animations
    [self.animationManager setCompletedAnimationCallbackBlock:^(id sender){
        if ([self.animationManager.lastCompletedSequenceName isEqualToString:@"attacking"]) {
            [self.animationManager runAnimationsForSequenceNamed:@"moving"];
        }
    }];
}

@end
