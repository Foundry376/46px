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
    
    // add gesture recognizers for pinching and scrolling
    UIPanGestureRecognizer * g = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
    [g setMinimumNumberOfTouches: 2];
    [self addGestureRecognizer: g];
    
    UIPinchGestureRecognizer * z = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)] autorelease];
    [self addGestureRecognizer: z];
    
    camera.zoom = 1;
    pending.zoom = 1;
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
    CGContextSaveGState(c);
    
    // apply the camera transforms and the pending transforms. How does this work? 
    // We have two sets of "transforms" each with an X and Y translation and a zoom
    // value. When we start drawing, we have x = 0, y= 0, and zoom = 1. Let's say
    // you start zooming. We change the "pending" transform's zoom value as you're
    // zooming and then when you release the screen, we "commit" that value by 
    // multiplying it into the camera zoom and reseting the pending zoom. 
    
    // When we go to draw, step 1 is to shift the canvas by whatever the X/Y translation is:
    CGContextTranslateCTM(c, -camera.x -pending.x, -camera.y - pending.y);
    
    // Next, we want to zoom in or out based on the current zoom level (pending.zoom * camera.zoom).
    // This is a bit tricky becaues we don't want to zoom from the top left, we want to zoom from
    // the CENTER. To make that happen, we first need to shift everything in by 1/2 the screen
    // width, then apply our zoom translation, and then shift back.
    CGContextTranslateCTM(c, rect.size.width / 2, rect.size.height / 2);
    CGContextScaleCTM(c, pending.zoom * camera.zoom, pending.zoom * camera.zoom);
    CGContextTranslateCTM(c, -rect.size.width / 2, -rect.size.height / 2);
    
    // Note that we apply 1) translation and 2) zoom in that order. It's important to keep
    // that consistent throughout! To go from screen pixel to canvas pixel, do that order.
    // To go from canvas pixel to screen pixel, do the opposite: 2) then 1).
    
    // Note that the translation and scaling functions above _change the coordinate space
    // of the graphics context_. This means that when we say "draw into pixel 5,5" below,
    // those translations will be applied to "5,5" before anything is drawn. Some 5,5 might
    // become 10,10, or 5,0, etc... and the code below doesn't have to care.
    
    // draw the baseLayer of the drawing
    CGContextDrawLayerInRect(c, [self bounds], drawing.baseLayer);
    CGContextDrawLayerInRect(c, [self bounds], drawing.operationLayer);
    if (drawing.mirroringY){
        CGContextSaveGState(c);
        CGContextTranslateCTM(c, [self bounds].size.width, 0);
        CGContextScaleCTM(c, -1, 1);
        CGContextDrawLayerInRect(c, [self bounds], drawing.operationLayer);
        CGContextRestoreGState(c);
    }
    
    if (drawing.mirroringX) {
        CGContextSaveGState(c);
        CGContextTranslateCTM(c, 0, [self bounds].size.height);
        CGContextScaleCTM(c, 1, -1);
        CGContextDrawLayerInRect(c, [self bounds], drawing.operationLayer);
        CGContextRestoreGState(c);
    }
    
    if ((drawing.mirroringX) && (drawing.mirroringY)) {
        CGContextSaveGState(c);
        CGContextTranslateCTM(c, 0, [self bounds].size.height);
        CGContextScaleCTM(c, 1, -1);
        CGContextTranslateCTM(c, [self bounds].size.width, 0);
        CGContextScaleCTM(c, -1, 1);
        CGContextDrawLayerInRect(c, [self bounds], drawing.operationLayer);
        CGContextRestoreGState(c);
    }

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
    CGContextRestoreGState(c);
    
    if ([[drawing tool] down]) {
        [drawing.tool drawInContext: c];
    }
}

- (void)pan:(UIPanGestureRecognizer*)r
{
    CGPoint p = [r translationInView: self];
    pending.x = -p.x;
    pending.y = -p.y;
    
    if (r.state == UIGestureRecognizerStateEnded) {
        camera.x += pending.x;
        camera.y += pending.y;
        pending.x = 0;
        pending.y = 0;
    }
    
    [self setNeedsDisplay];
}

- (void)zoom:(UIPinchGestureRecognizer*)r
{
    pending.zoom = fmaxf(1 / camera.zoom, [r scale]);
    
    if (r.state == UIGestureRecognizerStateEnded) {
        camera.zoom *= pending.zoom;
        pending.zoom = 1;
    }
    
    [self setNeedsDisplay];
}


#pragma mark -
#pragma mark Touch Input

- (TouchProperties)touchPropertiesForTouch:(UITouch*)t
{
    TouchProperties p;
    p.touch = t;
    p.locationInView = [t locationInView: self];
    p.prevLocationInView = [t previousLocationInView: self];

    // to go from a pixel to a canvas pixel:
    // determine: What fraction pixel location is in the top left corner?
    // determine: What is the current width / height of the displayed region?
    // solve: left offset + (pixel x / width of view) * displayed region width
    
    float pixelWidth = ([self bounds].size.width / [drawing size].width);
    float pixelHeight = ([self bounds].size.height / [drawing size].height);
    float zoom = pending.zoom * camera.zoom;
    
    float xOffset = pending.x + camera.x;
    float yOffset = pending.y + camera.y;
    CGSize displayedRegionSize = CGSizeMake(self.frame.size.width / (pixelWidth * zoom), self.frame.size.height / (pixelHeight * zoom));
    CGPoint displayedOffset = CGPointMake(([drawing size].width - displayedRegionSize.width) / 2 + xOffset / (pixelWidth * zoom), ([drawing size].height - displayedRegionSize.height) / 2 + yOffset / (pixelHeight * zoom));
    
    p.pixelInView = CGPointMake(p.locationInView.x / (pixelWidth * zoom) + displayedOffset.x, p.locationInView.y / (pixelWidth * zoom) + displayedOffset.y);
    p.prevPixelInView = CGPointMake(p.prevLocationInView.x / (pixelWidth * zoom) + displayedOffset.x, p.prevLocationInView.y / (pixelWidth * zoom) + displayedOffset.y);
    
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
