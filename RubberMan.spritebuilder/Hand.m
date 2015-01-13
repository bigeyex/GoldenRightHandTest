//
//  Hand.m
//  RubberMan
//
//  Created by Wang Yu on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hand.h"

@implementation Hand{
    CCNode *_handBody;
    CCNode *_handJointNode;
    BOOL _isInTouch;
}

- (void)didLoadFromCCB{
    _isInTouch = NO;
}

- (void)update:(CCTime)delta{
    // set scale y of hand_body
    float distance = ccpDistance(_handJointNode.position, self.handFreeNode.position);
    _handBody.scaleY = distance/35;
    _handBody.rotation = -CC_RADIANS_TO_DEGREES(ccpAngleSigned(_handJointNode.position, self.handFreeNode.position))-160;
}



@end
