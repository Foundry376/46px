//
//  APIConnector.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@class PixelDrawing;

@interface APIConnector : NSObject <ASIHTTPRequestDelegate>
{
    NSMutableArray *        drafts;
}

@property (nonatomic, strong) NSMutableArray * drafts;

#pragma mark Singleton Implementation

+ (APIConnector*)shared;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;

- (void)removeFromCache:(PixelDrawing*)d;
- (NSString*)pathForNewDrawing;
- (void)postDrawing:(PixelDrawing*)d;
- (void)updateUserTableWithUserID:(NSString *)userID;

@end
