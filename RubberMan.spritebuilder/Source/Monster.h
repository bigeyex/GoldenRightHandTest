//
//  Monster.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
@class MonsterData;

@interface Monster : CCSprite

- (void)loadMonsterData: (MonsterData*)monsterData;

@end
