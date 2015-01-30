//
//  GetManaTutorial.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GetManaTutorial.h"
#import "GameEvent.h"

@implementation GetManaTutorial

- (id)init{
    self = [super init];
    if (self)
    {
        [GameEvent subscribe:@"GetMana" forObject:self withSelector:@selector(showTutorialWithMana)];
        
    }
    return self;
}

- (void)showTutorialWithMana{
    
    [self showTutorialScreen:@"Tutorial/tutorial1_2" afterDelay:1.0];
}

@end
