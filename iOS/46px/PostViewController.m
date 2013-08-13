//
//  PostViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostViewController.h"
#import "APIConnector.h"
#import <QuartzCore/QuartzCore.h>
#import "FacebookManager.h"

@implementation PostViewController

@synthesize previewImage;
@synthesize captionTextView;
@synthesize postButton;
@synthesize drawing;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[previewImage layer] setMagnificationFilter:kCAFilterNearest];
    [previewImage setImage: [drawing image]];
    [captionTextView setText: [drawing caption]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postEnded:) name:@"PostEnded" object:nil];
    [captionTextView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
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
    [spinner startAnimating];
}

- (void)postEnded:(NSNotification*)notif
{
    NSError * error = [notif object];
    
    [spinner stopAnimating];
    
    if (error) {
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Post Failed!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [a show];
    } else {
        [self dismissModalViewControllerAnimated: YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([[[textView text] stringByReplacingCharactersInRange:range withString:text] length] > 50)
        return NO;
    return YES;
}

@end
