//
//  Monster.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Monster.h"
#import "GameEvent.h"

CGFloat const outOfBoundThreshold=10;

@implementation Monster{
    CGPoint _moveDirection;
    CGPoint _attackPosition;
    double _attackTime;
    float _stopDuration;
    
    CGPoint _pausedVelocity;
    
    CCNode* _hpBar;
    float _initialHp;
}

- (void)didLoadFromCCB {
    _atk = 5;
    _isAttacking = NO;
    _atkPeriod = 2.0;
    _isEvading = NO;
    _spdBuff = 1.0;
    self.physicsBody.collisionType = @"monster";
    self.physicsBody.collisionMask = @[@"human",@"hand"];
    self.physicsBody.collisionCategories = @[@"monster"];
    
    [GameEvent subscribe:@"PauseMonsters" forObject:self withSelector:@selector(pauseMonster)];
    [GameEvent subscribe:@"ResumeMonsters" forObject:self withSelector:@selector(resumeMonster)];
}

- (void)setIsElite:(BOOL)isElite{
    _isElite = isElite;
    self.rankIcon.visible = isElite;
}

-(void)onEnter{
    [super onEnter];
    _initialHp = _hp;
}

- (void)pauseMonster{
    _pausedVelocity = self.physicsBody.velocity;
    self.physicsBody.velocity = ccp(0,0);
}

- (void)resumeMonster{
    self.physicsBody.velocity = _pausedVelocity;
}



- (BOOL)receiveHitWithDamage:(float)damage{
    _hp = _hp - damage;
    if(_hp<=0){
        return YES;
    }
    _hpBar.scaleX = _hp/_initialHp;
    return NO;
}

- (void)stopMovingForDuration:(float)duration{
    _isStopped = YES;
    _stopDuration = duration;
    [self.animationManager runAnimationsForSequenceNamed:@"default"];
}


- (void)loadMonsterData:(MonsterData *)monsterData{
    
}

-(void)update:(CCTime)delta{
    
    if(!_isEvading){
        //_moveDirection = ccpNormalize(ccpSub(ccp(145,130),self.positionInPoints));
        _moveDirection = ccp(-1,0);
        self.physicsBody.velocity = CGPointMake((_isStopped?0:1)*self.speed*_spdBuff * _moveDirection.x,(_isStopped?0:1)*self.speed*_spdBuff * _moveDirection.y);
    }
    
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
            [self.animationManager runAnimationsForSequenceNamed:@"moving"];
        }
    }
    
    CGRect ub = self.boundingBox;
    CGRect pb = self.parent.boundingBox;
    if(ub.origin.x+ub.size.width+outOfBoundThreshold < pb.origin.x ||
       ub.origin.y+ub.size.height+outOfBoundThreshold < pb.origin.y ||
       //ub.origin.x > pb.origin.x+pb.size.width+outOfBoundThreshold ||
       ub.origin.y > pb.origin.y+pb.size.height+outOfBoundThreshold){
        [self removeFromParent];
        [GameEvent dispatch:@"MonsterRemoved" withArgument:nil];
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

- (void)monsterEvade{
    
}

- (void)monsterCharge{
    
}

- (void)monsterChargeCancel{
    
}

- (void)protectMonsters:(Monster *)nodeA{
    
}

- (void)seekProtection:(CCNode *)monsterList{
    int numOfMonsters = (int)[monsterList.children count];
    for (int i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = monsterList.children[i];
        if(_checkNode.isElite){
            if(self!=_checkNode && !_checkNode.isEvading){
                [_checkNode protectMonsters:self];
                self.physicsBody.velocity = ccp(0,0);
                break;
            }
        }
    }
    
    
}

@end

@implementation MonsterWalker

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    self.speed = 30;
    self.elementType = @"ice";
}

/*
 -(void)monsterEvade{
 if(!self.isStopped){
 self.isEvading = YES;
 self.physicsBody.velocity = ccp(0,0);
 CGPoint previousPosition = self.position;
 id jumpSequence = [CCActionSequence actions: [CCActionMoveBy actionWithDuration:0.1 position:ccp(0,0.25)], [CCActionDelay actionWithDuration:0.5],[CCActionMoveTo actionWithDuration:0.1 position:previousPosition],[CCActionCallBlock actionWithBlock:^{
 self.isEvading = NO;}],nil];
 [self runAction:jumpSequence];
 }
 }
 */

- (void)protectMonsters:(Monster *)nodeA{
    if(!self.isStopped){
        CGPoint previousPosition = self.position;
        CGPoint nodeAPosition = nodeA.position;
        self.isEvading = YES;
        self.physicsBody.velocity = ccp(0,0);
        id evadeSequence = [CCActionSequence actions: [CCActionMoveBy actionWithDuration:0.1 position:ccp(0.1,0)], [CCActionDelay actionWithDuration:1],[CCActionMoveTo actionWithDuration:0.1 position:nodeAPosition],[CCActionCallBlock actionWithBlock:^{nodeA.isEvading = NO;}],nil];
        [nodeA runAction:evadeSequence];
        
        id protectSequence = [CCActionSequence actions: [CCActionMoveTo actionWithDuration:0.1 position:nodeAPosition], [CCActionDelay actionWithDuration:1],[CCActionMoveTo actionWithDuration:0.1 position:previousPosition],[CCActionCallBlock actionWithBlock:^{self.isEvading = NO;}],nil];
        [self runAction:protectSequence];
    }
}

@end

@implementation MonsterBat

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    self.speed = 40;
    self.elementType = @"fire";
}

-(void)monsterEvade{
    if(!self.isStopped && !self.isEvading){
        self.isEvading = YES;
        self.physicsBody.velocity = ccp(0,0);
        CGPoint previousPosition = self.position;
        id evadeSequence = [CCActionSequence actions: [CCActionMoveBy actionWithDuration:0.1 position:ccp(0.25,0)], [CCActionDelay actionWithDuration:0.5],[CCActionMoveTo actionWithDuration:0.1 position:previousPosition],[CCActionCallBlock actionWithBlock:^{
            self.isEvading = NO;}],nil];
        [self runAction:evadeSequence];
    }
}

@end

@implementation MonsterGhost

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    self.speed = 50;
    self.elementType = @"dark";
}

-(void)monsterCharge{
    if(self.isElite){
        self.spdBuff = 5.0;
    }
}

- (void)monsterChargeCancel{
    if(self.isElite){
        self.spdBuff = 1.0;
    }
}

@end

@implementation MonsterSausage

- (BOOL)receiveHitWithDamage:(float)damage{
    [GameEvent dispatch:@"FoundSausage"];
    return YES;
}

-(void)didLoadFromCCB{
    [super didLoadFromCCB];
    self.speed = 50;
    self.elementType = @"dark";
}

-(void)onEnter{
    [super onEnter];
    self.isEvading = true;  // this is a hack - to delegate movement to the physic engine
    [self.physicsBody applyImpulse:ccp(50,300)];
    [self.physicsBody applyAngularImpulse:300.0];
}



@end
