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
    PixelDrawing * __weak drawing;
    
    int highlightedColorIndex;
}

@property (nonatomic, weak) PixelDrawing * drawing;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end
