//
//  APIConnector.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIConnector : NSObject
{
    NSMutableArray *        drafts;
}

@property (nonatomic, retain) NSMutableArray * drafts;

#pragma mark Singleton Implementation

+ (APIConnector*)shared;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (oneway void)release;
- (id)autorelease;

- (NSString*)pathForNewDrawing;

@end
