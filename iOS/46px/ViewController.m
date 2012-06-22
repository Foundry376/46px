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
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "UserProfileViewController.h"

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
@synthesize scrollPageControl;
@synthesize drafts = _drafts;
@synthesize internetReachable = _internetReachable;
@synthesize hostReachable = _hostReachable;
@synthesize internetActive;
@synthesize hostActive;

- (NSMutableOrderedSet *)drafts {
    if (!_drafts) {
        _drafts = [[NSMutableOrderedSet alloc] init];
    }
    return _drafts;
}


- (void)viewDidLoad
{
    self.scrollPageControl.hidden = YES;
    [super viewDidLoad];
    NSString *urlAddress = [NSString stringWithFormat: @"http://46px.com/index.php?46px_user_id=%@", [[FacebookManager sharedManager] facebookUserID]];
    
    // Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    // URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    // Load the request in the UIWebView.
    [SVProgressHUD showWithStatus:@"Loading pixels..."];
    [webView loadRequest:requestObj];
    [[webView scrollView] setBounces: NO];
    
    // Listen for images being posted successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSuccess:) name:@"PostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:@"UpdateUser" object:nil];
    
    // update the interface to show the currently logged in user (if there is one)
    [self updateUser: nil];
    
    // Customize User Panel UI
    self.profilePicture.layer.cornerRadius = 3;
    self.profilePicture.layer.borderColor = [[UIColor colorWithRed:0.859 green:0.859 blue:0.859 alpha:1] CGColor];
    self.profilePicture.layer.borderWidth = 5;
    self.profilePicture.clipsToBounds = YES;
    self.userName.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.draftLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewWillAppear:(BOOL)animated
{

    [self viewWillLayoutSubviews];
    
    // Load in facebook user information
    Facebook * facebook = [FacebookManager sharedManager].facebook;
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [webView reload];
    self.title = @"46px";
    
    // Reachability stuff:
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [self.internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    self.hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [self.hostReachable startNotifier];
    
//    BOOL webViewActive = YES;
//    if (![[self.view subviews] containsObject:self.webView]) {
//        webViewActive = NO;
//    }
//    if (!self.internetActive || !self.hostActive) {
//        if (webViewActive) {
//            [self.webView removeFromSuperview];
//        }
//    }
//    else {
//
//        if (!webViewActive) {
//            [self.view addSubview:self.webView];
//        }
//    }
    
}

- (void)viewWillLayoutSubviews {
    
    // Grab the content size of the current draft scrollview
    CGSize scrollContentSize;
    scrollContentSize = self.draftScrollView.contentSize;
    
    // If portrait, change subviews
    if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        [self.sideBar setImage:[UIImage imageNamed:@"home_sidebar_background_portrait_2.png"]];
        [self.backgroundView setFrame:CGRectMake(0, 240, 784, 784)];
        [self.sideBar setFrame:CGRectMake(0, 0, 768, 260)];
        [self.profilePicture setFrame:CGRectMake(14, 34, 80, 80)];
        [self.loginButton setFrame:CGRectMake(5, 28, 240, 92)];
        [self.userName setFrame:CGRectMake(111, 34, 128, 26)];
        [self.logoutButton setFrame:CGRectMake(111, 68, 79, 37)];
        [self.drawButton setFrame:CGRectMake(26, 154, 206, 60)];
        [self.draftLabel setFrame:CGRectMake(264, 50, 90, 21)];
        [self.clearButton setFrame:CGRectMake(264, 140, 90, 37)];

        [self.draftScrollView setFrame:CGRectMake(360, 15, 400, 200)];
        [self.draftScrollView setContentSize:CGSizeMake(scrollContentSize.height, scrollContentSize.width)];
        [self.backgroundView setImage:[UIImage imageNamed:@"home_gallery_background_portrait_2.png"]];
    }
    // Else, lock in subviews for landscape or change to landscape.
    else {
        
        [self.loginButton setFrame:CGRectMake(784, 5, 240, 92)];
        [self.userName setFrame:CGRectMake(880, 16, 128, 26)];
        [self.logoutButton setFrame:CGRectMake(880, 48, 79, 37)];
        [self.drawButton setFrame:CGRectMake(802, 115, 206, 60)];
        [self.draftLabel setFrame:CGRectMake(818, 196, 167, 21)];
        [self.clearButton setFrame:CGRectMake(844, 650, 120, 37)];
        [self.sideBar setImage:[UIImage imageNamed:@"home_sidebar_background_2.png"]];
        [self.backgroundView setFrame:CGRectMake(0, 0, 784, 704)];
        [self.sideBar setFrame:CGRectMake(764, 0, 260, 704)];
        [self.profilePicture setFrame:CGRectMake(795, 10, 80, 80)];
        
        [self.draftScrollView setFrame:CGRectMake(794, 225, 240, 400)];
        [self.draftScrollView setContentSize:CGSizeMake(scrollContentSize.height, scrollContentSize.width)];
        [self.backgroundView setImage:[UIImage imageNamed:@"home_gallery_background_2.png"]];
    }
    
    // Manage the drafts
    [self manageDrafts];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)applicationDidEnterForeground
{
    NSLog(@"DidReturn");
}

- (IBAction)profilePressed:(id)sender {
    [TestFlight passCheckpoint:@"ProfileOpened"];
    
    // add new profile view controller to nav stack
    UserProfileViewController *upvc = [[UserProfileViewController alloc] init];
    upvc.userName = self.userName.text;
    [self.navigationController pushViewController:upvc animated:YES];
    [upvc autorelease];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.draftScrollView.delegate = self;
    CGFloat pageWidth;
    int page;
    if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        pageWidth = self.draftScrollView.frame.size.width;
        page = floor((self.draftScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    } else {
        pageWidth = self.draftScrollView.frame.size.height;
        page = floor((self.draftScrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
    }
    self.scrollPageControl.currentPage = page;
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
            [curDrafts removeFromCache:[[curDrafts drafts] objectAtIndex:i]];
        }
    }
    for (UIButton *button in self.drafts) {
        [button removeFromSuperview];
    }
    self.drafts = nil;
    //[self reloadInputViews];
    [self manageDrafts];

}

- (IBAction)removeDraftPressed:(id)sender {
    UIButton *curButton = sender;
    [self.drafts removeObject:curButton];
    curButton = [UIButton buttonWithType:UIButtonTypeCustom];
    curButton.frame = CGRectMake(0, 0, 80, 80);
    curButton.layer.cornerRadius = 4;
    curButton.layer.borderColor = [[UIColor colorWithRed:0.859 green:0.859 blue:0.859 alpha:1] CGColor];
    curButton.layer.borderWidth = 5;
    curButton.hidden = YES;
    curButton.clipsToBounds = YES;
    
    [curButton addTarget:self action:@selector(draftSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.drafts addObject:curButton];
    [self.draftScrollView addSubview:curButton];
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
    [SVProgressHUD showWithStatus:@"Pixelating drafts..."];
    size_t increment = 0;
    
    BOOL left = YES;
    
    UIButton * curButton;
    
    // Create 24 buttons, hide all, save in NSUserDefaults
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"]) {
        for (UIButton * button in self.drafts) {
            [button removeFromSuperview];
        }
        self.drafts = nil;
        CGFloat xspace = 20;
        CGFloat yspace = 10;
        for (increment = 0; increment < 24; ++increment) {
//            curButton = [[UIButton alloc] initWithFrame:CGRectMake(xspace, yspace, 100, 100)];
            curButton = [UIButton buttonWithType:UIButtonTypeCustom];
            curButton.frame = CGRectMake(xspace, yspace, 80, 80);
            
            if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
                if (left) {
                    yspace += 96;
                    left = NO;
                }
                else {
                    yspace -= 96;
                    left = YES;
                }
                if (increment % 2) {
                    xspace += 100;
                }
            }
            
            else {
                if (left) {
                    xspace += 96;
                    left = NO;
                }
                else {
                    xspace -= 96;
                    left = YES;
                }
                if (increment % 2) {
                    yspace += 100;
                }
            }
            
            curButton.layer.cornerRadius = 4;
            curButton.layer.borderColor = [[UIColor colorWithRed:0.859 green:0.859 blue:0.859 alpha:1] CGColor];
            curButton.layer.borderWidth = 5;
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
    
    // Unhide active buttons
    for (increment = 0; increment < [[[APIConnector shared] drafts] count]; ++increment) {
        curButton = [self.drafts objectAtIndex:increment];
        PixelDrawing *d = [[[APIConnector shared] drafts] objectAtIndex:increment];

        [curButton setBackgroundImage:[d image] forState:UIControlStateNormal];
        [curButton setBackgroundImage:[d image] forState:UIControlStateHighlighted];
        curButton.adjustsImageWhenHighlighted = NO;
        curButton.hidden = NO;
    }
    CGRect tempFrame = self.draftScrollView.frame;
    
    // Add more space in the ScrollView if the count exceeds 8
    if ([[[APIConnector shared] drafts] count] > 8) {
        if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            CGSize content = CGSizeMake((tempFrame.size.width + ([[[APIConnector shared] drafts] count] / 8 * tempFrame.size.width)), tempFrame.size.height);
            self.draftScrollView.contentSize = content;
            [self.draftScrollView scrollRectToVisible:CGRectMake(0, tempFrame.size.height, tempFrame.size.width * ([[[APIConnector shared] drafts] count] / 8), tempFrame.size.height) animated:YES];
        }
        else {
            CGSize content = CGSizeMake(tempFrame.size.width, (tempFrame.size.height + ([[[APIConnector shared] drafts] count] / 8 * tempFrame.size.height)));
            self.draftScrollView.contentSize = content;
            [self.draftScrollView scrollRectToVisible:CGRectMake(0, tempFrame.size.height, tempFrame.size.width, tempFrame.size.height * ([[[APIConnector shared] drafts] count] / 8)) animated:YES];
        }

    }
    else {
        self.draftScrollView.contentSize = tempFrame.size;
    }
    [SVProgressHUD dismiss];

}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [self.hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            
            break;
        }
    }
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
    [self setScrollPageControl:nil];
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
    [scrollPageControl release];
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
