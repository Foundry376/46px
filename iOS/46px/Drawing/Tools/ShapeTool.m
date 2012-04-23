//
//  ShapeTool.m
//  46px
//
//  Created by Grayson Carroll on 4/21/12.
//  Copyright (c) 2012 Belmont University. All rights reserved.
//

#import "ShapeTool.h"

@implementation ShapeTool

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
    [self drawToolOverlayInContext:c withDrawing:d];
    CGContextClearRect(c, CGRectMake(0, 0, d.size.width, d.size.height));
        
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

- (void)drawToolOverlayInContext:(CGContextRef)context withDrawing:(PixelDrawing *)d
{
    //for subclasses to implement
}
-(void)drawToolOverlayInContext
{
    //for subclasses to implement 
    //this is called during the 
}
@end
