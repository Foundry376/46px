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
#import "LinePixelTool.h"
#import "PaintBucketPixelTool.h"

@implementation PixelDrawing

@synthesize baseLayer, operationLayer, size, tools, tool, colors, color, directory, mirroringX, mirroringY, caption, threadID;

- (id)initWithDirectory:(NSString*)d
{
    self = [super init];
    if (self) {
        self.threadID = -1;
        self.directory = d;
        
        // load the drawing size and the thread ID
        if ([[NSFileManager defaultManager] fileExistsAtPath: [self statePath]]) {
            NSDictionary * state = [NSKeyedUnarchiver unarchiveObjectWithFile: [self statePath]];
            self.size = [[state objectForKey:@"size"] CGSizeValue];
            self.threadID = [[state objectForKey:@"threadID"] intValue];
        }
    }
    return self;
}

- (id)initWithSize:(CGSize)s andDirectory:(NSString*)d
{
    self = [super init];
    if (self) {
        self.threadID = -1;
        self.size = s;
        self.directory = d;
        
    }
    return self;
}

- (void)setupForEditing
{
    // make sure our directory exists!
    if ([[NSFileManager defaultManager] fileExistsAtPath: directory] == NO)
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];

    // setup some tools
    tools = [[NSMutableArray alloc] init];
    [tools addObject: [[[PenPixelTool alloc] init] autorelease]];
    [tools addObject: [[[LinePixelTool alloc] init] autorelease]];
    [tools addObject: [[[PaintBucketPixelTool alloc] init] autorelease]];
    
    // setup some colors
    colors = [[NSMutableArray alloc] init];
    [colors addObject: [UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [colors addObject: [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1]];
    [colors addObject: [UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    
    // populate a ton of colors... algorithmically
    float hStep = 1.0 / 10.0;
    for (int h = 0; h < 10; h ++) {
        UIColor * c3 = [UIColor colorWithHue:h * hStep saturation:1 brightness:0.5 alpha:1];
        [colors addObject: c3];
        UIColor * c2 = [UIColor colorWithHue:h * hStep saturation:1 brightness:1 alpha:1];
        [colors addObject: c2];
        UIColor * c1 = [UIColor colorWithHue:h * hStep saturation:0.5 brightness:1 alpha:1];
        [colors addObject: c1];
    }
    
    // set defaults
    color = [colors objectAtIndex: 0];
    tool = [tools objectAtIndex: 0];
    
    // load operations and redo...
    if ([[NSFileManager defaultManager] fileExistsAtPath: [self statePath]]) {
        NSDictionary * state = [NSKeyedUnarchiver unarchiveObjectWithFile: [self statePath]];
        operationStack = [[state objectForKey:@"operationStack"] retain];
        redoStack = [[state objectForKey:@"redoStack"] retain];
    }

    if (operationStack == nil)
        operationStack = [[NSMutableArray alloc] init];
    if (redoStack == nil)
        redoStack = [[NSMutableArray alloc] init];
}

- (void)save
{
    // save the state file
    NSMutableDictionary * d = [NSMutableDictionary dictionaryWithCapacity:2];
    [d setObject:operationStack forKey:@"operationStack"];
    [d setObject:redoStack forKey:@"redoStack"];
    [d setObject:[NSNumber numberWithInt: threadID] forKey:@"threadID"];
    [d setObject:[NSValue valueWithCGSize: size] forKey:@"size"];
    
    [NSKeyedArchiver archiveRootObject:d toFile:[self statePath]];
    
    // save our png file
    UIImage * us = UIImageFromLayer(baseLayer, CGRectMake(0, 0, size.width, size.height), NO);
    [UIImagePNGRepresentation(us) writeToFile:[self imagePath] atomically:NO];
}

- (void)initializeWithContext:(CGContextRef)ref
{
    baseLayer = CGLayerCreateWithContext(ref, size, NULL);
    operationLayer = CGLayerCreateWithContext(ref, size, NULL);
    
    CGContextRef bc = CGLayerGetContext(baseLayer);
    CGContextRef oc = CGLayerGetContext(operationLayer);
    
    CGContextSetInterpolationQuality(bc, kCGInterpolationNone);
    CGContextSetAllowsAntialiasing(bc, NO);
    CGContextSetInterpolationQuality(oc, kCGInterpolationNone);
    CGContextSetAllowsAntialiasing(oc, NO);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: [self imagePath]]) {
        UIImage * i = [UIImage imageWithContentsOfFile: [self imagePath]];
        CGContextSaveGState(bc);
        CGContextScaleCTM(bc, 1, -1);
        CGContextTranslateCTM(bc, 0, -[i size].height);
        CGContextDrawImage(bc, CGRectMake(0, 0, [i size].width, [i size].height), [i CGImage]);
        CGContextRestoreGState(bc);
    }
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
    if (![self canUndo])
        return;
    
    PixelEditOperation * op = [operationStack lastObject];
    [operationStack removeLastObject];
    
    // do we have the "changed" data in the operation? If not, let's populate
    // it so that it's possible to redo!
    if ([op changed] == nil)
        [op setChanged: UIImageFromLayer(baseLayer, [op changeRegion], YES)];
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
    if (![self canRedo])
        return;
        
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
    if (mirroringY) {
        CGRect o = [op changeRegion];
        float flip = size.width / 2;
        o.origin.x = flip + (flip - (o.origin.x + o.size.width));
        [op setChangeRegion: CGRectUnion([op changeRegion], o)];
    }
    if (mirroringX) {
        CGRect o = [op changeRegion];
        float flip = size.height / 2;
        o.origin.y = flip + (flip - (o.origin.y + o.size.height));
        [op setChangeRegion: CGRectUnion([op changeRegion], o)];
    }
    
    [op setOriginal: UIImageFromLayer(baseLayer, [op changeRegion], YES)];
    [UIImagePNGRepresentation([op original]) writeToFile:@"/test.png" atomically:YES];
    
    // flatten the operationLayer onto the baseLayer
    CGContextRef b = CGLayerGetContext(baseLayer);
    CGContextDrawLayerAtPoint(b, CGPointZero, operationLayer);
    if (mirroringY) {
        CGContextSaveGState(b);
        CGContextTranslateCTM(b, size.width, 0);
        CGContextScaleCTM(b, -1, 1);
        CGContextDrawLayerAtPoint(b, CGPointZero, operationLayer);
        CGContextRestoreGState(b);
    }
    if (mirroringX) {
        CGContextSaveGState(b);
        CGContextTranslateCTM(b, 0, size.height);
        CGContextScaleCTM(b, 1, -1);
        CGContextDrawLayerAtPoint(b, CGPointZero, operationLayer);
        CGContextRestoreGState(b);
    }
    if ((mirroringX) && (mirroringY)) {
        CGContextSaveGState(b);
        CGContextTranslateCTM(b, 0, size.height);
        CGContextScaleCTM(b, 1, -1);
        CGContextTranslateCTM(b, size.width, 0);
        CGContextScaleCTM(b, -1, 1);
        CGContextDrawLayerAtPoint(b, CGPointZero, operationLayer);
        CGContextRestoreGState(b);
    }
    
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


#pragma mark -
#pragma mark Representing on Disk

- (UIImage*)image
{
    if (baseLayer != nil) {
        return UIImageFromLayer(baseLayer, CGRectMake(0, 0, size.width, size.height), NO);
        
    } else {
        UIImage * i = [UIImage imageWithContentsOfFile: [self imagePath]];
        //i = [UIImage imageWithCGImage:[i CGImage] scale:1 orientation:UIImageOrientationDownMirrored];
        if (i) return i;
    }

    return [UIImage imageNamed: @"missing.png"];
}

- (NSString*)imagePath
{
    return [directory stringByAppendingPathComponent:@"46px.png"];
}

- (NSString*)statePath
{
    return [directory stringByAppendingPathComponent:@"state.plist"];
}

@end
