//
//  LevelLoader.m
//  RubberMan
//
//  Created by Wang Yu on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelLoader.h"
#import "MonsterData.h"
#import "GDataXMLNode.h"
#import "Monster.h"
#import "GameEvent.h"
#import "TutorialManager.h"

// Tutorials - has to hard code classes for lack of dynamic loading capability.
#import "BasicTutorial.h"

@implementation LevelLoader{
    NSMutableArray* monsterDataList;
    BOOL isLevelLoaded;
    CGFloat timeSinceStarted;
    NSMutableDictionary *_numOfMonsters;
}

- (void)didLoadFromCCB{
    _numOfMonsters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"NormalWalker",
                      [NSNumber numberWithInt:0],@"NormalBat",
                      [NSNumber numberWithInt:0],@"NormalGhost",
                      [NSNumber numberWithInt:0],@"EliteWalker",
                      [NSNumber numberWithInt:0],@"EliteBat",
                      [NSNumber numberWithInt:0],@"EliteGhost",nil];
    isLevelLoaded = NO;
    [GameEvent subscribe:@"PauseMonsters" forObject:self withSelector:@selector(pauseMonsters)];
    [GameEvent subscribe:@"ResumeMonsters" forObject:self withSelector:@selector(resumeMonsters)];
    [GameEvent subscribe:@"MonsterDefeated" forObject:self withSelector:@selector(updateNumOfMonsters:)];
}

- (void)pauseMonsters{
    self.paused = YES;
}

- (void)resumeMonsters{
    self.paused = NO;
}

- (void)updateNumOfMonsters:(Monster *)monster{
    _numOfMonsters[monster.monsterName] = [NSNumber numberWithInt:([_numOfMonsters[monster.monsterName] intValue]-1)];
}

- (BOOL)hasMoreMonsters{
    if(monsterDataList.count != 0){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)update:(CCTime)delta{
    timeSinceStarted += delta;
    
    NSMutableArray *discardedMonsterDataList = [NSMutableArray array];
    
    for (MonsterData *monsterData in monsterDataList){
        if([monsterData shouldRespawn:timeSinceStarted]){
            Monster *monster = [monsterData respawn];
            monster.numOfPreviousNormalWalker = [_numOfMonsters[@"NormalWalker"] intValue];
            monster.numOfPreviousNormalBat = [_numOfMonsters[@"NormalBat"] intValue];
            monster.numOfPreviousNormalGhost = [_numOfMonsters[@"NormalGhost"] intValue];
            monster.numOfPreviousEliteWalker = [_numOfMonsters[@"EliteWalker"] intValue];
            monster.numOfPreviousEliteBat = [_numOfMonsters[@"EliteBat"] intValue];
            monster.numOfPreviousEliteGhost = [_numOfMonsters[@"EliteGhost"] intValue];
            
            [self addChild:monster];

            _numOfMonsters[monster.monsterName] = [NSNumber numberWithInt:([_numOfMonsters[monster.monsterName] intValue]+1)];
            
            if(![monsterData hasNextUnit]){
                [discardedMonsterDataList addObject:monsterData];
            }
        }
    }
    
    [monsterDataList removeObjectsInArray:discardedMonsterDataList];
//    NSLog(@"%f", timeSinceStarted);
}


- (int)loadLevel:(NSString*)levelName{
    NSString* path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"xml"];
    
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:path];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    if (doc == nil) { NSLog(@"Loading failed"); return -1; }
    
    monsterDataList = [NSMutableArray array];
    
    // load enemies into the level
    int totalNumOfEmeny = 0;
    NSArray *levelEnemiesNodes = [doc nodesForXPath:@"//LevelData/MonsterData/Monster" error:nil];
    for (GDataXMLElement *enemyNode in levelEnemiesNodes) {
        MonsterData *monsterData;
        
        NSArray *spriteNames = [enemyNode elementsForName:@"SpriteName"];
        if (spriteNames.count > 0) {
            GDataXMLElement *spriteNameNode = (GDataXMLElement *) [spriteNames objectAtIndex:0];
            monsterData = [MonsterData fromSpriteName:spriteNameNode.stringValue];
        } else{
            [NSException raise:@"Enemy Nodes in Level XML File should at least contains level name"  format:@""];
        };
     
        NSArray *enterTimes = [enemyNode elementsForName:@"EnterTime"];
        if (enterTimes.count > 0) {
            GDataXMLElement *enterTimeNode = (GDataXMLElement *) [enterTimes objectAtIndex:0];
            monsterData.enterTime = [enterTimeNode.stringValue floatValue];
        }
        
        NSArray *unitNumbers = [enemyNode elementsForName:@"Number"];
        if (unitNumbers.count > 0) {
            GDataXMLElement *unitNumberNode = (GDataXMLElement *) [unitNumbers objectAtIndex:0];
            monsterData.number = [unitNumberNode.stringValue intValue];
            totalNumOfEmeny = totalNumOfEmeny + monsterData.number;
        }
        
        NSArray *respawnIntervals = [enemyNode elementsForName:@"RespawnInterval"];
        if (respawnIntervals.count > 0) {
            GDataXMLElement *respawnIntervalNode = (GDataXMLElement *) [respawnIntervals objectAtIndex:0];
            monsterData.respawnInterval = [respawnIntervalNode.stringValue floatValue];
        }
        
        NSArray *positionYs = [enemyNode elementsForName:@"PositionY"];
        if (positionYs.count > 0) {
            GDataXMLElement *positionYNode = (GDataXMLElement *) [positionYs objectAtIndex:0];
            monsterData.positionY = [positionYNode.stringValue floatValue];
        }
        
        NSArray *positionXs = [enemyNode elementsForName:@"PositionX"];
        if (positionXs.count > 0) {
            GDataXMLElement *positionXNode = (GDataXMLElement *) [positionXs objectAtIndex:0];
            monsterData.positionX = [positionXNode.stringValue floatValue];
        }
        
        NSArray *health = [enemyNode elementsForName:@"Health"];
        if (health.count > 0) {
            GDataXMLElement *healthNode = (GDataXMLElement *) [health objectAtIndex:0];
            monsterData.health = [healthNode.stringValue floatValue];
        }
        
        NSArray *attack = [enemyNode elementsForName:@"Attack"];
        if (attack.count > 0) {
            GDataXMLElement *attackNode = (GDataXMLElement *) [attack objectAtIndex:0];
            monsterData.attack = [attackNode.stringValue floatValue];
        }
        
        NSArray *speed = [enemyNode elementsForName:@"Speed"];
        if (speed.count > 0) {
            GDataXMLElement *speedNode = (GDataXMLElement *) [speed objectAtIndex:0];
            monsterData.speed = [speedNode.stringValue floatValue];
        }
        
        NSArray *probability = [enemyNode elementsForName:@"Probability"];
        if (speed.count > 0) {
            GDataXMLElement *probabilityNode = (GDataXMLElement *) [probability objectAtIndex:0];
            monsterData.probability = [probabilityNode.stringValue floatValue];
        }
        
        NSArray *isElite = [enemyNode elementsForName:@"IsElite"];
        if (isElite.count > 0) {
            GDataXMLElement *isEliteNode = (GDataXMLElement *) [isElite objectAtIndex:0];
            monsterData.isElite = [isEliteNode.stringValue boolValue];
        }
        
        NSArray *modifierNodes = [enemyNode elementsForName:@"Modifier"];
        if(modifierNodes.count>0){
            for(GDataXMLElement *modifierNode in [modifierNodes[0] children]){
                MonsterDataModifier *modifier = [[MonsterDataModifier alloc] init];
                modifier.name = [self lowercaseFirstLetter:modifierNode.name];
                for(GDataXMLElement *modifierParameter in [modifierNode children]){
                    [modifier setValue:[NSNumber numberWithFloat:modifierParameter.stringValue.floatValue] forKey:[self lowercaseFirstLetter:modifierParameter.name]];
                }
                [monsterData.modifiers addObject:modifier];
            }
        }
        
        
        [monsterDataList addObject:monsterData];
    }
    
    // load (tutorial) events
    NSArray *eventNodes = [doc nodesForXPath:@"//LevelData/EventData/Event" error:nil];
    for (GDataXMLElement *eventNode in eventNodes) {
        [TutorialManager createTutorial:eventNode.stringValue withMonsterList:self];
    }
    
    
    return totalNumOfEmeny;
}

- (NSString*)lowercaseFirstLetter:(NSString*)str{
    return [[[str substringToIndex:1] lowercaseString] stringByAppendingString:[str substringFromIndex:1]];
}

@end
