//
//  Player.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Hand.h"
#import "FireHand.h"

@interface Player : CCNode

@property Hand *hand;
@property BOOL isMonsterHit;
@property BOOL isStopTimeReached;
@property BOOL isGoBack;


- (void)touchAtLocation:(CGPoint) touchLocation;
- (void)updateTouchLocation:(CGPoint) touchLocation;
- (void)releaseTouch;
- (void)addHandwithName:(NSString *)ccbName;
@end
