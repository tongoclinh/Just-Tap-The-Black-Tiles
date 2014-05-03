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
    int highestTile;
    CGFloat totalTime;
    int counter;
    BOOL needUpdate;
}

@end

@implementation MainScene

- (void)didLoadFromCCB
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:tapRecognizer];
    for (int row = 0; row < 5; row++) {
        tiles[row] = [self createBlackTileAtRow:row AndCol:arc4random_uniform(4)];
    }
//    [self moveTile:tiles[0]];
    lastTile = 0;
    counter = 4;
    needUpdate = NO;
}

- (CCNodeColor *)createBlackTileAtRow:(int)row AndCol:(int)col
{
    
    widthUnit = [[CCDirector sharedDirector] viewSize].width / 4.0;
    heightUnit = [[CCDirector sharedDirector] viewSize].height / 4.0;
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
        [tile setPosition:ccp(widthUnit * arc4random_uniform(4), tiles[counter].position.y + heightUnit)];
        [tile setColor:[CCColor blackColor]];
        [self performSelector:@selector(moveTile:) withObject:tile];
        counter = (counter + 1) % 5;
        lastTile = (lastTile + 1) % 5;
        needUpdate = YES;
    }];
    CCActionSequence *sequence = [CCActionSequence actions:move, complete, nil];
    CCActionSpeed *moveSpeed = [CCActionSpeed actionWithAction:sequence speed:1];
    [moveSpeed setTag:474747];
    [tile runAction:moveSpeed];

}

- (void)syncPosition
{
    int lowest = 10000000, lowestIndex;
    for (int i = 0; i < 5; i++) {
        if ([tiles[i] position].y < lowest) {
            lowest = [tiles[i] position].y;
            lowestIndex = i;
        }
    }
    for (int i = 0; i < 5; i++) {
        int index = (lowestIndex + i) % 5;
        [tiles[index] setPosition:ccp([tiles[index] position].x, [tiles[lowestIndex] position].y + i * heightUnit)];
    }
}

- (void)update:(CCTime)delta
{
    totalTime += delta;
    for (int i = 0; i < 5; i++) {
        CCActionSpeed * action = (CCActionSpeed *)[tiles[i] getActionByTag:474747];
        [action setSpeed:1 + totalTime / 20];
    }
    
    if (!needUpdate)
        return;
    [self syncPosition];
    needUpdate = NO;
}

- (void)runAnimationOnTile:(CCNodeColor *)tile
{
    CCNodeColor *overlay = [CCNodeColor nodeWithColor:[CCColor grayColor] width:1 height:1];
    [overlay setScale:0.1];
    [overlay setContentSizeType:CCSizeTypeNormalized];
    [overlay setPosition:ccp(0.5, 0.5)];
    [overlay setPositionType:CCPositionTypeNormalized];
    [overlay setAnchorPoint:ccp(0.5, 0.5)];
    [tile addChild:overlay];
    CCActionScaleTo *scale = [CCActionScaleTo actionWithDuration:0.1 scale:1];
    CCActionCallBlock *cleanup = [CCActionCallBlock actionWithBlock:^{
        [tile setColor:[CCColor grayColor]];
        [overlay removeFromParentAndCleanup:YES];
    }];
    [overlay runAction:[CCActionSequence actions:scale, cleanup, nil]];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
//    CCLOG(@"Tapped");
    CGPoint tapPoint = [tap locationInView:tap.view];
    tapPoint.y = [[CCDirector sharedDirector] viewSize].height - tapPoint.y;
    for (int i = 0; i < 5; i++) {
        if (CGRectContainsPoint([tiles[i] boundingBox], tapPoint)) {
            CCLOG(@"%@", NSStringFromCGRect([tiles[i] boundingBox]));
            [self runAnimationOnTile:tiles[i]];
        }
    }
    CCLOG(@"%f, %f", tapPoint.x, tapPoint.y);
}

@end
