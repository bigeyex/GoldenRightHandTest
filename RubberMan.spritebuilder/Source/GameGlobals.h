//
//  GameGlobals.h
//  RubberMan
//
//  Created by Wang Yu on 1/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameGlobals : NSObject

@property (readonly) int totalNumberOfLevels;
@property (nonatomic) NSArray* levelNames;

+ (id)sharedInstance;
- (void)setLevelNames:(NSArray *)levelNames;
- (NSString*)levelNameAtIndex:(int)index;

@end
