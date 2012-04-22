//
//  PostViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostViewController.h"
#import "APIConnector.h"

@implementation PostViewController
@synthesize previewImage;
@synthesize captionTextView;
@synthesize postButton;
@synthesize drawing;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEnded) name:@"PostEnded" object:nil];
    [captionTextView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: 
    [self setPreviewImage:nil];
    [self setCaptionTextView:nil];
    [self setPostButton:nil];
    [super viewDidUnload];
}


- (IBAction)cancel:(id)sender 
{
    [self dismissModalViewControllerAnimated: YES];
}

- (IBAction)post:(id)sender 
{
    [self.drawing setCaption: [captionTextView text]];
    [[APIConnector shared] postDrawing: self.drawing];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc 
{
    [previewImage release];
    [captionTextView release];
    [postButton release];
    [super dealloc];
}
@end
