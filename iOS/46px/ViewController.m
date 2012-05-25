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

@property (retain, nonatomic) NSMutableOrderedSet *drafts;

@end

@implementation ViewController

@synthesize webView;
@synthesize sideBar;
@synthesize backgroundView;
@synthesize drawButton;
@synthesize profilePicture;
@synthesize userName;
@synthesize loginButton;
@synthesize logoutButton;
@synthesize draftLabel;
@synthesize clearButton;
@synthesize draftScrollView;
@synthesize drafts = _drafts;

- (NSMutableOrderedSet *)drafts {
    if (!_drafts) {
        _drafts = [[NSMutableOrderedSet alloc] init];
    }
    return _drafts;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *urlAddress = [NSString stringWithFormat: @"http://46px.com/index.php?46px_user_id=%@", [[FacebookManager sharedManager] facebookUserID]];
    
    // Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    // URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    // Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    [[webView scrollView] setBounces: NO];
    
    // Listen for images being posted successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSuccess:) name:@"PostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:@"UpdateUser" object:nil];
    
    // update the interface to show the currently logged in user (if there is one)
    [self updateUser: nil];
}

- (void)viewWillAppear:(BOOL)animated
{

    [self manageDrafts];
    
    // Load in facebook user information
    Facebook * facebook = [FacebookManager sharedManager].facebook;
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [webView reload];
    self.title = @"46px";
    
}

- (void)viewWillLayoutSubviews {
    
    if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        [self.sideBar setImage:[UIImage imageNamed:@"home_sidebar_background_portrait.png"]];
        [self.backgroundView setFrame:CGRectMake(0, 240, 784, 784)];
        [self.sideBar setFrame:CGRectMake(0, 0, 768, 240)];
        [self.profilePicture setFrame:CGRectMake(14, 14, 80, 80)];
        [self.loginButton setFrame:CGRectMake(5, 8, 240, 92)];
        [self.userName setFrame:CGRectMake(111, 14, 128, 26)];
        [self.logoutButton setFrame:CGRectMake(111, 48, 79, 37)];
        [self.drawButton setFrame:CGRectMake(26, 154, 206, 60)];
        [self.draftLabel setFrame:CGRectMake(423, 35, 167, 21)];
        [self.clearButton setFrame:CGRectMake(446, 182, 120, 37)];
    }
    else {
        
        [self.loginButton setFrame:CGRectMake(784, 0, 240, 92)];
        [self.userName setFrame:CGRectMake(880, 11, 128, 26)];
        [self.logoutButton setFrame:CGRectMake(880, 48, 79, 37)];
        [self.drawButton setFrame:CGRectMake(802, 115, 206, 60)];
        [self.draftLabel setFrame:CGRectMake(821, 217, 167, 21)];
        [self.clearButton setFrame:CGRectMake(844, 650, 120, 37)];
        [self.sideBar setImage:[UIImage imageNamed:@"home_sidebar_background.png"]];
        [self.backgroundView setFrame:CGRectMake(0, 0, 784, 704)];
        [self.sideBar setFrame:CGRectMake(784, 0, 240, 704)];
        [self.profilePicture setFrame:CGRectMake(795, 5, 80, 80)];
        
    }
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
    [TestFlight passCheckpoint:@"NewDrawingOpened"];

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
    
    [TestFlight passCheckpoint:@"ExistingDrawingOpened"];
    
    NSUInteger drawingToLoad = [self.drafts indexOfObject:sender];
    
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
    [TestFlight passCheckpoint:@"UserStartedLogin"];
    [[FacebookManager sharedManager] login];
    profilePicture.hidden = NO;
}

- (IBAction)logoutPressed:(id)sender 
{
    [[FacebookManager sharedManager] logout];
    profilePicture.hidden = YES;
}

- (IBAction)clearPressed:(id)sender 
{
    APIConnector *curDrafts = [APIConnector shared];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"drafts"];
    if ([[curDrafts drafts] count] != 0) {
        for (int i = [[curDrafts drafts] count] - 1; [[curDrafts drafts] count] != 0; i--) {
            UIButton * button = [self.drafts objectAtIndex:i];
            button.hidden = YES;
            [curDrafts removeFromCache:[[curDrafts drafts] objectAtIndex:i]];
        }
    }
    self.drafts = nil;
    [self reloadInputViews];
    [self manageDrafts];

}

- (void)updateUser:(NSNotification*)notif
{
    NSDictionary * userDict =[[FacebookManager sharedManager] facebookUserDictionary];
    if (userDict) {
        NSString * urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[FacebookManager sharedManager] facebookUserID]];
        NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        [profilePicture setImage:[UIImage imageWithData:imgUrl]];
    
        NSLog(@"%@", [userDict description]);
        NSString * fn = [userDict objectForKey:@"first_name"];
        NSString * ln = [userDict objectForKey:@"last_name"];
        
        [userName setText: [NSString stringWithFormat:@"%@ %@", fn, ln]];
        [loginButton setHidden: YES];
        
    } else {
        [loginButton setHidden: NO];
    }
}

- (void)manageDrafts 
{   
    
    size_t increment = 0;
    
    BOOL left = YES;
    
    UIButton * curButton;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"]) {
        self.drafts = nil;
        CGFloat xspace = 10;
        CGFloat yspace = 10;
        for (increment = 0; increment < 20; ++increment) {
        
            curButton = [[UIButton alloc] initWithFrame:CGRectMake(xspace, yspace, 100, 100)];
            
            if (left) {
                xspace += 120;
                left = NO;
            }
            else {
                xspace -= 120;
                left = YES;
            }
            
            if (increment % 2) {
                yspace += 100;
            }
            
            curButton.hidden = YES;
            curButton.clipsToBounds = YES;
            
            [curButton addTarget:self action:@selector(draftSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.drafts addObject:curButton];
            [self.draftScrollView addSubview:curButton];
            [[NSUserDefaults standardUserDefaults] setObject:self.drafts forKey:@"drafts"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
        }
    }
    else {
        self.drafts = [[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"];
    }
        
    for (increment = 0; increment < [[[APIConnector shared] drafts] count]; ++increment) {
        curButton = [self.drafts objectAtIndex:increment];
        PixelDrawing *d = [[[APIConnector shared] drafts] objectAtIndex:increment];

        [curButton setImage:[d image] forState:UIControlStateNormal];
        [curButton setImage:[d image] forState:UIControlStateHighlighted];
        curButton.adjustsImageWhenHighlighted = NO;
        curButton.hidden = NO;
    }
//    for (size_t i = increment; i < [buttonArray count]; ++i) {
//        curButton = [buttonArray objectAtIndex:i];
//        curButton.hidden = YES;
//    }

}

- (void)viewDidUnload
{
    [self setProfilePicture:nil];
    [self setLoginButton:nil];
    [self setLogoutButton:nil];
    [self setUserName:nil];
    [self setSideBar:nil];
    [self setBackgroundView:nil];
    [self setDrawButton:nil];
    [self setDraftLabel:nil];
    [self setClearButton:nil];
    [self setDraftScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc 
{
    [profilePicture release];
    [loginButton release];
    [logoutButton release];
    [userName release];
    [sideBar release];
    [backgroundView release];
    [drawButton release];
    [draftLabel release];
    [clearButton release];
    [draftScrollView release];
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
