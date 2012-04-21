//
//  AppDelegate.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"


@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>
{
    Facebook * facebook;
}

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) Facebook * facebook;
@property (strong, nonatomic) UINavigationController * viewController;

@end
