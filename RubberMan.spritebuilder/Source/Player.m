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
    CCNode *_head;
    CCNode *_leftFoot;
    CCNode *_rightFoot;
    CCNode *_leftHand;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_handJoint;
    CCPhysicsJoint *_handRangeLimitJoint;
    BOOL isTouched;
    BOOL isReleased;
    BOOL isRangeReached;
    double _stopTime;
    CGPoint _initialPosition;
    CGPoint _shootDirection;
    CCSprite *_arrow;
}

static float playerScale = 0.4;
static float stopDuration = 0.3;

-(void)didLoadFromCCB{
    // nothing shall collide with static point
    _mouseJointNode.physicsBody.collisionMask = @[];
    _centerJointNode.physicsBody.collisionMask = @[];
    
    // set up collision type
    _body.physicsBody.collisionType = @"human";
    _leftFoot.physicsBody.collisionType = @"human";
    _rightFoot.physicsBody.collisionType = @"human";
    _leftHand.physicsBody.collisionType = @"human";
    _head.physicsBody.collisionType = @"human";

    // set up collision categories
    _body.physicsBody.collisionCategories = @[@"hand"];
    _head.physicsBody.collisionCategories = @[@"hand"];
    _leftHand.physicsBody.collisionCategories = @[@"hand"];
    _leftFoot.physicsBody.collisionCategories = @[@"hand"];
    _rightFoot.physicsBody.collisionCategories = @[@"hand"];
    
    // add hand into the scene
    [self addHandwithName:@"Hand"];

    
    // set up initial parameters
    _playerHP = 100.0;
    isTouched = NO;
    isReleased = NO;
    _initialPosition = _hand.position;
    
}

-(void)addHandwithName:(NSString *)ccbName{
    
    // create a hand from the ccb-file
    _hand = (Hand *)[CCBReader load:ccbName];
    _hand.position = ccp(-138,-49);
    
    // add the hand to the player
    [self addChild:_hand];
    
    // create a joint with the centerJointNode
    _handJoint=[CCPhysicsJoint connectedSpringJointWithBodyA:_hand.physicsBody bodyB:_centerJointNode.physicsBody anchorA:_hand.anchorPointInPoints anchorB:ccp(0,0) restLength:ccpDistance(_hand.positionInPoints,_centerJointNode.positionInPoints)*playerScale stiffness:4.f damping:1.f];
    
    // create a distance joint to control the range of the hand
    _handRangeLimitJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA:_hand.physicsBody bodyB:_centerJointNode.physicsBody anchorA:_hand.anchorPointInPoints anchorB:ccp(0,0) minDistance:0.f maxDistance:_hand.range*playerScale];
    
}

-(void)update:(CCTime)delta{
    
    if(isReleased){
        // make sure the hand moves only in the shoot directions
        double velocity = ccpDot(_hand.physicsBody.velocity,_shootDirection);
        _hand.physicsBody.velocity = CGPointMake(velocity * _shootDirection.x,velocity * _shootDirection.y);
        
        // check whether the hand has reached its range
        CGPoint handRelativeVector = ccpSub(_hand.positionInPoints, _centerJointNode.positionInPoints);
        double handDist = ccpDot(handRelativeVector,_shootDirection);
        if((handDist>=_hand.range)&& (!isRangeReached)){
            isRangeReached = YES;
            _isStopTimeReached = NO;
        }
        
        if(isRangeReached||_isMonsterHit){
            if(!_isStopTimeReached){
                
                // set the velocity to zero for stopDuration
                _hand.physicsBody.velocity=ccp(0,0);
                if(isRangeReached){
                    _hand.position = ccpAdd(ccp(_hand.range*_shootDirection.x,_hand.range*_shootDirection.y),_centerJointNode.position);
                }
                
                // after the hand hits the monster, fix the hand's position during its stop time
                if(_isMonsterHit){
                    _hand.position = ccpSub(_handPositionAtHit,ccpMult(_shootDirection,0.f));
                }
                
                // load hand particle effect
                //[_hand handParticleEffectAtPosition:_hand.anchorPointInPoints];
                
                // after the hand has stopped for enough time, apply an impluse to let the hand go back
                if(_stopTime>=stopDuration){
                    double impulseScale = _hand.physicsBody.mass*1000;
                    
                    // change the shoot direction to the vector of _initialPosition to hand.position
                    
                    _shootDirection = ccpNormalize(ccpSub(_hand.positionInPoints,_initialPosition));
                    
                    [_hand.physicsBody applyImpulse:ccp(-_shootDirection.x*impulseScale,-_shootDirection.y*impulseScale) atLocalPoint:_hand.anchorPointInPoints];
                    
                    isRangeReached = NO;
                    _isStopTimeReached = YES;
                    _isMonsterHit = NO;
                    _isGoBack = YES;
                    
                    
                    // when hand is going back, it will not collide with any object
                    _hand.physicsBody.collisionMask = @[];
                }
                
                _stopTime = _stopTime + delta;
            }
        }
        
        // check whether the hand has been back to the origin;
        if((handDist<=ccpDot(_initialPosition,_shootDirection))&&_isGoBack){
            _hand.physicsBody.velocity=ccp(0,0);
            _hand.position = _initialPosition;
            isReleased = NO;
        }
    }
    
     
}

- (void)touchAtLocation:(CGPoint) touchLocation {
    
    // connect the hand touched by the user to a mouse joint at the touchLocation, when the hand is in the status of being released, the touch is invalid
    if ((!isReleased) && CGRectContainsPoint([_hand boundingBox], touchLocation))
    {
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        _hand.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the hand
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_hand.physicsBody anchorA:ccp(0, 0) anchorB:_hand.anchorPointInPoints restLength:0.f stiffness:3000.f damping:150.f];
        isTouched = YES;
        isReleased = NO;
        
        // add an arrow to indicate the direction
        _arrow = (CCSprite *)[CCBReader load:@"Arrow"];
        _arrow.scaleX = 0.5;
        _arrow.scaleY = 0.8;
        _arrow.position = _centerJointNode.positionInPoints;
        
        _shootDirection = ccpNormalize(ccpSub(_centerJointNode.positionInPoints,_hand.positionInPoints));
        _arrow.rotation = ccpAngleSigned(_shootDirection, ccp(0,0)) / M_PI * 180;
        [self addChild:_arrow];
    }
}

- (void)updateTouchLocation:(CGPoint) touchLocation {
    // update the position of mouse joint with touchLocation
    if (isTouched){
        _mouseJointNode.position = touchLocation;
        _hand.position = touchLocation;
        
        // update the arrow's angle
        _shootDirection = ccpNormalize(ccpSub(_centerJointNode.positionInPoints,_hand.positionInPoints));
        _arrow.rotation = ccpAngleSigned(_shootDirection, ccp(0,1)) / M_PI * 180;
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
        _isGoBack = NO;
        _stopTime = 0;
        
        // after the hand is released, hand can collide with monsters
        _hand.physicsBody.collisionMask = @[@"monster"];
        
        // remove the arrow
        [_arrow removeFromParent];
    }
}

@end
