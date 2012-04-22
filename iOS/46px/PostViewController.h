//
//  PostViewController.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixelDrawing.h"
#import "ViewController.h"

@interface PostViewController : UIViewController <UITextViewDelegate>
{
    
}
@property (nonatomic, assign) PixelDrawing * drawing;

@property (retain, nonatomic) IBOutlet UIImageView *previewImage;
@property (retain, nonatomic) IBOutlet UITextView *captionTextView;
@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView * spinner;

- (IBAction)post:(id)sender;
- (IBAction)cancel:(id)sender;

@end
