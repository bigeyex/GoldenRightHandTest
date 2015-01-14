//
//  Hand.m
//  RubberMan
//
//  Created by Guoqiang XU on 1/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hand.h"

@implementation Hand

-(void)didLoadFromCCB{
    // set up collision type
    self.physicsBody.collisionType = @"hand";
}

@end
