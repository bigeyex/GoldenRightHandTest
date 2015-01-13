//
//  Player.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Player : CCNode

- (void)touchAtLocation:(CGPoint) touchLocation;
- (void)updateTouchLocation:(CGPoint) touchLocation;
- (void)releaseTouch;

@end
