//
//  FacebookManager.h
//  46px
//
//  Created by Scott Andrus on 4/21/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

@interface FacebookManager : NSObject <FBSessionDelegate>
{
    Facebook * facebook;
}

@property (nonatomic, retain, readonly) Facebook * facebook;

- (void)login;
- (void)logout;

#pragma mark Singleton Implementation

+ (FacebookManager*)sharedManager;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (oneway void)release;
- (id)autorelease;

@end
