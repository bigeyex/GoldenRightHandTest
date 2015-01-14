//
//  Player.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player{
    CCNode *_body;
    CCNode *_mouseJointNode;
    CCNode *_centerJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_handJoint;
    CCPhysicsJoint *_handRangeLimitJoint;
    CGPoint _shootDirection;
    BOOL isTouched;
    BOOL isReleased;
    BOOL isRangeReached;
    BOOL isStopTimeReached;
    BOOL isGoBack;
    double _stopTime;
    CGPoint _initialPosition;
}

static float playerScale = 0.4;
static float stopDuration = 0.3;

-(void)didLoadFromCCB{
    // nothing shall collide with static point
    _mouseJointNode.physicsBody.collisionMask = @[];
    _body.physicsBody.collisionMask = @[];
    _centerJointNode.physicsBody.collisionMask = @[];

    // create a hand from the ccb-file
    _hand = (Hand *)[CCBReader load:@"Hand"];
    _hand.position = ccp(-138,-49);
    
    // add the hand to the player
    [self addChild:_hand];
    
    // set up the hand type
    _hand.handType = @"normal";
    _hand.range = 500.0f;
    
    // create a joint with the centerJointNode
    _handJoint=[CCPhysicsJoint connectedSpringJointWithBodyA:_hand.physicsBody bodyB:_centerJointNode.physicsBody anchorA:_hand.anchorPointInPoints anchorB:ccp(0,0) restLength:ccpDistance(_hand.positionInPoints,_centerJointNode.positionInPoints)*playerScale stiffness:4.f damping:1.f];
    
    _handRangeLimitJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA:_hand.physicsBody bodyB:_centerJointNode.physicsBody anchorA:_hand.anchorPointInPoints anchorB:ccp(0,0) minDistance:0.f maxDistance:_hand.range*playerScale];
    // set up initial parameters
    isTouched = NO;
    isReleased = NO;
    _initialPosition = _hand.position;
    
}

-(void)update:(CCTime)delta{
    
    if(isReleased){
        // make sure the hand moves only in the shoot directions
        double velocity = ccpDot(_hand.physicsBody.velocity,_shootDirection);
        _hand.physicsBody.velocity = CGPointMake(velocity * _shootDirection.x,velocity * _shootDirection.y);
        
        // check the status of the hand
        CGPoint handRelativeVector = ccpSub(_hand.positionInPoints, _centerJointNode.positionInPoints);
        double handDist = ccpDot(handRelativeVector,_shootDirection);
        
        // check whether the hand has reached its range
        if((handDist>=_hand.range)&& ~isRangeReached){
            isRangeReached = YES;
            isStopTimeReached = NO;
        }
        
        // check whether the hand has been back to the origin;
        if((handDist<=ccpDot(_initialPosition,_shootDirection))&&isGoBack){
            _hand.physicsBody.velocity=ccp(0,0);
            _hand.position = _initialPosition;
            isReleased = NO;
        }
        
        // set the velocity to zero for stopDuration
        if(isRangeReached){
            if(~isStopTimeReached){
                
                _hand.physicsBody.velocity=ccp(0,0);
                _hand.position = ccpAdd(ccp(_hand.range*_shootDirection.x,_hand.range*_shootDirection.y),_centerJointNode.position);
                _stopTime = _stopTime + delta;
                
                // load particle effect
                CCParticleSystem *fistHitEffect = (CCParticleSystem *)[CCBReader load:@"FistHitEffect"];
                fistHitEffect.autoRemoveOnFinish = TRUE;
                fistHitEffect.position = _hand.position;
                [_hand.parent addChild:fistHitEffect];
                
                if(_stopTime>=stopDuration){
                    double impulseScale = _hand.physicsBody.mass*1000;
                    [_hand.physicsBody applyImpulse:ccp(-_shootDirection.x*impulseScale,-_shootDirection.y*impulseScale) atLocalPoint:_hand.anchorPointInPoints];
                    isRangeReached = NO;
                    isStopTimeReached = YES;
                    isGoBack = YES;
                }
            }
        }
    }
    
     
}

- (void)touchAtLocation:(CGPoint) touchLocation {
    // connect the hand touched by the user to a mouse joint at the touchLocation
    if (CGRectContainsPoint([_hand boundingBox], touchLocation))
    {
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        _hand.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the hand
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_hand.physicsBody anchorA:ccp(0, 0) anchorB:_hand.anchorPointInPoints restLength:0.f stiffness:3000.f damping:150.f];
        isTouched = YES;
        isReleased = NO;
    }
}

- (void)updateTouchLocation:(CGPoint) touchLocation {
    // update the position of mouse joint with touchLocation
    if (isTouched){
    _mouseJointNode.position = touchLocation;
    _hand.position = touchLocation;
    }
}

- (void)releaseTouch{
    
    if (isTouched){
        
        // add an impulse to the hand when the touch is released
        double impulseScale = _hand.physicsBody.mass*10;
        double distance = ccpDistance(_centerJointNode.positionInPoints,_hand.positionInPoints);
        _shootDirection = ccpNormalize(ccpSub(_centerJointNode.positionInPoints,_hand.positionInPoints));
        [_hand.physicsBody applyImpulse:ccp(_shootDirection.x*distance*impulseScale,_shootDirection.y*distance*impulseScale) atLocalPoint:_hand.anchorPointInPoints];
        
        if (_mouseJoint != nil){
            [_mouseJoint invalidate];
            _mouseJoint = nil;
        }
        
        isTouched = NO;
        isReleased = YES;
        isGoBack = NO;
        _stopTime = 0;
    }
}

@end
