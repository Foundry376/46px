//
//  EllipseTool.h
//  46px
//
//  Created by Grayson Carroll on 4/21/12.
//  Copyright (c) 2012 Belmont University. All rights reserved.
//

#import "PixelTool.h"

@interface ShapeTool : PixelTool
{
    TouchProperties start;
    TouchProperties end;
}

-(void)drawToolOverlayInContext:(CGContextRef)context withDrawing:(PixelDrawing*)d;
@end
