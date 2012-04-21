//
//  PixelTool.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelTool.h"
#import "PixelDrawing.h"

@implementation PixelTool

- (void)touchBegan:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
}

- (void)touchMoved:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    // modify the operation's changeRect
}

- (void)touchEnded:(TouchProperties)touch inDrawing:(PixelDrawing*)d
{
    // expand the changeRegion a bit to account for the fact that rounding
    // occasionally causes edits to unintentional pixels
    CGRect r = [operation changeRegion];
    r.origin.x = fmaxf(0, r.origin.x - 1);
    r.origin.y = fmaxf(0, r.origin.y - 1);
    r.size.width = fminf([d size].width - r.origin.x, r.size.width + 2);
    r.size.height = fminf([d size].height - r.origin.y, r.size.height + 2);
    [operation setChangeRegion: r];
    
    [d applyOperation: operation];
}

- (UIImage*)icon
{
    return [UIImage imageNamed:@"tool-default.png"];
}

- (void)drawInContext:(CGContextRef)c
{
    // default implementation does nothing. Override to overlay cool shit
    // on the drawing canvas.
}

@end
