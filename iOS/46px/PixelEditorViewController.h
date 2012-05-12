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
#import "ColorGridView.h"

@class PixelEditorViewController;

@protocol PixelEditorDelegate <NSObject>

@optional
- (NSString*)titleForPixelEditor:(PixelEditorViewController*)e;
- (NSString*)commitButtonTitleForPixelEditor:(PixelEditorViewController*)e;
- (void)pixelEditorDidFinishEditing:(PixelEditorViewController*)e committed:(BOOL)committed;

@end
@interface PixelEditorViewController : UIViewController
{
}

@property (nonatomic, assign) NSObject<PixelEditorDelegate> * delegate;
@property (nonatomic, retain) PixelDrawing * drawing;
@property (retain, nonatomic) IBOutlet ColorGridView *colorsView;
@property (retain, nonatomic) IBOutlet UIView *toolsView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;

@property (retain, nonatomic) IBOutlet PixelCanvasView *canvasView;
@property (retain, nonatomic) IBOutlet PixelCanvasView *canvasThumbnailView;
@property (retain, nonatomic) IBOutlet UIButton *zoomToFitButton;

@property (retain, nonatomic) IBOutlet UIButton *undoButton;
@property (retain, nonatomic) IBOutlet UIButton *redoButton;
@property (retain, nonatomic) IBOutlet UIButton *mirrorXButton;
@property (retain, nonatomic) IBOutlet UIButton *mirrorYButton;

- (id)initWithDrawing:(PixelDrawing*)d andDelegate:(NSObject<PixelEditorDelegate>*)del;

- (void)viewDidLoad;
- (void)viewDidUnload;

- (void)downloadAndAddImage:(NSString*)path;

- (void)toolToggled:(UIButton*)toolButton;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)zoomToFit:(id)sender;

- (void)drawingModified;

- (void)dealloc;

@end
