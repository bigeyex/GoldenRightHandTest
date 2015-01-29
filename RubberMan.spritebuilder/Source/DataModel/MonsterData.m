//
//  MonsterData.m
//  RubberMan
//
//  Created by Wang Yu on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MonsterData.h"
#import "Monster.h"
#include <stdlib.h>

@implementation MonsterData{
    CGFloat nextRespawnTime;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.enterTime = 0;
        self.respawnInterval = 1;
        self.number = 1;
        self.positionX = 1;
        self.positionY = 0.3;
        self.health = 10;
        self.speed = 0;
        self.modifiers = [NSMutableArray array];
        nextRespawnTime = 0;
    }
    return self;
}

- (id)initWithSpriteName: (NSString*) spriteName
{
    self = [self init];
    if(self)
    {
        self.spriteName = spriteName;
    }
    return self;
}

+ (id)fromSpriteName:(NSString *)spriteName{
    return [[self alloc] initWithSpriteName:spriteName];
}

- (BOOL)shouldRespawn: (CGFloat)timeSinceGameStarted{
    if(nextRespawnTime == 0){
        nextRespawnTime = self.enterTime;
    }
    if(self.number <= 0){
        return NO;
    }
    if(timeSinceGameStarted > nextRespawnTime){
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)hasNextUnit{
    if(self.number > 0 || self.number == -1){
        return YES;
    }
    else{
        return NO;
    }
}

- (Monster*)respawn{
    if(self.number != -1){
        self.number--;
    }
    for (MonsterDataModifier *modifier in self.modifiers) {
        [modifier runModifierForMonsterData:self];
    }
    nextRespawnTime += self.respawnInterval;
    
    Monster *monster = (Monster*)[CCBReader load: [NSString stringWithFormat:@"Monsters/%@", self.spriteName]];
    monster.positionType = CCPositionTypeNormalized;
    monster.position = ccp(self.positionX, self.positionY);
    monster.isElite = self.isElite;
    monster.hp = self.health;
    return monster;
}

@end

@implementation MonsterDataModifier{
    float baseValue;
    BOOL hasBaseValue;
}

float const nullValue = -365.0;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.delta = 0;
        self.minValue = nullValue;
        self.maxValue = nullValue;
        hasBaseValue = NO;
    }
    return self;
}

- (CGFloat)newValueFromLast:(CGFloat)lastValue{
    if(!hasBaseValue){
        baseValue = lastValue;
        hasBaseValue = YES;
    }
    baseValue += self.delta;
    if(self.variation != nullValue){
        baseValue -= self.variation/2;
        baseValue += (float)(arc4random() % 200)*self.variation/200.0;
    }
    
    if(self.minValue!=nullValue && baseValue <= self.minValue){
        baseValue = self.minValue;
    }
    else if(self.maxValue!=nullValue &&baseValue >= self.maxValue){
        baseValue = self.maxValue;
    }
    return baseValue;
}

- (void)runModifierForMonsterData:monsterData{
    [monsterData setValue:[NSNumber numberWithFloat:
                           [self newValueFromLast:[[monsterData valueForKey:self.name] floatValue]]]
                 forKey:self.name];
}

@end
