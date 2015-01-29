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
}

- (void)didLoadFromCCB{
    isLevelLoaded = NO;
    [GameEvent subscribe:@"PauseMonsters" forObject:self withSelector:@selector(pauseMonsters)];
    [GameEvent subscribe:@"ResumeMonsters" forObject:self withSelector:@selector(resumeMonsters)];
}

- (void)pauseMonsters{
    self.paused = YES;
}

- (void)resumeMonsters{
    self.paused = NO;
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
            [self addChild:monster];

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
        
        NSArray *isElite = [enemyNode elementsForName:@"IsElite"];
        if (isElite.count > 0) {
            GDataXMLElement *isEliteNode = (GDataXMLElement *) [isElite objectAtIndex:0];
            monsterData.isElite = [isEliteNode.stringValue boolValue];
        }
        
        NSArray *modifierNode = [enemyNode elementsForName:@"Modifier"];
        for(GDataXMLElement *modifierAttribute in modifierNode){
            MonsterDataModifier *modifier = [[MonsterDataModifier alloc] init];
            modifier.name = modifierNode
            for(GDataXMLDocument *modifierParameter in modifierAttribute){
                
            }
        }
        
        [monsterDataList addObject:monsterData];
    }
    
    // load (tutorial) events
    NSArray *eventNodes = [doc nodesForXPath:@"//LevelData/EventData/Event" error:nil];
    for (GDataXMLElement *eventNode in eventNodes) {
        [TutorialManager createTutorial:eventNode.stringValue];
    }
    
    
    return totalNumOfEmeny;
}


@end
