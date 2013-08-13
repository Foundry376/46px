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
    UIColor * _originalNavTint;
    UIPopoverController * _activityPopover;
}

@property (nonatomic, weak) NSObject<PixelEditorDelegate> * delegate;
@property (nonatomic, strong) PixelDrawing * drawing;
@property (strong, nonatomic) IBOutlet ColorGridView *colorsView;
@property (strong, nonatomic) IBOutlet UIView *toolsView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;

@property (strong, nonatomic) IBOutlet PixelCanvasView *canvasView;
@property (strong, nonatomic) IBOutlet PixelCanvasView *canvasThumbnailView;
@property (strong, nonatomic) IBOutlet UIButton *zoomToFitButton;

@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;
@property (strong, nonatomic) IBOutlet UIButton *mirrorXButton;
@property (strong, nonatomic) IBOutlet UIButton *mirrorYButton;

- (id)initWithDrawing:(PixelDrawing*)d andDelegate:(NSObject<PixelEditorDelegate>*)del;

- (void)viewDidLoad;
- (void)viewDidUnload;

- (void)downloadAndAddImage:(NSString*)path;

- (void)toolToggled:(UIButton*)toolButton;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)zoomToFit:(id)sender;

- (void)drawingModified;

@end
