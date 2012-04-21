//
//  ColorGridView.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelTool.h"
#import "PixelDrawing.h"

@interface ColorGridView : UIView
{
    PixelDrawing * drawing;
    
    int highlightedColorIndex;
}

@property (nonatomic, assign) PixelDrawing * drawing;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
