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
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"fortysix"]) {
        NSString * path = [[request URL] absoluteString];
        NSString * threadID = [path substringFromIndex:[path rangeOfString:@"edit:"].location + 5];
        
        NSString * dir = [[APIConnector shared] pathForNewDrawing];
        PixelDrawing * d = [[[PixelDrawing alloc] initWithSize:CGSizeMake(46, 46) andDirectory:dir] autorelease];
        [d setThreadID: [threadID intValue]];
        
        PixelEditorViewController * c = [[[PixelEditorViewController alloc] initWithDrawing:d andDelegate:self] autorelease];
        [self.navigationController pushViewController:c animated:YES];
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
