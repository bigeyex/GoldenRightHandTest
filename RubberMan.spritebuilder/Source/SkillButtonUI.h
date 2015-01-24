//
//  SkillButton.h
//  RubberMan
//
//  Created by Guoqiang XU on 1/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface SkillButtonUI : CCNode

@property (nonatomic,assign) NSString *upperElement;
@property (nonatomic,assign) NSString *lowerLeftElement;
@property (nonatomic,assign) NSString *lowerRightElement;

-(void)resetElement;

@end
