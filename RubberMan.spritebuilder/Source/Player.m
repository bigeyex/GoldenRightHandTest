//
//  Player.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Player.h"
#import "GameEvent.h"

@implementation Player{
    CCNode *_body;
    CCNode *_head;
    CCNode *_leftFoot;
    CCNode *_rightFoot;
    CCNode *_leftHand;
    CCPhysicsJoint *_handRangeLimitJoint;
    BOOL isRangeReached;
    double _stopTime;
    CGPoint _initialPosition;
    CCSprite *_arrow;
    float _minTouchTime;
    BOOL _isMoved;
    
    CCNode* _hpBar;
}

static float playerScale = 0.4;
static float stopDuration = 0.3;
static float controlRange = 300;

-(void)didLoadFromCCB{
    // nothing shall collide with static point
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
    _isTouched = NO;
    _isReleased = NO;
    _isMoved = NO;
    _initialPosition = _hand.position;
    _atkBuff = 1.0;
    _damageReduction = 1.0;
    _isShooting = NO;
}

-(void)addHandwithName:(NSString *)ccbName{
    
    // create a hand from the ccb-file
    _hand = (Hand *)[CCBReader load:ccbName];
    _hand.position = ccp(-138,-49);
    
    // add the hand to the player
    [self addChild:_hand];
    
    // create a distance joint to control the range of the hand
    _handRangeLimitJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA:_hand.physicsBody bodyB:_centerJointNode.physicsBody anchorA:_hand.anchorPointInPoints anchorB:ccp(0,0) minDistance:0.f maxDistance:_hand.range*playerScale];
}

-(void)removeHand{
    [_hand removeFromParent];
    
    if (_handRangeLimitJoint != nil){
        [_handRangeLimitJoint invalidate];
        _handRangeLimitJoint = nil;
    }
    _isReleased = 0;
}

-(void)update:(CCTime)delta{
    
    if(_isReleased){
        
        // make sure the hand moves only in the shoot directions
        double velocity = ccpDot(_hand.physicsBody.velocity,_shootDirection);
        _hand.physicsBody.velocity = CGPointMake(velocity * _shootDirection.x,velocity * _shootDirection.y);
        
        // check whether the hand has reached its range
        CGPoint handRelativeVector = ccpSub(_hand.positionInPoints, _centerJointNode.positionInPoints);
        double handDist = ccpDot(handRelativeVector,_shootDirection);
        if((!isRangeReached)&&(handDist>=(_hand.range-5.0))){
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
                else if(_isMonsterHit){
                    _hand.position = ccpSub(_handPositionAtHit,ccpMult(_shootDirection,0.f));
                }
                
                // after the hand has stopped for enough time, apply an impluse to let the hand go back
                if(_stopTime>=stopDuration){
                    double impulseScale = _hand.physicsBody.mass*1500;
                    
                    // change the shoot direction to the vector of _initialPosition to hand.position
                    _shootDirection = ccpNormalize(ccpSub(_hand.positionInPoints,_initialPosition));
                    
                    [_hand.physicsBody applyImpulse:ccp(-_shootDirection.x*impulseScale,-_shootDirection.y*impulseScale) atLocalPoint:_hand.anchorPointInPoints];
                    
                    isRangeReached = NO;
                    _isStopTimeReached = YES;
                    _isMonsterHit = NO;
                    _isGoBack = YES;
                    [GameEvent dispatch:@"ReleaseHand"];
                }
                
                if(_stopTime == 0){
                    // when hand is going back, it will not collide with any object
                    _hand.physicsBody.collisionMask = @[];
                }
                
                _stopTime = _stopTime + delta;
            }
        }
        
        // check whether the hand has been back to the origin;
        if(_isGoBack&&(handDist<=ccpDot(_initialPosition,_shootDirection))){
            _hand.physicsBody.velocity=ccp(0,0);
            _hand.position = _initialPosition;
            _isReleased = NO;
            
            // change the hand back to normal hand if its skill times is zero
            if(_hand.skillTimes==0){
                [self removeHand];
                [self addHandwithName:@"Hand"];
            }
        }
    }
    
    
}

- (BOOL)touchAtLocation:(CGPoint) touchLocation {
    
    // move the hand to the touch location, when the hand is in the status of being released, the touch is invalid
    //if ((!_isReleased) && CGRectContainsPoint([_hand boundingBox], touchLocation))
    
    // now you can just slide in the left region to activate hand.
    if ((!_isReleased) && touchLocation.x<_centerJointNode.positionInPoints.x)
    {
        // if the touch is on the right side of body, adjust it
        if(touchLocation.x>_centerJointNode.positionInPoints.x){
            touchLocation = CGPointMake(_centerJointNode.positionInPoints.x,touchLocation.y);
        }
        
        // constrain the max moving distance of the hand to be within controlRange
        CGPoint controlVector = ccpSub(touchLocation,_centerJointNode.positionInPoints);
        _shootDirection = ccpNormalize(ccpNeg(controlVector));
        _hand.position = ccpAdd(ccpNeg(ccpMult(_shootDirection,MIN(controlRange,ccpLength(controlVector)))),_centerJointNode.positionInPoints);
        
        _isTouched = YES;
        _isMoved = NO;
        _isReleased = NO;
        
        // add an arrow to indicate the direction
        _arrow = (CCSprite *)[CCBReader load:@"Arrow"];
        _arrow.scaleX = 0.5;
        _arrow.scaleY = 0.8;
        _arrow.position = _centerJointNode.positionInPoints;
        
        _arrow.rotation = ccpAngleSigned(_shootDirection, ccp(0,0)) / M_PI * 180;
        [self addChild:_arrow];
        [GameEvent dispatch:@"AimingHand"];
    }
    return _isTouched;
}

- (void)updateTouchLocation:(CGPoint) touchLocation {
    // update the position of mouse joint with touchLocation
    if (_isTouched){
        _isMoved = YES;
        // if the touch is on the right side of body, adjust it
        if(touchLocation.x>_centerJointNode.positionInPoints.x){
            touchLocation = CGPointMake(_centerJointNode.positionInPoints.x,touchLocation.y);
        }
        
        // constrain the max moving distance of the hand to be within controlRange
        CGPoint controlVector = ccpSub(touchLocation,_centerJointNode.positionInPoints);
        _shootDirection = ccpNormalize(ccpNeg(controlVector));
        _hand.position = ccpAdd(ccpNeg(ccpMult(_shootDirection,MIN(controlRange,ccpLength(controlVector)))),_centerJointNode.positionInPoints);
        
        // update the arrow's angle
        _arrow.rotation = ccpAngleSigned(_shootDirection, ccp(0,1)) / M_PI * 180;
    }
}

- (BOOL)releaseTouch{
    
    if (_isTouched&&_isMoved){
        // add an impulse to the hand when the touch is released
        double impulseScale = _hand.physicsBody.mass*1500;
        _shootDirection = ccpNormalize(ccpSub(_centerJointNode.positionInPoints,_hand.positionInPoints));
        [_hand.physicsBody applyImpulse:ccp(_shootDirection.x*impulseScale,_shootDirection.y*impulseScale) atLocalPoint:_hand.anchorPointInPoints];
        
        _isReleased = YES;
        _isGoBack = NO;
        _stopTime = 0;
        
        // after the hand is released, hand can collide with monsters
        _hand.physicsBody.collisionMask = @[@"monster"];
        
        _isTouched = NO;
        
        // remove the arrow
        [_arrow removeFromParent];
    }
    
    if(!_isMoved){
        _hand.position = _initialPosition;
    }
    return _isReleased;
}

-(void)receiveAttack{
    if(self.playerHP>0){
        [self.animationManager runAnimationsForSequenceNamed:@"beAttacked"];
    }
}

-(void)doubleAttackForDuration:(float)duration{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"buff.ogg"];
    
    // load particle effect
    CCParticleSystem *AtkBuffEffect = (CCParticleSystem *)[CCBReader load:@"AtkBuff"];
    AtkBuffEffect.position = ccp(30,-200);
    [self addChild:AtkBuffEffect z:-1];
    
    id doubleAttack = [CCActionSequence actions:[CCActionCallBlock actionWithBlock:^{_atkBuff = 2.0;}],[CCActionDelay actionWithDuration:duration],[CCActionCallBlock actionWithBlock:^{_atkBuff = 1.0;[AtkBuffEffect removeFromParent];}],nil];
    [self runAction:doubleAttack];
}

-(void)immuneFromAttackForDuration:(float)duration{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"buff.ogg"];
    
    CCSprite *shield = [CCSprite spriteWithImageNamed:@"UI/shield.png"];
    shield.position = ccp(140.0,95.0);
    shield.scaleX = 0;
    shield.scaleY = 0;
    [self addChild:shield];
    id tweenX = [CCActionTween actionWithDuration:1.5 key:@"ScaleX" from:0 to:5];
    id tweenY = [CCActionTween actionWithDuration:1.5 key:@"ScaleY" from:0 to:3.5];
    [shield runAction:tweenX];
    [shield runAction:tweenY];
    
    id immune = [CCActionSequence actions:[CCActionCallBlock actionWithBlock:^{_damageReduction = 0.0;}],[CCActionDelay actionWithDuration:duration],[CCActionCallBlock actionWithBlock:^{_damageReduction = 1.0;[shield removeFromParent];}],nil];
    [self runAction:immune];
}

-(void)shootingForDuration:(float)duration{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"buff.ogg"];
    
    // load particle effect
    CCParticleSystem *buffEffect = (CCParticleSystem *)[CCBReader load:@"AccurancyBuffEffect"];
    buffEffect.position = ccp(90,80);
    [self.hand addChild:buffEffect];
    
    id shooting = [CCActionSequence actions:[CCActionCallBlock actionWithBlock:^{_isShooting = YES;}],[CCActionDelay actionWithDuration:duration],[CCActionCallBlock actionWithBlock:^{_isShooting = NO;[buffEffect removeFromParent];}],nil];
    [self runAction:shooting];
}

-(void)heal:(float)recoverHP{
    if(recoverHP>0){
        _playerHP = MIN(_playerHP + recoverHP,100);
        CCParticleSystem *healEffect = (CCParticleSystem *)[CCBReader load:@"HealEffect"];
        healEffect.autoRemoveOnFinish = TRUE;
        healEffect.position = _centerJointNode.positionInPoints;
        [self addChild:healEffect];
        
        // play sound effect
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playEffect:@"heal.ogg"];
    }
}

@end
