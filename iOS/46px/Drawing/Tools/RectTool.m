//
//  EllipseTool.m
//  46px
//
//  Created by Grayson Carroll on 4/21/12.
//  Copyright (c) 2012 Belmont University. All rights reserved.
//

#import "RectTool.h"

@implementation RectTool


- (UIImage*)icon
{
    return [UIImage imageNamed:@"tool-rect.png"];
}

- (void)drawShapeInContext:(CGContextRef)c withDrawing:(PixelDrawing *)d
{
    CGContextSetStrokeColorWithColor(c, [d.color CGColor]);
    CGContextStrokeRect(c, CGRectMake(start.pixelInView.x, start.pixelInView.y, end.pixelInView.x - start.pixelInView.x, end.pixelInView.y - start.pixelInView.y));
}

- (void)drawInContext:(CGContextRef)c
{
    CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
    CGContextStrokeRect(c, CGRectMake(start.locationInView.x, start.locationInView.y, end.locationInView.x - start.locationInView.x, end.locationInView.y - start.locationInView.y));
}


@end
