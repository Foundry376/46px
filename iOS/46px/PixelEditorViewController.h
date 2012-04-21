//
//  PixelEditorViewController.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelTool.h"
#import "PixelCanvasView.h"
#import "PixelEditOperation.h"
#import "PixelDrawing.h"

@class PixelEditorViewController;

@protocol PixelEditorDelegate <NSObject>

@optional
- (NSString*)titleForPixelEditor:(PixelEditorViewController*)e;
- (void)pixelEditorDidFinishEditing:(PixelEditorViewController*)e;

@end
@interface PixelEditorViewController : UIViewController
{
}

@property (nonatomic, assign) NSObject<PixelEditorDelegate> * delegate;
@property (nonatomic, retain) PixelDrawing * drawing;
@property (retain, nonatomic) IBOutlet UIView *colorsView;
@property (retain, nonatomic) IBOutlet UIView *toolsView;
@property (retain, nonatomic) IBOutlet PixelCanvasView *canvasView;

@property (retain, nonatomic) IBOutlet UIButton *undoButton;
@property (retain, nonatomic) IBOutlet UIButton *redoButton;

@end
