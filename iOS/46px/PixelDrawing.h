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

@property (nonatomic, retain) NSMutableArray * colors;
@property (nonatomic, assign) UIColor * color;

@property (nonatomic, assign) CGLayerRef baseLayer;
@property (nonatomic, assign) CGLayerRef operationLayer;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, retain) NSString * directory;

- (id)initWithSize:(CGSize)s andDirectory:(NSString*)d;
- (id)initWithDirectory:(NSString*)d;

- (void)setupForEditing;

- (void)initializeWithContext:(CGContextRef)ref;
- (BOOL)layersInitialized;

- (void)save;

#pragma mark -
#pragma mark Handling Operations

- (BOOL)canUndo;
- (void)performUndo;
- (BOOL)canRedo;
- (void)performRedo;
- (void)applyOperation:(PixelEditOperation*)op;

#pragma mark -
#pragma mark Representing on Disk

- (UIImage*)image;
- (NSString*)imagePath;
- (NSString*)statePath;

@end
