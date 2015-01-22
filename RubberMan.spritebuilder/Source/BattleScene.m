//
//  BattleScene.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BattleScene.h"
#import "Player.h"
#import "Monster.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "GDataXMLNode.h"
#import "LevelLoader.h"
#import "LifeBar.h"
#import "UIScoreBoard.h"

@implementation BattleScene{
    CCPhysicsNode *_physicsNode;
    Player *_player;
    LevelLoader *_monsterList;
    LifeBar *_playerLifeBar;
    CCButton *_skillbox1;
    CCButton *_skillbox2;
    CCButton *_skillbox3;
    int _totalNumOfMonsters;
    int _monstersKilled;
    NSMutableArray *_skillbox;
    
    CCNode* pauseButton;
    CCNode* pauseMenu;
    CCNode* gameOverMenu;
    CCNode* scoreBoardMenu;
    UIScoreBoard *uiScoreBoard;
    
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // visualize physics bodies & joints
    //_physicsNode.debugDraw = YES;
    
    // sign up as the collision delegate of physics node
    _physicsNode.collisionDelegate = self;
    
    // disable the button
    _skillbox = [NSMutableArray arrayWithObjects:_skillbox1,_skillbox2,_skillbox3,nil];
    for (int i=0;i<=2;i++){
        [_skillbox[i] setEnabled:NO];
    }
    
    
}

- (void)onEnter{
    [super onEnter];
    _totalNumOfMonsters = [_monsterList loadLevel:_levelName];
    _monstersKilled = 0;
}

- (void)showPauseMenu{
    [[CCDirector sharedDirector] pause];
    pauseButton.visible = NO;
    pauseMenu.visible = YES;
}

- (void)resumeGame{
    pauseMenu.visible = NO;
    gameOverMenu.visible = NO;
    pauseButton.visible = YES;
    [[CCDirector sharedDirector] resume];
}

- (void)restartLevel{
    CCScene *battleScene = [CCBReader loadAsScene:@"BattleScene"];
    BattleScene *sceneNode = [[battleScene children] firstObject];
    sceneNode.levelName = self.levelName;
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:battleScene];
}

- (void)goToNextLevel{
    
}

- (void)exitToMenu{
    [[CCDirector sharedDirector] resume];
    CCScene *winScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:winScene];
}

- (void)update:(CCTime)delta{
    
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
    BOOL isReleased = [_player releaseTouch];
    if(isReleased){
        [self monsterAI];
    }
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // tell player the touch is cancelled
    BOOL isReleased = [_player releaseTouch];
    if(isReleased){
        [self monsterAI];
    }
}

- (void) monsterAI{
    int numOfMonsters = (int)[_monsterList.children count];
    for (int i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = _monsterList.children[i];
        if(_checkNode.isElite){
            CGPoint handPosition = [_player convertToWorldSpace:_player.hand.positionInPoints];
            CGPoint monsterPosition = [_checkNode convertToWorldSpace:_checkNode.physicsBody.body.centerOfGravity];
            float distance = fabsf(_player.shootDirection.y*(monsterPosition.x-handPosition.x)-_player.shootDirection.x*(monsterPosition.y-handPosition.y));
            
            // NOTE: this is to assume the hand size is 20 and the monster size is 20 also, potential bug
            // if the monster is targeted
            if (distance<=20*2){
                [_checkNode monsterEvade];
            }
        }
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA hand:(Hand *)nodeB{
    // when the monster is hit or the hand is going back, ignore all the collision
    return (!_player.isMonsterHit) && (!_player.isGoBack);
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA hand:(Hand *)nodeB
{
    if((!_player.isGoBack) && (!_player.isMonsterHit)){
        
        int numOfMonstersOld = (int)[_monsterList.children count];
        
        BOOL isDefeated = [nodeA receiveHitWithDamage:nodeB.atk];
        float recoverHP = [_player.hand handSkillwithMonster:nodeA MonsterList:_monsterList];
        
        _player.playerHP = MIN(_player.playerHP + recoverHP,100);
        [_playerLifeBar setLength:_player.playerHP];
        
        _player.handPositionAtHit = _player.hand.positionInPoints;
        _player.isMonsterHit = YES;
        _player.isStopTimeReached = NO;
        
        nodeA.physicsBody.velocity = ccp(0,0);
        
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
        
        int numOfMonstersNew = (int)[_monsterList.children count];
        _monstersKilled = _monstersKilled + numOfMonstersOld - numOfMonstersNew;
        if(_monstersKilled == _totalNumOfMonsters){
            [self scheduleOnce:@selector(battleWin:) delay:2.0f];
        }
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA human:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        if(!(nodeA.isAttacking)){
            [nodeA startAttack];
            [_player receiveAttack];
            _player.playerHP = _player.playerHP - nodeA.atk;
            [_playerLifeBar setLength:_player.playerHP];
            if(_player.playerHP<=0){
                [self battleLose];
            }
        }
    } key:nodeA];
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
    if((_player.hand.handType!=-1)&&(_player.hand.skillTimes)){
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

-(void)battleLose{
    [[CCDirector sharedDirector] pause];
    gameOverMenu.visible = YES;
    pauseMenu.visible = NO;
}

-(void)battleWin:(CCTime)delta{
    [[CCDirector sharedDirector] pause];
    scoreBoardMenu.visible = YES;
    pauseMenu.visible = NO;
    
    // TODO: Implement Score System
    [uiScoreBoard giveStarForReason:@"Health > 75%"];
    [uiScoreBoard giveStarForReason:@"Accuracy > 75%"];
    [uiScoreBoard giveStarForReason:@"Find Sausage"];
    [uiScoreBoard displayStars];
}


@end
