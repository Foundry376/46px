//
//  PixelDrawing.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PixelEditOperation.h"

@class PixelTool;

@interface PixelDrawing : NSObject
{
    CGSize              size;
    CGLayerRef          baseLayer;
    CGLayerRef          operationLayer;
    
    NSMutableArray    * operationStack;
    NSMutableArray    * redoStack;
    
}

@property (nonatomic, retain) NSMutableArray * tools;
@property (nonatomic, assign) PixelTool * tool;

@property (nonatomic, assign) CGLayerRef baseLayer;
@property (nonatomic, assign) CGLayerRef operationLayer;
@property (nonatomic, assign) CGSize size;

- (void)initializeWithContext:(CGContextRef)ref;
- (BOOL)layersInitialized;


#pragma mark -
#pragma mark Handling Operations

- (BOOL)canUndo;
- (void)performUndo;
- (BOOL)canRedo;
- (void)performRedo;
- (void)applyOperation:(PixelEditOperation*)op;

@end
