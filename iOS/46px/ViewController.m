//
//  ViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PixelEditorViewController.h"
#import "PixelDrawing.h"
#import "APIConnector.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize webView;
@synthesize draftOne;
@synthesize draftTwo;
@synthesize draftThree;
@synthesize draftFour;
@synthesize draftFive;
@synthesize draftSix;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *urlAddress = @"http://46px.com/test_pagenums.php";
    
    // Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    // URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    // Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSMutableArray *buttonArray = [NSMutableArray arrayWithCapacity:6];
    [buttonArray addObject:draftOne];
    [buttonArray addObject:draftTwo];
    [buttonArray addObject:draftThree];
    [buttonArray addObject:draftFour];
    [buttonArray addObject:draftFive];
    [buttonArray addObject:draftSix];
    size_t increment = 0;
    
    UIButton *curButton;
    
    for (size_t i = 0; i < [[[APIConnector shared] drafts] count]; ++i) {
        increment++;
        PixelDrawing *d = [[[APIConnector shared] drafts] objectAtIndex:i];
        
        curButton = [buttonArray objectAtIndex:i];
        
        [curButton setImage:[d image] forState:UIControlStateNormal];
        [curButton setImage:[d image] forState:UIControlStateHighlighted];
        curButton.adjustsImageWhenHighlighted = NO;
    }
    for (size_t i = increment; i < [buttonArray count]; ++i) {
        curButton = [buttonArray objectAtIndex:i];
        curButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
}
    
- (IBAction)start:(id)sender
{    
    // ask for a folder that we can put our new drawing into
    NSString * dir = [[APIConnector shared] pathForNewDrawing];
    
    // create the new drawing, and add it to our drafts
    PixelDrawing * d = [[[PixelDrawing alloc] initWithSize: CGSizeMake(46, 46) andDirectory: dir] autorelease];
    [[[APIConnector shared] drafts] addObject: d];
    
    // open the editing view controller and go!
    PixelEditorViewController * pevc = [[PixelEditorViewController alloc] initWithDrawing: d andDelegate: self];
    [self.navigationController pushViewController:pevc animated:YES];
    [pevc autorelease];
}


- (IBAction)draftSelected:(id)sender {
    
    int drawingToLoad = 0;
    
    if (sender == draftTwo)
        drawingToLoad = 1;
    else if (sender == draftThree)
        drawingToLoad = 2;
    else if (sender == draftFour)
        drawingToLoad = 3;
    else if (sender == draftFive)
        drawingToLoad = 4;
    else if (sender == draftSix)
        drawingToLoad = 5;
    
    // create the new drawing, and add it to our drafts
    PixelDrawing * d = [[[APIConnector shared] drafts] objectAtIndex:drawingToLoad];
    
    // open the editing view controller and go!
    PixelEditorViewController * pevc = [[PixelEditorViewController alloc] initWithDrawing: d andDelegate: self];
    [self.navigationController pushViewController:pevc animated:YES];
    [pevc autorelease];
}

- (void)viewDidUnload
{
    [self setDraftOne:nil];
    [self setDraftTwo:nil];
    [self setDraftThree:nil];
    [self setDraftFour:nil];
    [self setDraftFive:nil];
    [self setDraftSix:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
    [draftOne release];
    [draftTwo release];
    [draftThree release];
    [draftFour release];
    [draftFive release];
    [draftSix release];
    [super dealloc];
}
@end
