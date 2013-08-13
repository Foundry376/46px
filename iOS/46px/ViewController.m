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


@implementation ViewController

@synthesize webView;
@synthesize profilePicture;
@synthesize userName;
@synthesize loginButton;
@synthesize logoutButton;
@synthesize userPostCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setClipsToBounds: YES];
    [self.collectionView registerClass:[DrawingCollectionViewCell class] forCellWithReuseIdentifier:@"DrawingCollectionViewCell"];
    [self.collectionView setAlwaysBounceVertical: YES];
    
    [self gotoHome];
    [[webView scrollView] setBounces: NO];
    
    // Listen for images being posted successfully
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSuccess:) name:@"PostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUser:) name:@"UpdateUser" object:nil];
    
    [self.navigationItem setTitleView: [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"header.png"]]];
    
    // update the interface to show the currently logged in user (if there is one)
    [self updateUser: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self layoutForOrientation: self.interfaceOrientation];
    
    // Load in facebook user information
    Facebook * facebook = [FacebookManager sharedManager].facebook;
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [webView reload];
    
    // Reload the drafts
    [_collectionView reloadData];
}

- (IBAction)gotoHome
{
    NSString *urlAddress = [NSString stringWithFormat: @"http://46px.com/index.php?46px_user_id=%@", [[FacebookManager sharedManager] facebookUserID]];
    [self webViewLoad: [NSURL URLWithString:urlAddress]];
}

- (void)gotoMyDrawings
{
    NSString *urlAddress = [NSString stringWithFormat: @"http://46px.com/index.php?46px_user_id=%@&mine=true", [[FacebookManager sharedManager] facebookUserID]];
    [self webViewLoad: [NSURL URLWithString:urlAddress]];
}

- (void)webViewLoad:(NSURL*)url
{
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [_webFailedView setHidden: YES];
    [_webLoadingView setHidden: NO];
    
    _webFailTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(webViewFailed:) userInfo:nil repeats:NO];
}

- (void)webViewFailed:(NSTimer*)timer
{
    _webFailTimer = nil;
    if ([_webLoadingView isHidden] == NO) {
        [_webLoadingView setHidden: YES];
        [_webFailedView setHidden: NO];
    }
}

- (void)layoutForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [_sidebarContainerView setFrame: CGRectMake(0, self.view.frame.size.height - 205, self.view.frame.size.width, 205)];
        [_sidebarBackgroundView setFrame: _sidebarContainerView.bounds];
        [_sidebarBackgroundView setImage: [UIImage imageNamed: @"home_sidebar_background_portrait.png"]];
        [_collectionView setFrame: CGRectMake(292, 0, self.view.frame.size.width - 290, 205)];
        [webView setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 205)];
        [_webViewBackground setFrame: webView.frame];
        [_startDrawingButton setFrame: CGRectMake(13, 120, 270, 60)];
        [_sidebarShadowView setFrame: CGRectMake(0, self.view.frame.size.height - 205 - 20, 768, 20)];
        [_sidebarShadowView setHidden:NO];
    } else {
        [_sidebarContainerView setFrame: CGRectMake(0, 0, 300, self.view.frame.size.height)];
        [_sidebarBackgroundView setFrame: _sidebarContainerView.bounds];
        [_sidebarBackgroundView setImage: [UIImage imageNamed: @"home_sidebar_background_landscape.png"]];
        [_collectionView setFrame: CGRectMake(0, 192, 300, 466)];
        [webView setFrame: CGRectMake(300, 0, self.view.frame.size.width-300, self.view.frame.size.height)];
        [_webViewBackground setFrame: webView.frame];
        [_startDrawingButton setFrame: CGRectMake(13, 114, 273, 60)];
        [_sidebarShadowView setHidden:YES];
    }
}


- (IBAction)start:(id)sender
{    
    // ask for a folder that we can put our new drawing into
    NSString * dir = [[APIConnector shared] pathForNewDrawing];
    
    // create the new drawing, and add it to our drafts
    PixelDrawing * d = [[PixelDrawing alloc] initWithSize: CGSizeMake(46, 46) andDirectory: dir];
    [[[APIConnector shared] drafts] addObject: d];
    
    // open the editing view controller and go!
    PixelEditorViewController * pevc = [[PixelEditorViewController alloc] initWithDrawing: d andDelegate: self];
    [self.navigationController pushViewController:pevc animated:YES];
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
}

- (IBAction)logoutPressed:(id)sender 
{
    [[FacebookManager sharedManager] logout];
}

- (void)updateUser:(NSNotification*)notif
{
    NSDictionary * userDict =[[FacebookManager sharedManager] facebookUserDictionary];
    if (userDict) {
        NSString * urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=156&height=156", [[FacebookManager sharedManager] facebookUserID]];
        NSData *imgUrl = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        [profilePicture setImage:[UIImage imageWithData:imgUrl]];
    
        NSLog(@"%@", [userDict description]);
        NSString * fn = [userDict objectForKey:@"first_name"];
        NSString * ln = [userDict objectForKey:@"last_name"];
        
        [userName setText: [NSString stringWithFormat:@"%@ %@", fn, ln]];
        [loginButton setHidden: YES];
        [self gotoHome];
        
        UIBarButtonItem * myDrawings = [[UIBarButtonItem alloc] initWithTitle:@"My Published Drawings" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoMyDrawings)];
        [self.navigationItem setRightBarButtonItem:myDrawings animated:YES];
        
    } else {
        [userName setText: @"Anonymous"];
        [profilePicture setImage: [UIImage imageNamed:@"anonymous.png"]];
        [loginButton setHidden: NO];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)viewDidUnload
{
    [self setProfilePicture:nil];
    [self setLoginButton:nil];
    [self setLogoutButton:nil];
    [self setUserName:nil];
    [self setUserPostCount:nil];
    [self setCollectionView:nil];
    [self setSidebarContainerView:nil];
    [self setSidebarBackgroundView:nil];
    [self setWebViewBackground:nil];
    [self setStartDrawingButton:nil];
    [self setSidebarShadowView:nil];
    [self setWebLoadingView:nil];
    [self setWebFailedView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutForOrientation: self.interfaceOrientation];
}


#pragma mark -
#pragma mark UICollectionView Delegate Functionality
     
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // create the new drawing, and add it to our drafts
    PixelDrawing * d = [[[APIConnector shared] drafts] objectAtIndex: [indexPath row]];
    
    // open the editing view controller and go!
    PixelEditorViewController * pevc = [[PixelEditorViewController alloc] initWithDrawing: d andDelegate: self];
    [self.navigationController pushViewController:pevc animated:YES];
}

- (void)collectionViewCellLongPress:(UILongPressGestureRecognizer*)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        _pendingDeleteIndex = [[recognizer view] tag];
        [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Delete this drawing permanently?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
    }
}

- (int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[APIConnector shared] drafts] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PixelDrawing * d = [[[APIConnector shared] drafts] objectAtIndex: [indexPath row]];
    DrawingCollectionViewCell * c = [collectionView dequeueReusableCellWithReuseIdentifier:@"DrawingCollectionViewCell" forIndexPath:indexPath];

    if ([[c gestureRecognizers] count] == 0)
        [c addGestureRecognizer: [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewCellLongPress:)]];

    [c setTag: [indexPath row]];
    [c setDrawing: d];

    return c;
}


#pragma mark -
#pragma mark UIWebView Delegate Functionality

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_webLoadingView setHidden: YES];
    [_webFailedView setHidden: YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * path = [[request URL] absoluteString];
    if ([path rangeOfString:@"thread.php"].location != NSNotFound) {
        // open it in a new web view!
        WebViewController * wvc = [[WebViewController alloc] initWithPage: [request URL]];
        [self.navigationController pushViewController:wvc animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark UIAlertView Functionality

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [[[APIConnector shared] drafts] removeObjectAtIndex: _pendingDeleteIndex];
        _pendingDeleteIndex = NSNotFound;
        [_collectionView reloadData];
    }
}

@end
