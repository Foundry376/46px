//
//  ViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PixelEditorViewController.h"
#import "WebViewController.h"
#import "PixelDrawing.h"
#import "APIConnector.h"
#import "FacebookManager.h"
#import "PostViewController.h"
#import <QuartzCore/QuartzCore.h>

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
@synthesize profilePicture;
@synthesize userName;
@synthesize loginButton;
@synthesize logoutButton;
@synthesize userPostCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *urlAddress = @"http://46px.com/index.php";
    
    // Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    // URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    // Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    [[webView scrollView] setBounces: NO];
    
    // Listen for images being posted successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSuccess:) name:@"PostSuccess" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
//    NSMutableArray *buttonArray = [NSMutableArray arrayWithCapacity:6];
//    [buttonArray addObject:draftOne];
//    [buttonArray addObject:draftTwo];
//    [buttonArray addObject:draftThree];
//    [buttonArray addObject:draftFour];
//    [buttonArray addObject:draftFive];
//    [buttonArray addObject:draftSix];
//    size_t increment = 0;
//    
//    UIButton *curButton;
//    
//    for (size_t i = 0; i < [[[APIConnector shared] drafts] count]; ++i) {
//        if (i >= 6) {
//            break;
//        }
//        increment++;
//        PixelDrawing *d = [[[APIConnector shared] drafts] objectAtIndex:i];
//        
//        curButton = [buttonArray objectAtIndex:i];
//        
//        curButton.layer.cornerRadius = 9;
//        curButton.clipsToBounds = YES;
//        
//        curButton.layer.borderColor = [[UIColor grayColor] CGColor];
//        curButton.layer.borderWidth = .5;
//        [curButton setImage:[d image] forState:UIControlStateNormal];
//        [curButton setImage:[d image] forState:UIControlStateHighlighted];
//        curButton.adjustsImageWhenHighlighted = NO;
//    }
//    for (size_t i = increment; i < [buttonArray count]; ++i) {
//        curButton = [buttonArray objectAtIndex:i];
//        curButton.hidden = YES;
//    }

    [self manageDrafts];
    
    // Load in facebook user information
    Facebook * facebook = [FacebookManager sharedManager].facebook;
    [facebook requestWithGraphPath:@"me/picture" andDelegate:self];
    [facebook requestWithGraphPath:@"me/name" andDelegate:self];
    [webView reload];
    
}

- (void)applicationDidEnterForeground
{
    NSLog(@"DidReturn");
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

- (void)postSuccess:(NSNotification*)n
{ 
    [self performSelector:@selector(postSuccessDismissEditor:) withObject:[n object] afterDelay:0.8];
}

- (void)postSuccessDismissEditor:(NSString*)path
{   
    NSArray * vcs = [self.navigationController viewControllers];
    if ([[vcs objectAtIndex: [vcs count] - 2] isKindOfClass:[WebViewController class]])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popToRootViewControllerAnimated: YES];
}

- (IBAction)loginPressed:(id)sender 
{
    [[FacebookManager sharedManager] login];
    profilePicture.hidden = NO;
}

- (IBAction)logoutPressed:(id)sender {
    [[FacebookManager sharedManager] logout];
    profilePicture.hidden = YES;
}

- (IBAction)clearPressed:(id)sender {
    APIConnector *curDrafts = [APIConnector shared];
    
    if ([[curDrafts drafts] count] != 0) {
        for (size_t i = 0; i < [[curDrafts drafts] count]; ++i) {
            [curDrafts removeFromCache:[[curDrafts drafts] objectAtIndex:i]];
        }
        [self manageDrafts];
    }
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Requestdidfail");
    NSLog(@"error:%@",[error localizedDescription]);
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSString * urlString = [[response URL]absoluteString];
    // This is a picture
    if (!([request.url rangeOfString:@"me/picture"].location == NSNotFound)) {
        NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        [profilePicture setImage:[UIImage imageWithData:imgUrl]];
    } 
    // This is a name
    else if (!([request.url rangeOfString:@"me/firstname"].location == NSNotFound)) {
        userName.text = urlString;
    }
    
}
-(void)request:(FBRequest *)request didLoad:(id)result
{
    NSDictionary * userDict =(NSDictionary*)result;
    [userDict objectForKey:@"first_name"];
    
}

- (void)manageDrafts {
    
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
        if (i >= 6) {
            break;
        }
        increment++;
        PixelDrawing *d = [[[APIConnector shared] drafts] objectAtIndex:i];
    
        
        curButton = [buttonArray objectAtIndex:i];
        curButton.hidden = NO;
//        
//        curButton.layer.cornerRadius = 9;
        curButton.clipsToBounds = YES;
//        
//        curButton.layer.borderColor = [[UIColor grayColor] CGColor];
//        curButton.layer.borderWidth = .5;
        [curButton setImage:[d image] forState:UIControlStateNormal];
        [curButton setImage:[d image] forState:UIControlStateHighlighted];
        curButton.adjustsImageWhenHighlighted = NO;
    }
    for (size_t i = increment; i < [buttonArray count]; ++i) {
        curButton = [buttonArray objectAtIndex:i];
        curButton.hidden = YES;
    }

}

- (void)viewDidUnload
{
    [self setDraftOne:nil];
    [self setDraftTwo:nil];
    [self setDraftThree:nil];
    [self setDraftFour:nil];
    [self setDraftFive:nil];
    [self setDraftSix:nil];
    [self setProfilePicture:nil];
    [self setLoginButton:nil];
    [self setLogoutButton:nil];
    [self setUserName:nil];
    [self setUserPostCount:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc 
{
    [draftOne release];
    [draftTwo release];
    [draftThree release];
    [draftFour release];
    [draftFive release];
    [draftSix release];
    [profilePicture release];
    [loginButton release];
    [logoutButton release];
    [userName release];
    [userPostCount release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIWebView Delegate Functionality



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * path = [[request URL] absoluteString];
    if ([path rangeOfString:@"thread.php"].location != NSNotFound) {
        // open it in a new web view!
        WebViewController * wvc = [[WebViewController alloc] initWithPage: [request URL]];
        [self.navigationController pushViewController:wvc animated:YES];
        [wvc autorelease];        
        return NO;
    }
    return YES;
}

@end
