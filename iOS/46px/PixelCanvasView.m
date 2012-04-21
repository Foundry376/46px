//
//  PixelCanvasView.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelCanvasView.h"
#import "PixelTool.h"

@implementation PixelCanvasView

@synthesize drawing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:@"PixelDrawingChanged" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    if ([drawing layersInitialized] == NO)
        [drawing initializeWithContext: c];
    
    // okay - this is pretty simple. Turn off all that linear interpolation shit
    // that will make our image look blurry
    CGContextSetInterpolationQuality(c, kCGInterpolationNone);
    
    // draw the baseLayer of the drawing
    CGContextDrawLayerInRect(c, [self bounds], drawing.baseLayer);
    CGContextDrawLayerInRect(c, [self bounds], drawing.operationLayer);
    
    // if the view is more than 4x the width of the drawing, draw little hairlines
    // separating each pixel. If the view is small, we don't want that!
    if (self.bounds.size.width > [drawing size].width * 4) {
        // draw little hairlines over each pixel
        CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
        float pixelWidth = [self bounds].size.width / [drawing size].width;
        float pixelHeight = [self bounds].size.height / [drawing size].height;
        
        for (int x = 0; x <= [drawing size].width; x++) {
            CGContextMoveToPoint(c, x * pixelWidth, 0);
            CGContextAddLineToPoint(c, x * pixelWidth, self.bounds.size.height);
            CGContextStrokePath(c);
        }

        for (int y = 0; y <= [drawing size].height; y++) {
            CGContextMoveToPoint(c, 0, y * pixelHeight);
            CGContextAddLineToPoint(c, self.bounds.size.width, y * pixelHeight);
            CGContextStrokePath(c);
        }
    }
    
    // Cool! So we drew the drawing into our view. Now let's draw whatever the 
    // tool needs drawn. This could be anything from a straight line or some sort
    // of "guide thing" that indicates what the tool is doing...
    [drawing.tool drawInContext: c];
}

#pragma mark -
#pragma mark Touch Input

- (TouchProperties)touchPropertiesForTouch:(UITouch*)t
{
    float pixelWidth = [self bounds].size.width / [drawing size].width;
    float pixelHeight = [self bounds].size.height / [drawing size].height;
    
    TouchProperties p;
    p.touch = t;
    p.locationInView = [t locationInView: self];
    p.pixelInView = CGPointMake(floorf(p.locationInView.x / pixelWidth), roundf(p.locationInView.y / pixelHeight));
    p.prevLocationInView = [t previousLocationInView: self];
    p.prevPixelInView = CGPointMake(floorf(p.prevLocationInView.x / pixelWidth), roundf(p.prevLocationInView.y / pixelHeight));
    
    return p;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    TouchProperties p = [self touchPropertiesForTouch: [touches anyObject]];
    [drawing.tool touchBegan: p inDrawing:drawing];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    TouchProperties p = [self touchPropertiesForTouch: [touches anyObject]];
    [drawing.tool touchMoved: p inDrawing:drawing];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    TouchProperties p = [self touchPropertiesForTouch: [touches anyObject]];
    [drawing.tool touchEnded: p inDrawing:drawing];
    [self setNeedsDisplay];
}

@end
