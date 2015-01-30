//
//  BasicTutorial.h
//  RubberMan
//
//  Created by Wang Yu on 1/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tutorial : NSObject

+ (void)setUp;
- (void)showTutorialScreen:(NSString*)screenName afterDelay:(float)delay;

@end
