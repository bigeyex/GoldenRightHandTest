//
//  UIScoreBoard.m
//  RubberMan
//
//  Created by Wang Yu on 1/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "UIScoreBoard.h"
#import "LevelClearScreenStar.h"

float const secondsBetweenStarAppearence = 0.5;

@implementation UIScoreBoard{
    CCLabelTTF *uiText;
    CCNode *uiStars;
    int starIndex;
    
    NSMutableArray *starReasonList;
}

- (void)didLoadFromCCB{
    starReasonList = [NSMutableArray arrayWithCapacity:3];
    starIndex = 0;
}

- (int)numberOfStars{
    return starReasonList.count;
}


- (void)reset{
    starIndex = 0;
    starReasonList = [NSMutableArray arrayWithCapacity:3];
}

- (void)giveStarForReason: (NSString*)reason{
    [starReasonList addObject:reason];
}

- (void)displayStars{
    for(int i=0;i<starReasonList.count;i++){
        [self performSelector:@selector(displaySingleStar) withObject:nil afterDelay:secondsBetweenStarAppearence * i];
    }
}

- (void)displaySingleStar{
    if(starReasonList.count<=starIndex || [[uiStars children] count]<=starIndex){
        [NSException raise:@"Out of Star Capacity" format:@"You give stars out of scoreboard capacity"];
    }
    [uiText setString:[starReasonList objectAtIndex:starIndex]];
    LevelClearScreenStar *star = [[uiStars children] objectAtIndex:starIndex];
    [star displayStar];
    starIndex++;
}

@end
