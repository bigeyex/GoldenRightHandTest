//
//  GameEvent.h
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameEvent : NSObject

+ (void)subscribe:(NSString*)eventName forObject:(id) object withSelector:(SEL) selector;

+ (void)reset;

+ (void)clearEvent:(NSString*) eventName;

+ (void)unsubscribe:(NSString*)eventName forObject:(id) object withSelector:(SEL) selector;

+ (void)dispatch: (NSString*)eventName;

+ (void)dispatch: (NSString*)eventName withArgument:(id)argument;


@end
