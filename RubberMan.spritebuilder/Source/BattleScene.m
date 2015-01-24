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
#import "GameEvent.h"
#import "SkillButtonUI.h"

@implementation BattleScene{
    CCPhysicsNode *_physicsNode;
    Player *_player;
    LevelLoader *_monsterList;
    LifeBar *_playerLifeBar;
    int _totalNumOfMonsters;
    int _monstersKilled;
    SkillButtonUI *_skillButton;
    
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
    
    // play bgm
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play background sound
    [audio playBg:@"iceloop.mp3" loop:TRUE];
    
    [GameEvent subscribe:@"MonsterRemoved" forObject:self withSelector:@selector(checkWinningCondition)];
    [_skillButton.children[0] setEnabled:NO];
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
                
        BOOL isDefeated = [nodeA receiveHitWithDamage:nodeB.atk];
        float recoverHP = [_player.hand handSkillwithMonster:nodeA MonsterList:_monsterList];
        
        _player.playerHP = MIN(_player.playerHP + recoverHP,100);
        [_playerLifeBar setLength:_player.playerHP];
        
        _player.handPositionAtHit = _player.hand.positionInPoints;
        _player.isMonsterHit = YES;
        _player.isStopTimeReached = NO;
        
        nodeA.physicsBody.velocity = ccp(0,0);
        
        if(isDefeated){
            // remove the monster from the scene
            [nodeA removeFromParent];
            
            // assign the element type to the skill button ui
            _skillButton.lowerRightElement = _skillButton.lowerLeftElement;
            _skillButton.lowerLeftElement = _skillButton.upperElement;
            _skillButton.upperElement = nodeA.elementType;
            if(![_skillButton.lowerRightElement isEqualToString:@"none"]){
                [_skillButton.children[0] setEnabled:YES];
            }
            
        }
        
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA human:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        if(!(nodeA.isAttacking)&&(!nodeA.isStopped)){
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

- (BOOL)satifsyWinningCondition{
    if(![_monsterList hasMoreMonsters] && ([_monsterList children].count==0)){
        return YES;
    }
    else{
        return NO;
    }
}

-(void)battleLose{
    [[CCDirector sharedDirector] pause];
    gameOverMenu.visible = YES;
    pauseMenu.visible = NO;
}

- (void)checkWinningCondition{
    if([self satifsyWinningCondition]){
        [self scheduleOnce:@selector(battleWin:) delay:2.0f];
    }
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
    
    // save the star of current level
    int stars = 3;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:stars] forKey:_levelName];
    [defaults synchronize];
}

-(void)activateSkill{
    NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"fire",[NSNumber numberWithInt:2],@"ice",[NSNumber numberWithInt:3],@"dark", nil];
    int skillOptions = [map[_skillButton.upperElement] intValue] * [map[_skillButton.lowerLeftElement] intValue] * [map[_skillButton.lowerRightElement] intValue];
    switch(skillOptions){
        case 1: // fire * fire * fire

            [_player removeHand];
            [_player addHandwithName:@"FireHand"];
            break;
        
        case 2: // fire * fire * ice
            break;
            
        case 3: // fire * fire * dark
            break;
            
        case 4: // fire * ice * ice
            
            break;
            
        case 6: // fire * ice * dark
            break;
            
        case 8: // ice * ice * ice
            
            [_player removeHand];
            [_player addHandwithName:@"IceHand"];
            break;
            
        case 9: // fire * dark * dark
            break;
            
        case 12: // ice * ice * dark
            break;
            
        case 18: // ice * dark * dark
            break;
            
        case 27: // dark * dark * dark

            [_player removeHand];
            [_player addHandwithName:@"DarkHand"];
            break;
    }
    
    [_skillButton resetElement];
    [_skillButton.children[0] setEnabled:NO];
}

@end
