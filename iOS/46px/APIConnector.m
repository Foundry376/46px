//
//  APIConnector.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIConnector.h"
#import "PixelDrawing.h"
#import "ASIFormDataRequest.h"
#import "FacebookManager.h"

static APIConnector * sharedConnector;


@implementation APIConnector

@synthesize drafts;

#pragma mark Singleton Implementation

+ (APIConnector*)shared
{
    @synchronized(self) {
        if (sharedConnector== nil) {
            sharedConnector = [[self alloc] init];
        }
    }
    return sharedConnector;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedConnector == nil) {
            sharedConnector = [super allocWithZone:zone];
            return sharedConnector;
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

#pragma mark Standard Functionality

- (id)init
{
    if (self = [super init]){
        drafts = [[NSMutableArray alloc] init];
        
        // load all of the existing drawings in the drafts folder
        NSString * draftsFolder = [@"~/Documents/Drafts" stringByExpandingTildeInPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath: draftsFolder] == NO)
            [[NSFileManager defaultManager] createDirectoryAtPath:draftsFolder withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSArray * draftFilenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:draftsFolder error:nil];
        for (NSString * f in draftFilenames) {
            PixelDrawing * d = [[PixelDrawing alloc] initWithDirectory: [draftsFolder stringByAppendingPathComponent: f]];
            [drafts addObject: [d autorelease]];
        }
        
        NSLog(@"Loaded %d Saved Drawings: ", [drafts count]);
        NSLog(@"%@", [drafts description]);
    }
    return self;
}

- (NSString*)pathForNewDrawing
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY h.mm.ss a"];
    NSString *dateString = [dateFormat stringFromDate:today];
    [dateFormat release];
    
    NSString * draftsFolder = [@"~/Documents/Drafts" stringByExpandingTildeInPath];
    return [draftsFolder stringByAppendingPathComponent: dateString];
}

- (void)postDrawing:(PixelDrawing*)d
{
    NSURL * url = [NSURL URLWithString:@"http://46px.com/testForm.php"];
    
    ASIFormDataRequest * req = [[[ASIFormDataRequest alloc] initWithURL: url] autorelease];
    
    [req addPostValue:[[[FacebookManager sharedManager] facebook] accessToken] forKey:@"user_token"];
    [req addPostValue:[d caption] forKey:@"caption"];
    [req addPostValue:[d threadID] forKey:@"thread_id"];
    [req addData:UIImagePNGRepresentation(d.image) withFileName:@"image.png" andContentType: @"image/png" forKey:@"image"];
    [req setUserAgent:@"46px App"];
    [req addRequestHeader:@"Expect" value:@"100-Continue"];
    [req addRequestHeader:@"Content-Encoding" value:@"identity"];
    [req addRequestHeader:@"Accept" value:@"application/json"];
    [req setAllowCompressedResponse: NO];
    [req setDelegate: self];
    [req startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([[request responseString] rangeOfString:@"404"].location != NSNotFound)
        return [self requestFailed: request];
        
    NSLog(@"%@", [request responseString]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostEnded" object:nil];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostEnded" object: [request error]];
}

@end
