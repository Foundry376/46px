//
//  ViewController.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelEditorViewController.h"
#import "FBConnect.h"

@interface ViewController : UIViewController <UIWebViewDelegate, PixelEditorDelegate, FBRequestDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIImageView *sideBar;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;
@property (retain, nonatomic) IBOutlet UIImageView *drawButton;

@property (retain, nonatomic) IBOutlet UIImageView *profilePicture;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;
@property (retain, nonatomic) IBOutlet UILabel *draftLabel;
@property (retain, nonatomic) IBOutlet UIButton *clearButton;

@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIScrollView *draftScrollView;

- (void)manageDrafts;

@end
