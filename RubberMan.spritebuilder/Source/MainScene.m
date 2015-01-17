#import "MainScene.h"
#import "Player.h"
#import "Monster.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "GDataXMLNode.h"
#import "LevelLoader.h"
#import "LifeBar.h"

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
    Player *_player;
    LevelLoader *_monsterList;
    LifeBar *_playerLifeBar;
    CCButton *_skillbox;
}

double collisionThreshold = 1000.0;

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // visualize physics bodies & joints
    _physicsNode.debugDraw = YES;
    
    // sign up as the collision delegate of physics node
    _physicsNode.collisionDelegate = self;
    
    [_monsterList loadLevel:@"level1"];
    
    // disable the button
    _skillbox.enabled = NO;
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
    
    // if energy is large enough, remove the monster
    if ((energy > collisionThreshold)) {
        if((!_player.isGoBack) && (!_player.isMonsterHit)){
            CGPoint monsterPosition = nodeA.positionInPoints;
            int monsterElementType = nodeA.elementType;
            BOOL isDefeated = [nodeA receiveHitWithDamage:nodeB.atk];
            [_player.hand handSkillwithMonsterPosition:monsterPosition MonsterList:_monsterList];
            _player.handPositionAtHit = _player.hand.positionInPoints;
            _player.isMonsterHit = YES;
            _player.isStopTimeReached = NO;
            
            if(isDefeated){
                // player's mana is increased by 1
                _player.mana[monsterElementType] = [_player.mana[monsterElementType] decimalNumberByAdding:[NSDecimalNumber one]];
                
                // enable the skill button if the mana is enough
                if([_player.mana[0] intValue]>=_player.skillcost){
                    _skillbox.enabled = YES;
                }
            }
        }
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA human:(CCNode *)nodeB
{
    if(!(nodeA.isAttacking)){
        [nodeA startAttack];
        _player.playerHP = _player.playerHP - nodeA.atk;
        [_playerLifeBar setLength:_player.playerHP];
    }
}

-(void)changeHand{
    
    // player's mana is decreased by skill cost
    _player.mana[0] = [_player.mana[0] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", _player.skillcost]]];
    
    // remove the normal hand
    [_player removeHand];
    
    // add the new fire hand
    [_player addHandwithName:@"FireHand"];
    
    // disable the skill button if mana is insufficient
    if([_player.mana[0] intValue]<_player.skillcost){
        _skillbox.enabled = NO;
    }
}

@end
