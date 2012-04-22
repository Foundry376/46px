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
@synthesize canvasView;
@synthesize canvasThumbnailView;
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
    
    // attach the tool "buttons" to the sidebar so we can have lots of tools
    CGRect r = CGRectMake(4, TOOL_PADDING, 60, 60);
    for (PixelTool * t in self.drawing.tools) {
        OrangeButton * b = [[[OrangeButton alloc] initWithFrame: r] autorelease];
        [b setImage:[t icon] forState:UIControlStateNormal];
        [b setTag: [self.drawing.tools indexOfObject: t]];
        [b addTarget:self action:@selector(toolToggled:) forControlEvents:UIControlEventTouchUpInside];
        [b setImageEdgeInsets: UIEdgeInsetsMake(5, 5, 10, 10)];
        [b setup];
        
        if (self.drawing.tool == t)
            [b setSelected: YES];
            
        [toolsView addSubview: b];
        
        r.origin.x += r.size.width + TOOL_PADDING;
        if (r.origin.x + r.size.width > toolsView.bounds.size.width) {
            r.origin.x = 4;
            r.origin.y += r.size.height + TOOL_PADDING;
        }
    }
    
    // attach the drawing to the canvas
    [canvasView setDrawing: self.drawing];
    [canvasThumbnailView setDrawing: self.drawing];
    [canvasView setNeedsDisplay];
    [canvasThumbnailView setNeedsDisplay];
    
    // setup the color view for the first time
    [colorsView setDrawing: self.drawing];
    [colorsView setNeedsDisplay];
    [undoButton setEnabled: [self.drawing canUndo]];
    [redoButton setEnabled: [self.drawing canRedo]];
    
    // subscribe to know when the drawing changes so we can update the interface
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawingModified) name:@"PixelDrawingChanged" object:nil];

    // add the publish / save button to the upper right
    NSString * title = @"Save";
    if ([delegate respondsToSelector:@selector(commitButtonTitleForPixelEditor:)])
        title = [delegate commitButtonTitleForPixelEditor: self];

    UIBarButtonItem * b = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(finished:)];
    [self.navigationItem setRightBarButtonItem:b animated:YES];
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
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // save the drawing to drafts!!
    [drawing save];
}

- (void)downloadAndAddImage:(NSString*)path
{
    ASIHTTPRequest * req = [[[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString: path]] autorelease];
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
        PostViewController * pvc = [[[PostViewController alloc] init] autorelease];
        [pvc setDrawing: drawing];
        [pvc setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        [pvc setModalPresentationStyle: UIModalPresentationFormSheet];
        [self presentModalViewController:pvc animated:YES];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"Before you can post your drawings, you need to sign in to Facebook on the home screen. Don't worry, you can re-open this drawing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
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

- (void)dealloc
{
    self.drawing = nil;
    
    [undoButton release];
    [redoButton release];
    [canvasView release];
    [canvasThumbnailView release];
    [colorsView release];
    [toolsView release];
    [mirrorXButton release];
    [mirrorYButton release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end
