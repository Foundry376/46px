//
//  PixelEditorViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelEditorViewController.h"
#import "PenPixelTool.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "PostViewController.h"
#import "OrangeButton.h"
#import "FacebookManager.h"

#define TOOL_PADDING 5

@implementation PixelEditorViewController

@synthesize colorsView;
@synthesize toolsView;
@synthesize backgroundView;
@synthesize canvasView;
@synthesize canvasThumbnailView;
@synthesize zoomToFitButton;
@synthesize undoButton;
@synthesize redoButton;
@synthesize mirrorXButton;
@synthesize mirrorYButton;
@synthesize drawing;
@synthesize delegate;

- (id)initWithDrawing:(PixelDrawing*)d andDelegate:(NSObject<PixelEditorDelegate>*)del
{
    self = [super init];
    if (self) {
        self.drawing = d;
        self.delegate = del;
        
        if ([del respondsToSelector: @selector(titleForPixelEditor:)])
            self.navigationItem.title = [del titleForPixelEditor: self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.drawing setupForEditing];
    
    _originalNavTint = [[self.navigationController navigationBar] tintColor];
    [[self.navigationController navigationBar] setTintColor: [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:40.0/255.0 alpha:1]];
    
    // attach the tool "buttons" to the sidebar so we can have lots of tools
    for (PixelTool * t in self.drawing.tools) {
        OrangeButton * b = [[OrangeButton alloc] initWithFrame: CGRectMake(0, 0, 60, 60)];
        [b setImage:[t icon] forState:UIControlStateNormal];
        [b setTag: [self.drawing.tools indexOfObject: t]];
        [b addTarget:self action:@selector(toolToggled:) forControlEvents:UIControlEventTouchUpInside];
        [b setImageEdgeInsets: UIEdgeInsetsMake(5, 5, 10, 10)];
        [b setup];
        
        if (self.drawing.tool == t)
            [b setSelected: YES];
            
        [toolsView addSubview: b];
    }

    // attach the drawing to the canvas
    [canvasView setDrawing: self.drawing];
    
    // setup the color view for the first time
    [colorsView setDrawing: self.drawing];
    [undoButton setEnabled: [self.drawing canUndo]];
    [redoButton setEnabled: [self.drawing canRedo]];
    
    // subscribe to know when the drawing changes so we can update the interface
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawingModified) name:@"PixelDrawingChanged" object:nil];

    // add the publish / save button to the upper right
    NSString * title = @"Publish Drawing";
    if ([delegate respondsToSelector:@selector(commitButtonTitleForPixelEditor:)])
        title = [delegate commitButtonTitleForPixelEditor: self];

    UIBarButtonItem * b = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(finished:)];
    [self.navigationItem setRightBarButtonItem:b animated:YES];
}

- (void)layoutForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [backgroundView setFrame: self.view.bounds];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [undoButton setFrame: CGRectMake(632, 894, 60, 60)];
        [redoButton setFrame: CGRectMake(700, 894, 60, 60)];
        [canvasView setFrame: CGRectMake(34, 174, 704, 704)];
        [canvasThumbnailView setFrame: CGRectMake(601, 13, 138, 138)];
        [zoomToFitButton setFrame: CGRectMake(601, 13, 138, 138)];
        [colorsView setFrame: CGRectMake(28, 8, 602, 150)];
        [toolsView setFrame: CGRectMake(0, 889, 488, 133)];
        [mirrorXButton setFrame: CGRectMake(350, 894, 125, 60)];
        [mirrorYButton setFrame: CGRectMake(481, 894, 125, 60)];
        [backgroundView setImage: [UIImage imageNamed: @"drawing_background_portrait.png"]];
        
    } else {
        [undoButton setFrame: CGRectMake(5, 639, 60, 60)];
        [redoButton setFrame: CGRectMake(70, 639, 60, 60)];
        [canvasView setFrame: CGRectMake(141, 0, 704, 704)];
        [canvasThumbnailView setFrame: CGRectMake(872, 13, 138, 138)];
        [zoomToFitButton setFrame: CGRectMake(872, 13, 138, 138)];
        [colorsView setFrame: CGRectMake(865, 166, 150, 540)];
        [toolsView setFrame: CGRectMake(0, 0, 133, 488)];
        [mirrorXButton setFrame: CGRectMake(5, 506, 125, 60)];
        [mirrorYButton setFrame: CGRectMake(5, 573, 125, 60)];
        [backgroundView setImage: [UIImage imageNamed: @"drawing_background.png"]];
    }
    [self layoutToolButtons];
}

- (void)layoutToolButtons
{
    CGRect r = CGRectMake(4, TOOL_PADDING, 60, 60);
    for (UIButton * b in toolsView.subviews) {
        [b setFrame: r];
        r.origin.x += r.size.width + TOOL_PADDING;
        if (r.origin.x + r.size.width > toolsView.bounds.size.width) {
            r.origin.x = 4;
            r.origin.y += r.size.height + TOOL_PADDING;
        }
    }
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [self setColorsView:nil];
    [self setToolsView:nil];
    [self setCanvasView:nil];
    [self setUndoButton:nil];
    [self setCanvasThumbnailView: nil];
    [self setRedoButton:nil];
    [self setMirrorXButton:nil];
    [self setMirrorYButton:nil];
    [self setZoomToFitButton:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self layoutForOrientation: self.interfaceOrientation];
    
    [canvasThumbnailView setDrawing: self.drawing];
    [canvasThumbnailView setNeedsDisplay];
    [canvasView setNeedsDisplay];
    [colorsView setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // save the drawing to drafts!!
    [drawing save];
    
    [[self.navigationController navigationBar] setTintColor: _originalNavTint];
}

- (void)downloadAndAddImage:(NSString*)path
{
    ASIHTTPRequest * req = [[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString: path]];
    [req setDelegate:self];
    [req setDidFinishSelector:@selector(downloadAndAddImageFinished:)];
    [req startAsynchronous];
}

- (void)downloadAndAddImageFinished:(ASIHTTPRequest*)req
{
    UIImage * i = [UIImage imageWithData: [req responseData]];
    CGLayerRef r = [drawing baseLayer];
    CGContextRef c = CGLayerGetContext(r);
    CGContextSaveGState(c);
    CGContextScaleCTM(c, 1, -1);
    CGContextTranslateCTM(c, 0, -i.size.height);
    CGContextDrawImage(c, CGRectMake(0, 0, [i size].width, [i size].height), [i CGImage]);
    CGContextRestoreGState(c);
    [canvasView setNeedsDisplay];
}

- (void)toolToggled:(UIButton*)toolButton
{
    // deselect all the tool buttons
    for (UIButton * b in [toolsView subviews]) 
        [b setSelected: NO];
    
    // select the one the user clicked
    [toolButton setSelected: YES];
    
    // update the drawing's current tool
    [self.drawing setTool: [[self.drawing tools] objectAtIndex: [toolButton tag]]];
}

- (void)finished:(id)sender
{
    if ([[[FacebookManager sharedManager] facebookUserID] length] > 0) {
        // okay. so the user is done! let's fire back to the delegate
        PostViewController * pvc = [[PostViewController alloc] init];
        [pvc setDrawing: drawing];
        [pvc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        [pvc setModalPresentationStyle: UIModalPresentationFormSheet];
        [self presentModalViewController:pvc animated:YES];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"Before you can post your drawings, you need to sign in to Facebook on the home screen. Don't worry, you can re-open this drawing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)undo:(id)sender
{
    [self.drawing performUndo];
}

- (IBAction)redo:(id)sender
{
    [self.drawing performRedo];
}

- (IBAction)zoomToFit:(id)sender
{
    [canvasView zoomToFit];
}

- (IBAction)toggleMirroringY:(id)sender
{
     [self.drawing setMirroringY: !drawing.mirroringY];
     [mirrorYButton setSelected: drawing.mirroringY];
}

- (IBAction)toggleMirroringX:(id)sender
{
    [self.drawing setMirroringX: !drawing.mirroringX];
    [mirrorXButton setSelected: drawing.mirroringX];
}

- (void)drawingModified
{
    [undoButton setEnabled: [self.drawing canUndo]];
    [redoButton setEnabled: [self.drawing canRedo]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutForOrientation: interfaceOrientation];
}


@end
