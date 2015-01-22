//
//  LevelClearScreenStar.m
//  RubberMan
//
//  Created by Wang Yu on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelClearScreenStar.h"

@implementation LevelClearScreenStar{
    CCSprite* star;
}

- (void)didLoadFromCCB{
    self.visible = NO;
}

- (void)displayStar{
    self.visible = YES;
    [self.animationManager runAnimationsForSequenceNamed:@"default"];
}

@end
