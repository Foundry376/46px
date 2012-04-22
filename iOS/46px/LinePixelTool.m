//
//  LinePixelTool.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinePixelTool.h"

@implementation LinePixelTool

- (UIImage*)icon
{
    return [UIImage imageNamed:@"tool-line.png"];
}

-(void)drawToolOverlayInContext:(CGContextRef)c withDrawing:(PixelDrawing *)d
{
    CGContextMoveToPoint(c, start.pixelInView.x, start.pixelInView.y);
    CGContextAddLineToPoint(c, end.pixelInView.x, end.pixelInView.y);
    CGContextSetStrokeColorWithColor(c, [d.color CGColor]);
}

- (void)drawInContext:(CGContextRef)c
{
    CGContextMoveToPoint(c, start.locationInView.x, start.locationInView.y);
    CGContextAddLineToPoint(c, end.locationInView.x, end.locationInView.y);
    CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
    CGContextStrokePath(c);
}

@end
