//
//  UIScoreBoard.h
//  RubberMan
//
//  Created by Wang Yu on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface UIScoreBoard : CCSprite

- (void)giveStarForReason: (NSString*)reason;
- (void)displayStars;
- (void)reset;

@end
