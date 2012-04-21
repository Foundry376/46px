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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        original = [[aDecoder decodeObjectForKey:@"original"] retain];
        changed = [[aDecoder decodeObjectForKey:@"changed"] retain];
        changeRegion = [[aDecoder decodeObjectForKey:@"changeRegion"] CGRectValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (original)
        [aCoder encodeObject:UIImagePNGRepresentation(original) forKey:@"original"];
    if (changed)
        [aCoder encodeObject:UIImagePNGRepresentation(changed) forKey:@"changed"];
    [aCoder encodeObject:[NSValue valueWithCGRect:changeRegion] forKey:@"changeRegion"];
}

- (void)dealloc
{
    [changed release];
    [original release];
    [super dealloc];
}
@end
