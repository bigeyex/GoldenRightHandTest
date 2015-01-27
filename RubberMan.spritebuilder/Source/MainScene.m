#import "MainScene.h"

@implementation MainScene

-(void)didLoadFromCCB{
    // preload sound effects
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"normalFist.mp3"];
    [audio preloadEffect:@"fireFist.mp3"];
    [audio preloadEffect:@"fireSpell.mp3"];
    [audio preloadEffect:@"heal.ogg"];
    [audio preloadEffect:@"iceFist2.mp3"];
    [audio preloadEffect:@"iceSpell.mp3"];
    [audio preloadEffect:@"buff.ogg"];
    [audio preloadEffect:@"deathFist2.mp3"];
    //[audio preloadEffect:@"darkFist.mp3"];
}

-(void) start{
    CCScene *levelSelectScene = [CCBReader loadAsScene:@"LevelSelectScene"];
    [[CCDirector sharedDirector] replaceScene:levelSelectScene];
}

@end
