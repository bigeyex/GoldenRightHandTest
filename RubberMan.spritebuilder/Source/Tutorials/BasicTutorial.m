//
//  BasicTutorial.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicTutorial.h"
#import "GameEvent.h"

float const secondsBeforeFirstTutorial=1;

@implementation BasicTutorial

+ (void)setUp{
    if(![[self alloc] init]){
        NSLog(@"Failed to init event");
    }
}

- (id)init{
    self = [super init];
    if (self)
    {
        [self showTutorialScreen:@"Tutorial/tutorial1" afterDelay:secondsBeforeFirstTutorial];

        
    }
    return self;
}


@end
