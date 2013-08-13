//
//  PixelTool.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixelEditOperation.h"
#import "PixelCanvasView.h"

@class PixelDrawing;

@interface PixelTool : NSObject
{
    PixelEditOperation * operation;
    BOOL down;
}

- (void)touchBegan:(TouchProperties*)touch inDrawing:(PixelDrawing*)d;
- (void)touchMoved:(TouchProperties*)touch inDrawing:(PixelDrawing*)d;
- (void)touchEnded:(TouchProperties*)touch inDrawing:(PixelDrawing*)d;

- (void)drawInContext:(CGContextRef)c;

- (void)cancel:(PixelDrawing*)d;
- (BOOL)down;
- (UIImage*)icon;

@end
