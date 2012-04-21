//
//  PixelDrawing.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelDrawing.h"
#import "PixelCanvasView.h"
#import "CGHelpers.h"
#import "PenPixelTool.h"
#import "PixelTool.h"

@implementation PixelDrawing

@synthesize baseLayer, operationLayer, size, tools, tool;

- (id)initWithSize:(CGSize)s
{
    self = [super init];
    if (self) {
        size = s;
        
        operationStack = [[NSMutableArray alloc] init];
        redoStack = [[NSMutableArray alloc] init];
        
        // setup some tools
        tools = [[NSMutableArray alloc] init];
        PenPixelTool * pen = [[[PenPixelTool alloc] init] autorelease];
        [tools addObject: pen];

        tool = [tools objectAtIndex: 0];
    }
    return self;
}

- (void)initializeWithContext:(CGContextRef)ref
{
    baseLayer = CGLayerCreateWithContext(ref, size, NULL);
    operationLayer = CGLayerCreateWithContext(ref, size, NULL);
    CGContextSetInterpolationQuality(CGLayerGetContext(baseLayer), kCGInterpolationNone);
    CGContextSetAllowsAntialiasing(CGLayerGetContext(baseLayer), NO);
    CGContextSetInterpolationQuality(CGLayerGetContext(operationLayer), kCGInterpolationNone);
    CGContextSetAllowsAntialiasing(CGLayerGetContext(operationLayer), NO);
}

- (BOOL)layersInitialized
{
    return (baseLayer != nil);
}

- (void)dealloc
{
    [operationStack release];
    [redoStack release];
    [super dealloc];
}

#pragma mark -
#pragma mark Handling Operations

- (BOOL)canUndo
{
    return ([operationStack count] > 0);
}

- (void)performUndo
{
    PixelEditOperation * op = [operationStack lastObject];
    [operationStack removeLastObject];
    
    // do we have the "changed" data in the operation? If not, let's populate
    // it so that it's possible to redo!
    if ([op changed] == nil)
        [op setChanged: UIImageFromLayer(baseLayer, [op changeRegion])];
    [UIImagePNGRepresentation([op changed]) writeToFile:@"/test.png" atomically:YES];
    
    // restore the drawing to what it looked like
    CGContextRef b = CGLayerGetContext(baseLayer);
    CGContextClearRect(b, [op changeRegion]);
    CGContextDrawImage(b, [op changeRegion], [[op original] CGImage]);

    // push this operation on the redo stack
    [redoStack addObject: op];
    
    // tell the canvas view that it needs to refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PixelDrawingChanged" object:nil];
}

- (BOOL)canRedo
{
    return ([redoStack count] > 0);
}

- (void)performRedo
{
    PixelEditOperation * op = [redoStack lastObject];
    [redoStack removeLastObject];
    
    // so if we're redoing, it means that the user drew something, then undid it,
    // and now they want it back. We have the original data (pre-operation) in
    // the "original" property and the changed image (post-operation) in "changed."
    
    // so let's restore to "changed"
    CGContextRef b = CGLayerGetContext(baseLayer);
    CGContextClearRect(b, [op changeRegion]);
    CGContextDrawImage(b, [op changeRegion], [[op changed] CGImage]);
    
    // push this operation back on the operations stack so we can undo it again!
    [operationStack addObject: op];
    
    // tell the canvas view that it needs to refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PixelDrawingChanged" object:nil];
}

- (void)applyOperation:(PixelEditOperation*)op
{
    // okay—so each operation has a change region. Grab that portion of our image,
    // and save it so we can undo this change later.
    [op setOriginal: UIImageFromLayer(baseLayer, [op changeRegion])];
    [UIImagePNGRepresentation([op original]) writeToFile:@"/test.png" atomically:YES];
    
    // flatten the operationLayer onto the baseLayer
    CGContextRef b = CGLayerGetContext(baseLayer);
    CGContextDrawLayerAtPoint(b, CGPointZero, operationLayer);
    
    // clear the operation layer—the user will want to begin another operation soon
    // and we want this layer to ONLY hold the part of the drawing the tool is 
    // currently creating.
    CGContextRef o = CGLayerGetContext(operationLayer);
    CGContextClearRect(o, CGRectMake(0, 0, size.width, size.height));
    
    // push this operation onto the history stack and prevent redos (now that a 
    // new operation has occurred you can't redo things you undid)
    [operationStack addObject: op]; 
    [redoStack removeAllObjects];
    
    // tell the canvas view that it needs to refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PixelDrawingChanged" object:nil];
}

@end
