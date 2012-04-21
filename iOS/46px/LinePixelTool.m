//
//  LinePixelTool.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinePixelTool.h"

@implementation LinePixelTool

- (void)touchBegan:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    [super touchBegan: touch inDrawing: d];
    
    operation = [[PixelEditOperation alloc] init];
    
    CGLayerRef l = [d operationLayer];
    CGContextRef c = CGLayerGetContext(l);
    CGContextClearRect(c, CGRectMake(0, 0, d.size.width, d.size.height));
    
    start = touch;
    end = touch;
    [operation setChangeRegion: CGRectMake(touch.pixelInView.x, touch.pixelInView.y, 1, 1)];
}

- (void)touchMoved:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    end = touch;
    
    CGLayerRef l = [d operationLayer];
    CGContextRef c = CGLayerGetContext(l);
    
    CGContextClearRect(c, CGRectMake(0, 0, d.size.width, d.size.height));
    CGContextMoveToPoint(c, start.pixelInView.x, start.pixelInView.y);
    CGContextAddLineToPoint(c, end.pixelInView.x, end.pixelInView.y);
    CGContextSetStrokeColorWithColor(c, [d.color CGColor]);
    CGContextStrokePath(c);

    [super touchMoved: touch inDrawing: d];
}

- (void)touchEnded:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    end = touch;
    
    CGLayerRef l = [d operationLayer];
    CGContextRef c = CGLayerGetContext(l);
    
    CGContextClearRect(c, CGRectMake(0, 0, d.size.width, d.size.height));
    CGContextMoveToPoint(c, start.pixelInView.x, start.pixelInView.y);
    CGContextAddLineToPoint(c, touch.pixelInView.x, touch.pixelInView.y);
    CGContextSetStrokeColorWithColor(c, [d.color CGColor]);
    CGContextStrokePath(c);
    
    CGRect startRect = CGRectMake(start.pixelInView.x, start.pixelInView.y, 1, 1);
    CGRect endRect = CGRectMake(touch.pixelInView.x, touch.pixelInView.y, 1, 1); 
    CGRect drawnRect = CGRectUnion(startRect, endRect);
    
    [operation setChangeRegion: CGRectUnion([operation changeRegion], drawnRect)];
    [super touchEnded: touch inDrawing: d];
}

- (UIImage*)icon
{
    return [UIImage imageNamed:@"tool-line.png"];
}

- (void)drawInContext:(CGContextRef)c
{
    CGContextMoveToPoint(c, start.locationInView.x, start.locationInView.y);
    CGContextAddLineToPoint(c, end.locationInView.x, end.locationInView.y);
    CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
    CGContextStrokePath(c);
}

@end
