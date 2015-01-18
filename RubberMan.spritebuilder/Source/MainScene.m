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
    CCButton *_skillbox1;
    CCButton *_skillbox2;
    CCButton *_skillbox3;
    NSMutableArray *_skillbox;
}

static double collisionThreshold = 1000.0;

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // visualize physics bodies & joints
    //_physicsNode.debugDraw = YES;
    
    // sign up as the collision delegate of physics node
    _physicsNode.collisionDelegate = self;
    
    [_monsterList loadLevel:@"level1"];
    
    // disable the button
    _skillbox = [NSMutableArray arrayWithObjects:_skillbox1,_skillbox2,_skillbox3,nil];
    for (int i=0;i<=2;i++){
        [_skillbox[i] setEnabled:NO];
    }
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
            BOOL isDefeated = [nodeA receiveHitWithDamage:nodeB.atk];
            float recoverHP = [_player.hand handSkillwithMonster:nodeA MonsterList:_monsterList];
            
            _player.playerHP = MIN(_player.playerHP + recoverHP,100);
            [_playerLifeBar setLength:_player.playerHP];
            
            _player.handPositionAtHit = _player.hand.positionInPoints;
            _player.isMonsterHit = YES;
            _player.isStopTimeReached = NO;
            
            if(isDefeated){
                // player's mana is increased by 1
                _player.mana[nodeA.elementType] = [_player.mana[nodeA.elementType] decimalNumberByAdding:[NSDecimalNumber one]];
                
                // remove the monster from the scene
                [nodeA removeFromParent];
                
                // enable the skill button if the mana is enough
                for (int i=0;i<=2;i++){
                    if([_player.mana[i] intValue]>=_player.skillcost){
                        [_skillbox[i] setEnabled:YES];
                    }
                }
            }
            NSLog(@"Fire mana is %@",_player.mana[0]);
            NSLog(@"Ice mana is %@",_player.mana[1]);
            NSLog(@"Dark mana is %@",_player.mana[2]);
            
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
    int elementType = 0;
    NSString *ccbName = @"Hand";
    
    if(_skillbox1.highlighted){
        elementType = 0;
        ccbName = @"FireHand";
    } else if(_skillbox2.highlighted){
        elementType = 1;
        ccbName = @"IceHand";
    } else if(_skillbox3.highlighted){
        elementType = 2;
        ccbName = @"DarkHand";
    }
    
    // recover the unused player mana
    if(_player.hand.handType!=-1){
        _player.mana[_player.hand.handType] = [_player.mana[_player.hand.handType] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", _player.skillcost]]];
        [_skillbox[_player.hand.handType] setEnabled:YES];
    }
    
    // player's mana is decreased by skill cost
    _player.mana[elementType] = [_player.mana[elementType] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", _player.skillcost]]];

    // remove the normal hand
    [_player removeHand];
    
    // add the new fire hand
    [_player addHandwithName:ccbName];
    
    // disable the skill button if mana is insufficient
    [_skillbox[elementType] setEnabled:NO];
}

@end
