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
#import "DrawingCollectionViewCell.h"
#import "OrangeButton.h"

@interface ViewController : UIViewController <UIWebViewDelegate, PixelEditorDelegate, FBRequestDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    int _pendingDeleteIndex;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *webViewBackground;
@property (weak, nonatomic) IBOutlet UIView *sidebarContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *sidebarBackgroundView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userPostCount;
@property (weak, nonatomic) IBOutlet OrangeButton *startDrawingButton;


@end
