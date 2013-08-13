//
//  ColorGridView.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorGridView.h"

#define COLOR_CELL_SIZE 42
#define COLOR_CELL_PADDING 6

@implementation ColorGridView

@synthesize drawing;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self){
        highlightedColorIndex = NSNotFound;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    // need to redraw after an orientation / frame size change to re-layout squares
    [super setFrame: frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGRect r = CGRectMake(COLOR_CELL_PADDING, COLOR_CELL_PADDING, COLOR_CELL_SIZE, COLOR_CELL_SIZE);
    
    if (!drawing)
        return;
        
    // draw all of the color squares—do something special for the selected one.
    for (int ii = 0; ii < drawing.colors.count; ii++) {
        UIColor * cc = [drawing.colors objectAtIndex: ii];

        if (highlightedColorIndex == ii) {
            CGContextSetRGBStrokeColor(c, 0, 0, 1, 0.5);
            CGContextSetLineWidth(c, 4);            
        } else if (cc == drawing.color) {
            CGContextSetRGBStrokeColor(c, 0, 0, 1, 1);
            CGContextSetLineWidth(c, 4);
        } else {
            CGContextSetRGBStrokeColor(c, 0, 0, 0, 0.6);
            CGContextSetLineWidth(c, 1);
        }
        
        CGContextSetFillColorWithColor(c, [cc CGColor]);
        CGContextFillRect(c, r);
        CGContextStrokeRect(c, r);
        
        if (highlightedColorIndex == ii) {
            CGContextSetRGBFillColor(c, 1, 1, 1, 0.4);
            CGContextFillRect(c, r);
        }
        
        if (rect.size.height > rect.size.width) {
            r.origin.x += r.size.width + COLOR_CELL_PADDING;
            if (r.origin.x + r.size.width > rect.size.width) {
                r.origin.x = COLOR_CELL_PADDING;
                r.origin.y += r.size.height + COLOR_CELL_PADDING;
            }
        } else {
            r.origin.y += r.size.height + COLOR_CELL_PADDING;
            if (r.origin.y + r.size.height > rect.size.height) {
                r.origin.y = COLOR_CELL_PADDING;
                r.origin.x += r.size.width + COLOR_CELL_PADDING;
            }
        }
    }
}

- (void)updateHighlightedSquare:(CGPoint)p
{
    int hx = floor(p.x / (COLOR_CELL_SIZE + COLOR_CELL_PADDING));
    int hy = floor(p.y / (COLOR_CELL_SIZE + COLOR_CELL_PADDING));
    if (self.bounds.size.height > self.bounds.size.width)
        highlightedColorIndex = hy * roundf(self.bounds.size.width / (COLOR_CELL_SIZE + COLOR_CELL_PADDING)) + hx;
    else
        highlightedColorIndex = hx * roundf(self.bounds.size.height / (COLOR_CELL_SIZE + COLOR_CELL_PADDING)) + hy;
    
    if ((highlightedColorIndex < 0) || (highlightedColorIndex >= [drawing.colors count]))
        highlightedColorIndex = NSNotFound;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView: self];
    [self updateHighlightedSquare: p];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView: self];
    [self updateHighlightedSquare: p];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView: self];
    [self updateHighlightedSquare: p];
    
    if (highlightedColorIndex != NSNotFound)
        [drawing setColor: [[drawing colors] objectAtIndex: highlightedColorIndex]];
    highlightedColorIndex = NSNotFound;
    
    [self setNeedsDisplay];
}


@end
