//
//  PenPixelTool.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PenPixelTool.h"

@implementation PenPixelTool

- (void)touchBegan:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    [super touchBegan: touch inDrawing: d];
    
    operation = [[PixelEditOperation alloc] init];
    
    CGLayerRef l = [d operationLayer];
    CGContextRef c = CGLayerGetContext(l);
    
    CGRect pixelRect = CGRectMake(touch.pixelInView.x, touch.pixelInView.y, 1, 1);
    CGContextFillRect(c, pixelRect);
    
    [operation setChangeRegion: pixelRect];
}

- (void)touchMoved:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    [super touchMoved: touch inDrawing: d];
    
    CGLayerRef l = [d operationLayer];
    CGContextRef c = CGLayerGetContext(l);
    
    CGContextMoveToPoint(c, touch.prevPixelInView.x, touch.prevPixelInView.y);
    CGContextAddLineToPoint(c, touch.pixelInView.x, touch.pixelInView.y);
    CGContextStrokePath(c);
    
    CGRect startRect = CGRectMake(touch.prevPixelInView.x, touch.prevPixelInView.y, 1, 1);
    CGRect endRect = CGRectMake(touch.pixelInView.x, touch.pixelInView.y, 1, 1); 
    CGRect drawnRect = CGRectUnion(startRect, endRect);
    
    [operation setChangeRegion: CGRectUnion([operation changeRegion], drawnRect)];
}

- (void)touchEnded:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    [super touchEnded: touch inDrawing: d];
}


@end
