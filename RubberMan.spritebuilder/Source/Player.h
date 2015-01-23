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
@property NSMutableArray *mana;
@property int skillcost;
@property CGPoint shootDirection;

- (void)touchAtLocation:(CGPoint) touchLocation;
- (void)updateTouchLocation:(CGPoint) touchLocation;
- (BOOL)releaseTouch;
- (void)addHandwithName:(NSString *)ccbName;
- (void)removeHand;
- (void)receiveAttack;

@end
