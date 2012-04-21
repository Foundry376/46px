//
//  ViewController.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelEditorViewController.h"

@interface ViewController : UIViewController <PixelEditorDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet UIButton *draftOne;
@property (retain, nonatomic) IBOutlet UIButton *draftTwo;
@property (retain, nonatomic) IBOutlet UIButton *draftThree;
@property (retain, nonatomic) IBOutlet UIButton *draftFour;
@property (retain, nonatomic) IBOutlet UIButton *draftFive;
@property (retain, nonatomic) IBOutlet UIButton *draftSix;

@end
