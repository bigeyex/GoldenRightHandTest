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
#import "GameGlobals.h"

@implementation BattleScene{
    CCPhysicsNode *_physicsNode;
    Player *_player;
    LevelLoader *_monsterList;
    LifeBar *_playerLifeBar;
    int _totalNumOfMonsters;
    int _monstersKilled;
    SkillButtonUI *_skillButton;
    CCLabelTTF *_skillDescription;
    NSMutableArray *_skillDescriptionArray;
    
    BOOL foundSausage;
    BOOL _isLose;
    int countOfPlayerAttacks;
    int countOfHit;
    
    CCNode* pauseButton;
    CCNode* pauseMenu;
    CCNode* gameOverMenu;
    CCNode* scoreBoardMenu;
    UIScoreBoard *uiScoreBoard;
    CCLabelTTF *gameOverMessage;
    
    float timeSinceGameStarted;
}

+ (void)loadSceneByLevelIndex:(int)levelIndex{
    NSString* levelName = [[GameGlobals sharedInstance] levelNameAtIndex:levelIndex];
    if(levelName != nil){
        CCScene *battleScene = [CCBReader loadAsScene:@"BattleScene"];
        BattleScene *sceneNode = [[battleScene children] firstObject];
        sceneNode.levelName = levelName;
        sceneNode.levelIndex = levelIndex;
        // in case the game is paused (when selecting "restart" in the pause screen)
        [[CCDirector sharedDirector] resume];
        [[CCDirector sharedDirector] replaceScene:battleScene];
        
        // show or hide "next level" button
        if([[GameGlobals sharedInstance] levelNames].count <= sceneNode.levelIndex+1){
            sceneNode.nextLevelButton.visible = NO;
        }
        else{
            sceneNode.nextLevelButton.visible = YES;
        }
        
        // HACK: Level 4 is endless mode
        if(levelIndex == 3){
            sceneNode.endlessMode = YES;
            OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
            [audio playBg:@"bossbattle.mp3" loop:true];
        }
    }
}

+ (id)init{
    // every scene should start with new game event object.
    [GameEvent reset];
    return [super init];
}

- (void)didLoadFromCCB {
    [GameEvent clearEvent:@"MonsterRemoved"];
    [GameEvent clearEvent:@"FoundSausage"];
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    self.endlessMode = NO;
    
    // visualize physics bodies & joints
    //_physicsNode.debugDraw = YES;
    
    // sign up as the collision delegate of physics node
    _physicsNode.collisionDelegate = self;
    
    // play bgm
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    // play background sound
    [audio playBg:@"iceloop.mp3" loop:true];
    
    [GameEvent subscribe:@"MonsterRemoved" forObject:self withSelector:@selector(checkWinningCondition)];
    [_skillButton.children[0] setEnabled:NO];
    [uiScoreBoard reset];
    [self initSkillDescriptionArray];
    _skillDescription.string = @"Collect 3 element to use skills";
    _skillDescription.opacity = 0.5;
    
    countOfPlayerAttacks = 0;
    countOfHit = 0;
    foundSausage = NO;
    _isLose = NO;
    [GameEvent subscribe:@"FoundSausage" forObject:self withSelector:@selector(onFoundSausage)];
    
}

- (void)onFoundSausage{
    foundSausage = YES;
}

- (void)onEnter{
    [super onEnter];
    _totalNumOfMonsters = [_monsterList loadLevel:_levelName];
    _monstersKilled = 0;
}

- (void) initSkillDescriptionArray{
    _skillDescriptionArray = [NSMutableArray arrayWithObjects:
                              @"Firestorm",
                              @"100% Accuracy (10sec)",
                              @"Fist of Fire",
                              @"Double Damage",@"n/a",
                              @"Fist of Ice",@"n/a",
                              @"Icestorm",
                              @"Healing",@"n/a",@"n/a",
                              @"Instant Kill",@"n/a",@"n/a",@"n/a",@"n/a",@"n/a",
                              @"Fist of Absorbing",@"n/a",@"n/a",@"n/a",@"n/a",@"n/a",@"n/a",@"n/a",@"n/a",
                              @"Invincible (10sec)",
                              nil];
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
    // avoid rare case when last BattleScene listens to a event and still exists.
    [GameEvent reset];
    CCScene *battleScene = [CCBReader loadAsScene:@"BattleScene"];
    BattleScene *sceneNode = [[battleScene children] firstObject];
    sceneNode.levelName = self.levelName;
    sceneNode.endlessMode = self.endlessMode;
    sceneNode.levelIndex = self.levelIndex;
    // Play new bg at endless node. This is so ugly..
    if(self.endlessMode){
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio playBg:@"bossbattle.mp3" loop:true];
    }
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene:battleScene];
}

- (void)goToNextLevel{
    [[self class] loadSceneByLevelIndex:self.levelIndex+1];
}

- (void)exitToMenu{
    [[CCDirector sharedDirector] resume];
    CCScene *winScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:winScene];
}

- (void)update:(CCTime)delta{
    timeSinceGameStarted += delta;
}

-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_player];
    
    // call Player's method touchAtLocation to deal with the touch event
    BOOL isTouched = [_player touchAtLocation:touchLocation];
    [_player updateTouchLocation:touchLocation];
    
    if (isTouched){
        int numOfMonsters = (int)[_monsterList.children count];
        for (int i = 0;i<numOfMonsters;i++){
            Monster *_checkNode = _monsterList.children[i];
            [_checkNode monsterCharge];
        }
    }
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
        countOfPlayerAttacks++;
        //NSLog(@"%d",countOfPlayerAttacks);
        [self monsterAI];
        int numOfMonsters = (int)[_monsterList.children count];
        for (int i = 0;i<numOfMonsters;i++){
            Monster *_checkNode = _monsterList.children[i];
            [_checkNode monsterChargeCancel];
        }
    }
}

-(void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // tell player the touch is cancelled
    BOOL isReleased = [_player releaseTouch];
    if(isReleased){
        [self monsterAI];
        int numOfMonsters = (int)[_monsterList.children count];
        for (int i = 0;i<numOfMonsters;i++){
            Monster *_checkNode = _monsterList.children[i];
            [_checkNode monsterChargeCancel];
        }
    }
}

- (void) monsterAI{
    if(!_player.isShooting){
        int numOfMonsters = (int)[_monsterList.children count];
        Monster *monsterBeAttacked;
        float minProjectDistance=10000;
        for (int i = 0;i<numOfMonsters;i++){
            Monster *_checkNode = _monsterList.children[i];
            CGPoint handPosition = [_player convertToWorldSpace:_player.hand.positionInPoints];
            CGPoint monsterPosition = [_checkNode convertToWorldSpace:_checkNode.physicsBody.body.centerOfGravity];
            
            float distance = fabsf(_player.shootDirection.y*(monsterPosition.x-handPosition.x)-_player.shootDirection.x*(monsterPosition.y-handPosition.y));
            // if the monster is targeted
            if (distance<=20*2){
                
                // if the monster is elite, perform evade behavior
                if(_checkNode.isElite){
                    [_checkNode monsterEvade];
                }
                
                // calculate which monster is being attacked
                float projectDistance = ccpDot(_player.shootDirection,ccpSub(monsterPosition,handPosition));
                if(minProjectDistance>projectDistance){
                    monsterBeAttacked = _checkNode;
                    minProjectDistance = projectDistance;
                }
            }
        }
        
        // the being hitted monster ask for protection
        if(monsterBeAttacked){
            [monsterBeAttacked seekProtection:_monsterList];
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
        
        // play sound effect
        [_player.hand playHitSound];
        
        BOOL isDefeated = [nodeA receiveHitWithDamage:nodeB.atk * _player.atkBuff];
        float recoverHP = [_player.hand handSkillwithMonster:nodeA MonsterList:_monsterList];
        
        [_player heal:recoverHP];
        [_playerLifeBar setLength:_player.playerHP];
        
        _player.handPositionAtHit = _player.hand.positionInPoints;
        _player.isMonsterHit = YES;
        _player.isStopTimeReached = NO;
        
        countOfHit++;
        //NSLog(@"%d",countOfHit);
        
        //        nodeA.physicsBody.velocity = ccp(0,0);
        
        // when a monster is killed
        if(isDefeated){
            [GameEvent dispatch:@"MonsterDefeated" withArgument:nodeA];
            
            // the skill element motion animation
            CCSprite *element = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"UI/%@.png",nodeA.elementType]];
            element.position = nodeA.positionInPoints;
            element.opacity = 0.5;
            [self addChild:element];
            id elementMotion = [CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.5 position:ccpAdd(_skillButton.positionInPoints,ccp(-50,70))],[CCActionCallBlock actionWithBlock:^{[element removeFromParent];}],nil];
            [element runAction:elementMotion];
            
            // remove the monster from the scene
            //            [nodeA removeFromParent];
            //            [self checkWinningCondition];
            
            // assign the element type to the skill button ui
            _skillButton.lowerRightElement = _skillButton.lowerLeftElement;
            _skillButton.lowerLeftElement = _skillButton.upperElement;
            _skillButton.upperElement = nodeA.elementType;
            if(![_skillButton.lowerRightElement isEqualToString:@"none"]){
                [GameEvent dispatch:@"GetSkill"];
                [_skillButton.children[0] setEnabled:YES];
                [self showSkillDescription];
            }
            
        }
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair monster:(Monster *)nodeA human:(CCNode *)nodeB
{
    [[_physicsNode space] addPostStepBlock:^{
        // when monster is protecting others, isEvading is true. In race cases, the protected monster is close to the player, the one protecting others therefore would collide with tbe body. This case should be removed
        if(!(nodeA.isAttacking)&&(!nodeA.isStopped)&&(!nodeA.isEvading)){
            [nodeA startAttack];
            
            if(_player.damageReduction != 0.0){
                _player.playerHP = _player.playerHP - nodeA.atk * _player.damageReduction;
                [_player receiveAttack];
                [_playerLifeBar setLength:_player.playerHP];
                if(_player.playerHP<=0 && !_isLose){
                    _isLose = YES;
                    self.userInteractionEnabled = NO;
                    [_player.animationManager runAnimationsForSequenceNamed:@"dead"];
                    [self scheduleOnce:@selector(battleLose:) delay:2.0f];
                }
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

-(void)battleLose:(CCTime)delta{
    self.userInteractionEnabled = TRUE;
    [[CCDirector sharedDirector] pause];
    gameOverMenu.visible = YES;
    pauseMenu.visible = NO;
    if(self.endlessMode){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id defaultObject = [defaults objectForKey:@"EndlessHiScore"];
        if(defaultObject == nil){
            gameOverMessage.string = [NSString stringWithFormat:@"Survival: %.2fs Hi: ---", timeSinceGameStarted];
            [defaults setObject:[NSNumber numberWithFloat:timeSinceGameStarted] forKey:@"EndlessHiScore"];
        }
        else{
            float hiScore = [defaultObject floatValue];
            gameOverMessage.string = [NSString stringWithFormat:@"Survival: %.2fs Hi: %.2fs", timeSinceGameStarted, hiScore];
            if(timeSinceGameStarted > hiScore){
                [defaults setObject:[NSNumber numberWithFloat:timeSinceGameStarted] forKey:@"EndlessHiScore"];
            }
        }
        
    }
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
    [uiScoreBoard reset];
    if(_player.playerHP > 75){
        [uiScoreBoard giveStarForReason:@"Health > 75%"];
    }
    if(countOfPlayerAttacks>0 && ((float)countOfHit/(float)countOfPlayerAttacks)>0.75){
        [uiScoreBoard giveStarForReason:@"Accuracy > 75%"];
    }
    if(foundSausage){
        [uiScoreBoard giveStarForReason:@"Found Sausage"];
    }
    [uiScoreBoard displayStars];
    
    // save the star of current level
    int stars = [uiScoreBoard numberOfStars];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(stars>[[defaults objectForKey:_levelName] intValue]){
        [defaults setObject:[NSNumber numberWithInt:stars] forKey:_levelName];
        [defaults synchronize];
    }
}

-(void)activateSkill{
    NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"fire",[NSNumber numberWithInt:2],@"ice",[NSNumber numberWithInt:3],@"dark", nil];
    int skillOptions = [map[_skillButton.upperElement] intValue] * [map[_skillButton.lowerLeftElement] intValue] * [map[_skillButton.lowerRightElement] intValue];
    switch(skillOptions){
        case 1: // fire * fire * fire
            // deal 5 damage to all the monsters
            [self dealDamageToAllMonsters:5.0];
            break;
            
        case 2: // fire * fire * ice
            // hit that can't be evaded
            [_player shootingForDuration:10.0];
            break;
            
        case 3: // fire * fire * dark
            // use a fire fist which deal damage to an area
            [_player removeHand];
            [_player addHandwithName:@"FireHand"];
            break;
            
        case 4: // fire * ice * ice
            // double the attack for 10s
            [_player doubleAttackForDuration:10.0];
            break;
            
        case 6: // fire * ice * dark
            // use an ice fist to deal damage to one monster and freeze all others surrounding it
            [_player removeHand];
            [_player addHandwithName:@"IceHand"];
            break;
            
        case 8: // ice * ice * ice
            // freeze all monsters for 5.0s
            [self freezeAllMonsters:5];
            break;
            
        case 9: // fire * dark * dark
            // heal for 30 hp
            [_player heal:30.0];
            [_playerLifeBar setLength:_player.playerHP];
            break;
            
        case 12: // ice * ice * dark
            // use a death fist which kill any monster touched
            [_player removeHand];
            [_player addHandwithName:@"DeathHand"];
            break;
            
        case 18: // ice * dark * dark
            // use a dark fist to absorb hp from monsters
            [_player removeHand];
            [_player addHandwithName:@"DarkHand"];
            break;
            
        case 27: // dark * dark * dark
            // receive zero damage for 10s
            [_player immuneFromAttackForDuration:10.0];
            break;
    }
    
    [_skillButton resetElement];
    [_skillButton.children[0] setEnabled:NO];
    _skillDescription.string = @"Collect 3 element to use skills";
    _skillDescription.opacity = 0.5;
    [GameEvent dispatch:@"UseSkill"];
}

-(void) dealDamageToAllMonsters:(float)damage{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"fireSpell.mp3"];
    
    // add particle effect
    CCParticleSystem *attackAllEffect = (CCParticleSystem *)[CCBReader load:@"AttackAllEffect"];
    attackAllEffect.autoRemoveOnFinish = TRUE;
    attackAllEffect.position = ccp(350,160);
    [self addChild:attackAllEffect];
    
    
    int numOfMonsters = (int)[_monsterList.children count];
    for (int i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = _monsterList.children[i];
        BOOL isDefeated = [_checkNode receiveHitWithDamage:5.0];
        if(isDefeated){
            [_checkNode removeFromParent];
            i--;
            numOfMonsters--;
            [self checkWinningCondition];
        }
    }
}

-(void) freezeAllMonsters:(float)duration{
    // play sound effect
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:@"iceSpell.mp3"];
    
    // add particle effect
    CCParticleSystem *attackAllEffect = (CCParticleSystem *)[CCBReader load:@"FreezeAllEffect"];
    attackAllEffect.autoRemoveOnFinish = TRUE;
    attackAllEffect.position = ccp(350,160);
    [self addChild:attackAllEffect];
    
    int numOfMonsters = (int)[_monsterList.children count];
    for (int i = 0;i<numOfMonsters;i++){
        Monster *_checkNode = _monsterList.children[i];
        [_checkNode stopMovingForDuration:duration];
        CCSprite* iceImage = [CCSprite spriteWithImageNamed:@"UI/ice-block.png"];
        iceImage.name = @"iceblock";
        iceImage.position = _checkNode.position;
        [_checkNode addChild:iceImage];

    }
}

-(void) showSkillDescription{
    NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"fire",[NSNumber numberWithInt:2],@"ice",[NSNumber numberWithInt:3],@"dark", nil];
    int skillOptions = [map[_skillButton.upperElement] intValue] * [map[_skillButton.lowerLeftElement] intValue] * [map[_skillButton.lowerRightElement] intValue];
    _skillDescription.string = _skillDescriptionArray[skillOptions-1];
    _skillDescription.opacity = 1.0;
}

- (SkillButtonUI*)skillButton{
    return _skillButton;
}

@end
