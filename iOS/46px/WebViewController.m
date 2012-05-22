//
//  WebViewController.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "APIConnector.h"

@implementation WebViewController
@synthesize webView;
@synthesize backgroundView;
@synthesize otherBackgroundView;

- (id)initWithPage:(NSURL*)u
{
    self = [super init];
    if (self) {
        url = [u retain];
        self.title = @"Loading...";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView loadRequest: [NSURLRequest requestWithURL: url]];
    [[webView scrollView] setBounces: NO];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setBackgroundView:nil];
    [self setOtherBackgroundView:nil];
    [self setOtherBackgroundView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [webView reload];
}

- (void)viewWillLayoutSubviews {
    
    if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        [self.backgroundView setFrame:CGRectMake(0, 0, 768, 1060)];
        self.otherBackgroundView.hidden = YES;
    }
    else {
        [self.backgroundView setFrame:CGRectMake(0, 0, 784, 704)];
        self.otherBackgroundView.hidden = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc 
{
    [url release];
    [webView release];
    [backgroundView release];
    [otherBackgroundView release];
    [otherBackgroundView release];
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    NSString * pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([pageTitle length] > 0)
        self.navigationItem.title = pageTitle;
    else
        self.navigationItem.title = @"Thread";
    
    if (editing) {
        [wv stringByEvaluatingJavaScriptFromString:@"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);"];
        editing = NO;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"fortysix"]) {
        NSString * path = [[request URL] absoluteString];
        
        int lastDelimiter = [path rangeOfString:@"---" options:NSBackwardsSearch].location;
        int prevDelimiter = [path rangeOfString:@"---" options:NSBackwardsSearch range:NSMakeRange(0, lastDelimiter)].location;
        
        NSString * threadID = [path substringFromIndex:lastDelimiter + 3];
        NSString * sourceImageURL = [path substringWithRange:NSMakeRange(prevDelimiter + 3, lastDelimiter - (prevDelimiter + 3))];
        if ([sourceImageURL rangeOfString:@"http://"].location == NSNotFound)   
            sourceImageURL = [@"http://www.46px.com" stringByAppendingString:sourceImageURL];
        
        NSString * dir = [[APIConnector shared] pathForNewDrawing];
        
        PixelDrawing * d = [[[PixelDrawing alloc] initWithSize:CGSizeMake(46, 46) andDirectory:dir] autorelease];
        [d setThreadID: [threadID intValue]];
        
        PixelEditorViewController * c = [[[PixelEditorViewController alloc] initWithDrawing:d andDelegate:self] autorelease];
        [self.navigationController pushViewController:c animated:YES];
        if ([sourceImageURL length] > 0)
            [c downloadAndAddImage: sourceImageURL];
        
        editing = YES;
        return NO;
    }
    return YES;
}

- (NSString*)titleForPixelEditor:(PixelEditorViewController*)e
{
    return @"Draw a response!";
}

- (NSString*)commitButtonTitleForPixelEditor:(PixelEditorViewController*)e
{
    return @"Post Response";
}


@end
