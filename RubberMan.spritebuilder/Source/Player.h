//
//  Player.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Hand.h"

@interface Player : CCNode

@property Hand *hand;
@property BOOL isMonsterHit;
@property BOOL isStopTimeReached;
@property BOOL isGoBack;
@property BOOL isReleased;
@property BOOL isTouched;
@property float playerHP;
@property CCNode *centerJointNode;
@property CGPoint handPositionAtHit;
@property CGPoint shootDirection;
@property float atkBuff;
@property float damageReduction;
@property BOOL isShooting;

- (void)reduceHandMomentumBy:(float)factor;
- (BOOL)touchAtLocation:(CGPoint) touchLocation;
- (void)updateTouchLocation:(CGPoint) touchLocation;
- (BOOL)releaseTouch;
- (void)addHandwithName:(NSString *)ccbName;
- (void)removeHand;
- (void)receiveAttack;
- (void)doubleAttackForDuration:(float)duration;
- (void)immuneFromAttackForDuration:(float)duration;
- (void)shootingForDuration:(float)duration;
- (void)heal:(float)recoverHP;

@end
