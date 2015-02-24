//
//  GameGlobals.m
//  RubberMan
//
//  Created by Wang Yu on 1/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameGlobals.h"

@implementation GameGlobals

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static GameGlobals *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString*)levelNameAtIndex:(int)index{
    if(self.levelNames.count <= index){
        return nil;
    }
    else{
        return (NSString*)[self.levelNames objectAtIndex:index];
    }
}

- (void)setLevelNames:(NSArray *)levelNames{
    _levelNames = levelNames;
    _totalNumberOfLevels = (int)[levelNames count];
}

- (void)setDatabaseWithName:(NSString *)dbName{
    // initialize the database
    _dbManager = [[DBManager alloc] initWithDatabaseFilename:dbName];
}

- (DBManager *)getDatabase{
    return _dbManager;
}

- (id)init {
    if (self = [super init]) {
        // init shared instance.
    }
    return self;
}



@end
