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

- (id)initWithPage:(NSURL*)u
{
    self = [super init];
    if (self) {
        url = [u retain];
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
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [webView reload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc 
{
    [url release];
    [webView release];
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
