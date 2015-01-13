//
//  HandBody.m
//  RubberMan
//
//  Created by Wang Yu on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hand.h"
#import "HandBody.h"

@implementation HandBody{
    CCNode *_handFreeNode;
    Hand *_handParent;
    CCPhysicsJoint *_mouseJoint;
    BOOL _isInTouch;
    CGPoint savedTouchLocation;
}

- (void)onEnter{
    self.userInteractionEnabled = true;
    _handParent = (Hand*)self.parent;
    _handFreeNode = _handParent.handFreeNode;
    [super onEnter];
}

- (void)update:(CCTime)delta{
    if(_isInTouch){
        _handFreeNode.position = savedTouchLocation;
    }
    
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    CGPoint touchLocation = [touch locationInNode:_handParent];
    savedTouchLocation = touchLocation;
    
    if(CGRectContainsPoint([self boundingBox], touchLocation)){
        CCLOG(@"InBound");
        _handFreeNode.position = touchLocation;
//        _handParent.mouseJointNode.position = touchLocation;
//        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_handParent.mouseJointNode.physicsBody bodyB:_handParent.handFreeNode.physicsBody anchorA:ccp(0,0) anchorB:ccp(50,50) restLength:0.f stiffness:3000 damping:150.f];
        _isInTouch = YES;
    }
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    if(_isInTouch){
        CGPoint touchLocation = [touch locationInNode:_handParent];
        savedTouchLocation = touchLocation;
        _handFreeNode.position = touchLocation;
//        _handParent.mouseJointNode.position = touchLocation;
    }
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    _isInTouch = NO;
}

@end
