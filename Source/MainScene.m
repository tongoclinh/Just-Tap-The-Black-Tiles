//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@interface MainScene() {
    CGPoint triggerPoint;
    CCNodeColor *tiles[5];
    int lastTile;
    int widthUnit;
    int heightUnit;
    CGFloat totalTime;
}

@end

@implementation MainScene

- (void)didLoadFromCCB
{
    for (int row = 0; row < 5; row++) {
        tiles[row] = [self createBlackTileAtRow:row AndCol:arc4random_uniform(4)];
    }
    lastTile = 0;
}

- (CCNodeColor *)createBlackTileAtRow:(int)row AndCol:(int)col
{
    
    widthUnit = [[CCDirector sharedDirector] viewSize].width / 4;
    heightUnit = [[CCDirector sharedDirector] viewSize].height / 4;
    CCNodeColor *tile = [CCNodeColor nodeWithColor:[CCColor blackColor] width:widthUnit height:heightUnit];
    [tile setPosition:ccp(widthUnit * col, heightUnit * row)];
    [tile setAnchorPoint:ccp(0, 0)];
    [self addChild:tile];
    [self moveTile:tile];
    return tile;
}

- (void)moveTile:(CCNodeColor *)tile
{
    CGPoint destination = ccp([tile position].x, -heightUnit);
    CGFloat distance = ccpDistance([tile position], destination);
    CGFloat speed = 200;
    CGFloat duration = distance / speed;
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:duration position:ccp([tile position].x, -heightUnit)];
    CCActionCallBlock *complete = [CCActionCallBlock actionWithBlock:^{
        [[CCDirector sharedDirector] pause];
        [tile setPosition:ccp(widthUnit * arc4random_uniform(4), heightUnit * 4)];
        [self performSelector:@selector(moveTile:) withObject:tile];
//        [tile removeFromParentAndCleanup:YES];
    }];
    CCActionSequence *sequence = [CCActionSequence actions:move, complete, nil];
    CCActionSpeed *moveSpeed = [CCActionSpeed actionWithAction:sequence speed:1];
    [moveSpeed setTag:474747];
    [tile runAction:moveSpeed];
    [[CCDirector sharedDirector]resume];
}

- (void)update:(CCTime)delta
{
    totalTime += delta;
    for (int i = 0; i < 5; i++) {
        CCActionSpeed * action = (CCActionSpeed *)[tiles[i] getActionByTag:474747];
        [action setSpeed:1 + totalTime / 20];
    }
}

@end
