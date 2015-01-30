//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BombSausageTutorial.h"
#import "GameEvent.h"

float const secondsBeforeSecondTutorial=1;

@implementation BombSausageTutorial

+ (void)setUp{
    if(![[self alloc] init]){
        NSLog(@"Failed to init event");
    }
}

- (id)init{
    self = [super init];
    if (self)
    {
        [self showTutorialScreen:@"Tutorial/tutorial3" afterDelay:secondsBeforeSecondTutorial];
        
    }
    return self;
}


@end
