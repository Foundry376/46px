//
//  PixelEditorViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelEditorViewController.h"
#import "PenPixelTool.h"

#define TOOL_PADDING 5

@implementation PixelEditorViewController

@synthesize colorsView;
@synthesize toolsView;
@synthesize canvasView;
@synthesize canvasThumbnailView;
@synthesize undoButton;
@synthesize redoButton;
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
    CGRect r = CGRectMake(0, 0, 65, 65);
    for (PixelTool * t in self.drawing.tools) {
        UIButton * b = [[[UIButton alloc] initWithFrame: r] autorelease];
        [b setImage:[t icon] forState:UIControlStateNormal];
        [b setTag: [self.drawing.tools indexOfObject: t]];
        [b addTarget:self action:@selector(toolToggled:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.drawing.tool = t)
            [b setSelected: YES];
            
        [toolsView addSubview: b];
        
        r.origin.x += r.size.width + TOOL_PADDING;
        if (r.origin.x + r.size.width > toolsView.bounds.size.width) {
            r.origin.x = TOOL_PADDING;
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
    
    // subscribe to know when the drawing changes so we can update the interface
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawingModified) name:@"PixelDrawingChanged" object:nil];
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
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // save the drawing to drafts!!
    [drawing save];
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

- (IBAction)undo:(id)sender
{
    [self.drawing performUndo];
}

- (IBAction)redo:(id)sender
{
    [self.drawing performRedo];
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
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
