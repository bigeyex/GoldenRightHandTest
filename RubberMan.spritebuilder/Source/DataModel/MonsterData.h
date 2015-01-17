//
//  MonsterData.h
//  RubberMan
//
//  Created by Wang Yu on 1/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Monster;

@interface MonsterData : NSObject

@property (nonatomic, strong) NSString* spriteName;
@property CGFloat enterTime;
@property CGFloat respawnInterval;
@property int number;
@property CGFloat positionY;
@property CGFloat positionX;
@property int health;
@property int elementType;

+ (id)fromSpriteName: (NSString*) spriteName;
- (id)initWithSpriteName: (NSString*) spriteName;
- (BOOL)shouldRespawn: (CGFloat)timeSinceGameStarted;
- (BOOL)hasNextUnit;
- (Monster*)respawn;


@end
