#import "MainScene.h"

@implementation MainScene

-(void) start{
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene];
}

@end
