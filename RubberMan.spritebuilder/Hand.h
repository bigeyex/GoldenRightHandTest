//
//  Hand.h
//  RubberMan
//
//  Created by Wang Yu on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Hand : CCSprite

@property (nonatomic, assign) CCNode *handFreeNode;
@property (nonatomic, assign) CCNode *mouseJointNode;

@end
