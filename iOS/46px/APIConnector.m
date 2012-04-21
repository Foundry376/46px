//
//  APIConnector.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APIConnector.h"
#import "PixelDrawing.h"

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

@end
