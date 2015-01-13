//
//  Player.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player{
    CCNode *_hand;
    CCNode *_body;
    CCNode *_mouseJointNode;
    CCNode *_centerJointNode;
    CCPhysicsJoint *_mouseJoint;
    CGPoint _shootDirection;
    BOOL isTouched;
    BOOL isReleased;
    CGPoint _initialPosition;
}

double vThreshold = 1e-1;
double fThreshold = 1e-1;

-(void)didLoadFromCCB{
    // nothing shall collide with static point
    _mouseJointNode.physicsBody.collisionMask = @[];
    _body.physicsBody.collisionMask = @[];
    _centerJointNode.physicsBody.collisionMask = @[];
    
    // set up initial parameters
    isTouched = NO;
    isReleased = NO;
    _initialPosition = _hand.position;
    
    // set up collision type
    _hand.physicsBody.collisionType = @"hand";
}

-(void)update:(CCTime)delta{
    
    if(isReleased){
        // make sure the hand moves only in the shoot directions
        double velocity = _hand.physicsBody.velocity.x * _shootDirection.x + _hand.physicsBody.velocity.y * _shootDirection.y;
        double deltaVx = velocity * _shootDirection.x - _hand.physicsBody.velocity.x;
        double deltaVy = velocity * _shootDirection.y - _hand.physicsBody.velocity.y;
        [_hand.physicsBody applyImpulse:ccp(deltaVx*_hand.physicsBody.mass,deltaVy*_hand.physicsBody.mass) atLocalPoint:ccp(8,8)];
        
        //reset the hand position after its velocity and force drops below vThreshold and fThreshold
        if(abs(_hand.physicsBody.velocity.x)<vThreshold & abs(_hand.physicsBody.force.x)<fThreshold & abs(_hand.physicsBody.velocity.y)<vThreshold & abs(_hand.physicsBody.force.y)<fThreshold){
            _hand.position = _initialPosition;
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
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_hand.physicsBody anchorA:ccp(0, 0) anchorB:ccp(8,8) restLength:0.f stiffness:3000.f damping:150.f];
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
        int impulseScale = 5;
        double deltaX = _centerJointNode.positionInPoints.x - _hand.positionInPoints.x;
        double deltaY = _centerJointNode.positionInPoints.y - _hand.positionInPoints.y;
        double distance = sqrt(deltaX*deltaX+deltaY*deltaY);
        _shootDirection.x = deltaX / distance;
        _shootDirection.y = deltaY / distance;
        [_hand.physicsBody applyImpulse:ccp(_shootDirection.x*distance*impulseScale,_shootDirection.y*distance*impulseScale) atLocalPoint:ccp(8,8)];
        
        if (_mouseJoint != nil){
            [_mouseJoint invalidate];
            _mouseJoint = nil;
        }
        
        isTouched = NO;
        isReleased = YES;
    }
}

@end
