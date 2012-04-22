//
//  WebViewController.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelEditorViewController.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, PixelEditorDelegate>
{
    NSURL * url;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (id)initWithPage:(NSURL*)u;

@end
