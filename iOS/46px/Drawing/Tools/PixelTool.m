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

- (void)touchBegan:(TouchProperties*)touch inDrawing:(PixelDrawing*)d
{
    down = YES;
}

- (void)touchMoved:(TouchProperties*)touch inDrawing:(PixelDrawing*)d
{
    // modify the operation's changeRect
}

- (void)touchEnded:(TouchProperties*)touch inDrawing:(PixelDrawing*)d
{
    if (down) {
        // expand the changeRegion a bit to account for the fact that rounding
        // occasionally causes edits to unintentional pixels
        CGRect r = [operation changeRegion];
        r.origin.x = fmaxf(0, floorf(r.origin.x - 1));
        r.origin.y = fmaxf(0, floorf(r.origin.y - 1));
        r.size.width = fminf(ceilf([d size].width - r.origin.x), ceilf(r.size.width + 2));
        r.size.height = fminf(ceilf([d size].height - r.origin.y), ceilf(r.size.height + 2));
        [operation setChangeRegion: r];
        
        [d applyOperation: operation];
        down = NO;
    }
}

- (void)cancel:(PixelDrawing*)d
{
    CGContextClearRect(CGLayerGetContext([d operationLayer]), CGRectMake(0, 0, [d size].width, [d size].height));
    down = NO;
}

- (BOOL)down
{
    return down;
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
