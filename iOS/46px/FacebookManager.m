//
//  FacebookManager.m
//  46px
//
//  Created by Scott Andrus on 4/21/12.
//  Copyright (c) 2012 Vanderbilt University. All rights reserved.
//

#import "FacebookManager.h"

static FacebookManager * sharedManager;

@implementation FacebookManager
@synthesize facebook;


#pragma mark Singleton Implementation

+ (FacebookManager*)sharedManager
{
    @synchronized(self) {
        if (sharedManager== nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    //denotes an object that cannot be released
    return UINT_MAX;
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

-(id)init
{
    if((self = [super init]))
    {
        facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        /*
        if (![facebook isSessionValid]) {
            [facebook authorize:nil];
        }*/

    }
    return self;
}


- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}

- (void)fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)login
{
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmm..."
                                                        message:[NSString stringWithFormat:@"You are already logged in to Facebook."]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)logout
{
    if ([facebook isSessionValid]) {
        [facebook logout];
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:[NSString stringWithFormat:@"You have been logged out of Facebook."]
                                                            delegate:nil
                                                            cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hmm..."
                                                        message:[NSString stringWithFormat:@"You are not logged in to Facebook."]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


@end
