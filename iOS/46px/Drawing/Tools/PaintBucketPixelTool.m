//
//  PaintBucketPixelTool.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintBucketPixelTool.h"
#import "CGHelpers.h"

@implementation PaintBucketPixelTool


- (void)touchBegan:(TouchProperties*)touch inDrawing:(PixelDrawing*)d
{
    operation = [[PixelEditOperation alloc] init];
    
    [super touchBegan: touch inDrawing: d];
}

- (void)touchMoved:(TouchProperties*)touch inDrawing:(PixelDrawing*)d
{
    [super touchMoved: touch inDrawing: d];
}

- (void)touchEnded:(TouchProperties*)touch inDrawing:(PixelDrawing*)d
{
    // alright—here's what we need to do. We want to do a breadth-first search
    // from the start pixel out to all the same-colored pixels. To explore the pixels,
    // we need to get the image into RGBA data.
    CGRect r = CGRectMake(0, 0, d.size.width, d.size.height);
    CGPoint p = touch.pixelInView;

    int outPixelsLength = d.size.width * d.size.height;
    
    UIImage * i = UIImageFromLayer(d.baseLayer, CGRectMake(0, 0, d.size.width, d.size.height), YES);
    RGBAPixel * pixels = (RGBAPixel *)[CGImageGetData([i CGImage], r) bytes];
    RGBAPixel * outPixels = calloc(outPixelsLength, sizeof(RGBAPixel));
    BOOL * visited = calloc(outPixelsLength, sizeof(BOOL));
    
    p.x = roundf(p.x);
    p.y = roundf(d.size.height - p.y);
    [self traversePoint: p pixels:pixels visited: visited output: outPixels inDrawing: d];
    free(visited);
    
    NSData * outData = [NSData dataWithBytesNoCopy:outPixels length:outPixelsLength * sizeof(RGBAPixel) freeWhenDone:YES];
    CGImageRef result = CGImageCreateFromData(outData, d.size);
    
    CGContextRef oc = CGLayerGetContext(d.operationLayer);
    CGContextDrawImage(oc, r, result);
    CGImageRelease(result);
    
    [operation setChangeRegion: r];
    [super touchEnded: touch inDrawing: d];
}

- (void)traversePoint:(CGPoint)p pixels:(RGBAPixel *)pixels visited:(BOOL*)visited output:(RGBAPixel *)output inDrawing:(PixelDrawing*)d
{
    CGSize s = d.size;
    const float * components = CGColorGetComponents([[d color] CGColor]);
    RGBAPixel painted = {(int)(components[0] * 255), (int)(components[1] * 255), (int)(components[2] * 255), (int)(components[3] * 255)};
    RGBAPixel current = pixels[(int)(p.y * s.width + p.x)];
    
    output[(int)((int)p.y * s.width + p.x)] = painted;
    visited[(int)((int)p.y * s.width + p.x)] = YES;
    
    // look at neighboring points—should we fill them?
    for (int x = fmaxf(0, p.x - 1); x <= fminf(p.x + 1, s.width - 1); x++) {
        for (int y = fmaxf(0, p.y - 1); y <= fminf(p.y + 1, s.height - 1); y++){
            if ((x == (int)p.x) && (y == (int)p.y))
                continue;
            if ((x != (int)p.x) && (y != (int)p.y))
                continue;
                
            int ii = (int)(y * s.width + x);
            RGBAPixel t = pixels[ii];
            
            BOOL sameColor = ((t.r == current.r) && (t.g == current.g) && (t.b == current.b) && (t.a == current.a));
            BOOL sameEmptiness = ((t.a == 0) && (current.a == 0));
            
            if ((sameEmptiness || sameColor) && (visited[ii] == NO))
                [self traversePoint:CGPointMake(x, y) pixels:pixels visited: visited output:output inDrawing:d];
            
            visited[ii] = YES;
        }
    }
}

- (UIImage*)icon
{
    return [UIImage imageNamed:@"tool-paintbucket.png"];
}

- (void)drawInContext:(CGContextRef)c
{
}


@end
