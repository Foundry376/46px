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

@interface TouchProperties : NSObject
@property (nonatomic, strong) UITouch * touch;
@property (nonatomic, assign) CGPoint locationInView;
@property (nonatomic, assign)CGPoint pixelInView;
@property (nonatomic, assign)CGPoint prevLocationInView;
@property (nonatomic, assign)CGPoint prevPixelInView;
@end

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

@property (nonatomic, weak) PixelDrawing * drawing;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)setup;
- (void)zoomToFit;
- (void)dealloc;

#pragma mark -
#pragma mark Touch Input

- (TouchProperties*)touchPropertiesForTouch:(UITouch*)t;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
