//
//  PixelEditOperation.m
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PixelEditOperation.h"

@implementation PixelEditOperation

@synthesize original, changed, changeRegion;

- (void)dealloc
{
    [changed release];
    [original release];
    [super dealloc];
}
@end
