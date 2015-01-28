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

+ (void)reset{
    eventList = [NSMutableDictionary dictionary];
}

+ (void)clearEvent:(NSString*) eventName{
    [eventList removeObjectForKey:eventName];
}

+ (void)unsubscribe:(NSString*)eventName forObject:(id) object withSelector:(SEL) selector{
    if(eventList==nil){
        return;
    }
    
    NSMutableArray* subscriberList = [eventList valueForKey:eventName];
    if(subscriberList==nil){
        return;
    }
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    for(NSArray *pair in subscriberList){
        SEL candidateSelector = NSSelectorFromString(pair[1]);
        id subscriber = pair[0];
        if(object==subscriber && selector==candidateSelector){
            [discardedItems addObject:pair];
        }
    }
    [subscriberList removeObjectsInArray:discardedItems];
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
