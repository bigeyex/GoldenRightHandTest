//
//  GameEvent.m
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameEvent.h"

@implementation GameEvent

static NSMutableDictionary* eventList;

+ (void)subscribe:(NSString*)eventName forObject:(id) object withSelector:(SEL) selector{
    if(eventList==nil){
        eventList = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray* subscriberList = [eventList valueForKey:eventName];
    if(subscriberList==nil){
        subscriberList = [NSMutableArray array];
        [eventList setValue:subscriberList forKey:eventName];
    }
    
    [subscriberList addObject:@[object, NSStringFromSelector(selector)]];
}

+ (void)dispatch: (NSString*)eventName{
    [self dispatch:eventName withArgument:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (void)dispatch: (NSString*)eventName withArgument:(id)argument{
    NSMutableArray* subscriberList = [eventList valueForKey:eventName];
    if(subscriberList != nil){
        for(NSArray *pair in subscriberList){
            SEL selector = NSSelectorFromString(pair[1]);
            [pair[0] performSelector:selector withObject:argument];
        }
    }
}

#pragma clang diagnostic pop

@end
