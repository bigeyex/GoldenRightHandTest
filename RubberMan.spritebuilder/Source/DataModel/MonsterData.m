//
//  MonsterData.m
//  RubberMan
//
//  Created by Wang Yu on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MonsterData.h"
#import "Monster.h"

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
        self.elementType = 0;
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
    if(self.number > 0){
        return YES;
    }
    else{
        return NO;
    }
}

- (Monster*)respawn{
    self.number--;
    nextRespawnTime += self.respawnInterval;
    
    Monster *monster = (Monster*)[CCBReader load: [NSString stringWithFormat:@"Monsters/%@", self.spriteName]];
    monster.positionType = CCPositionTypeNormalized;
    monster.position = ccp(self.positionX, self.positionY);
    monster.elementType = self.elementType;
    return monster;
}

@end
