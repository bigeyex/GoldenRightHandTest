//
//  Player.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"
#import "Hand.h"

@implementation Player{
    Hand *_hand;
    CCNode *_body;
    CCNode *_mouseJointNode;
    CCNode *_centerJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCPhysicsJoint *_handJoint;
    CGPoint _shootDirection;
    BOOL isTouched;
    BOOL isReleased;
    CGPoint _initialPosition;
}

double vThreshold = 1;
double fThreshold = 1;

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
    _hand.range = 50.0;
    
    // set up collision type
    _hand.physicsBody.collisionType = @"hand";
    
    // create a joint with the centerJointNode
    _handJoint=[CCPhysicsJoint connectedSpringJointWithBodyA:_hand.physicsBody bodyB:_centerJointNode.physicsBody anchorA:ccp(_hand.contentSizeInPoints.width/2,_hand.contentSizeInPoints.height/2) anchorB:ccp(0,0) restLength:80.f stiffness:4.f damping:1.f];
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
        [_hand.physicsBody applyImpulse:ccp(deltaVx*_hand.physicsBody.mass,deltaVy*_hand.physicsBody.mass) atLocalPoint:ccp(_hand.contentSizeInPoints.width/2,_hand.contentSizeInPoints.height/2)];
        
        //reset the hand position after its velocity and force drops below vThreshold and fThreshold
        if(fabs(_hand.physicsBody.velocity.x)<vThreshold & fabs(_hand.physicsBody.force.x)<fThreshold & fabs(_hand.physicsBody.velocity.y)<vThreshold & fabs(_hand.physicsBody.force.y)<fThreshold){
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
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_hand.physicsBody anchorA:ccp(0, 0) anchorB:ccp(_hand.contentSizeInPoints.width/2,_hand.contentSizeInPoints.height/2) restLength:0.f stiffness:3000.f damping:150.f];
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
        [_hand.physicsBody applyImpulse:ccp(_shootDirection.x*distance*impulseScale,_shootDirection.y*distance*impulseScale) atLocalPoint:ccp(_hand.contentSizeInPoints.width/2,_hand.contentSizeInPoints.height/2)];
        
        if (_mouseJoint != nil){
            [_mouseJoint invalidate];
            _mouseJoint = nil;
        }
        
        isTouched = NO;
        isReleased = YES;
    }
}

@end
