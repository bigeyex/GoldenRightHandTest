#import "MainScene.h"
#import "Player.h"
#import "Monster.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    Player *_player;
    Monster *_monster;
}

double collisionThreshold = 1000.0;

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // visualize physics bodies & joints
    //_physicsNode.debugDraw = YES;
    
    // sign up as the collision delegate of physics node
    _physicsNode.collisionDelegate = self;
}

-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_player];
    
    // call Player's method touchAtLocation to deal with the touch event
    [_player touchAtLocation:touchLocation];
    
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_player];
    
    // tell player the touch is moved
    [_player updateTouchLocation:touchLocation];
    
}

-(void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // tell player the touch is ended
    [_player releaseTouch];
    
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // tell player the touch is cancelled
    [_player releaseTouch];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA hand:(Hand *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the seal
    if (energy > collisionThreshold) {
        [[_physicsNode space] addPostStepBlock:^{
            [nodeA removeFromParent];
        } key:nodeA];
    }
}

@end
