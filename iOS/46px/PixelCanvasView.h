//
//  PixelCanvasView.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelDrawing.h"
#import "PixelEditOperation.h"

typedef struct {
    UITouch * touch;
    CGPoint locationInView;
    CGPoint pixelInView;
    CGPoint prevLocationInView;
    CGPoint prevPixelInView;
} TouchProperties;

typedef struct {
    float x;
    float y;
    float zoom;
} Transforms;

@interface PixelCanvasView : UIView
{
    Transforms  camera;
    Transforms  pending;
    
    NSTimer * zoomToFitTimer;
    Transforms zoomToFitTargetTransforms;
    float zoomToFitFraction;
}

@property (nonatomic, assign) PixelDrawing * drawing;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)setup;
- (void)zoomToFit;
- (void)dealloc;

#pragma mark -
#pragma mark Touch Input

- (TouchProperties)touchPropertiesForTouch:(UITouch*)t;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
