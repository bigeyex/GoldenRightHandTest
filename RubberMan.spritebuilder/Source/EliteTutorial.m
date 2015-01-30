//
//  EliteTutorial.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "EliteTutorial.h"
#import "GameEvent.h"

float const secondsBeforeFourthTutorial=1;

@implementation EliteTutorial

+ (void)setUp{
    if(![[self alloc] init]){
        NSLog(@"Failed to init event");
    }
}

- (id)init{
    self = [super init];
    if (self)
    {
        [self showTutorialScreen:@"Tutorial/tutorial4" afterDelay:secondsBeforeFourthTutorial];
        
    }
    return self;
}

@end
