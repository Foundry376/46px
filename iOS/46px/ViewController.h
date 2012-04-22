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

@interface ViewController : UIViewController <UIWebViewDelegate, PixelEditorDelegate, FBRequestDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet UIButton *draftOne;
@property (retain, nonatomic) IBOutlet UIButton *draftTwo;
@property (retain, nonatomic) IBOutlet UIButton *draftThree;
@property (retain, nonatomic) IBOutlet UIButton *draftFour;
@property (retain, nonatomic) IBOutlet UIButton *draftFive;
@property (retain, nonatomic) IBOutlet UIButton *draftSix;

@property (retain, nonatomic) IBOutlet UIImageView *profilePicture;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;

@property (retain, nonatomic) IBOutlet UILabel *userPostCount;

- (void)postVisitURL:(NSString*)u;

@end
