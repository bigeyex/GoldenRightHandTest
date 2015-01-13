#import "MainScene.h"

@implementation MainScene{
    CCPhysicsNode *_physicsNode;
}

- (void)didLoadFromCCB {
    _physicsNode.debugDraw = FALSE;
}

@end
