//
//  EllipseTool.h
//  46px
//
//  Created by Grayson Carroll on 4/21/12.
//  Copyright (c) 2012 Belmont University. All rights reserved.
//

#import "ShapeTool.h"

@interface RectTool : ShapeTool


- (UIImage*)icon;
- (void)drawShapeInContext:(CGContextRef)context withDrawing:(PixelDrawing *)d;

@end
