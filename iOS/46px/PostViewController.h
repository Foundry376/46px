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
@property (nonatomic, weak) PixelDrawing * drawing;

@property (strong, nonatomic) IBOutlet UIImageView *previewImage;
@property (strong, nonatomic) IBOutlet UITextView *captionTextView;
@property (strong, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView * spinner;

- (IBAction)post:(id)sender;
- (IBAction)cancel:(id)sender;

@end
