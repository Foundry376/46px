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
    BOOL editing;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;
@property (retain, nonatomic) IBOutlet UIImageView *otherBackgroundView;

- (id)initWithPage:(NSURL*)u;

@end
