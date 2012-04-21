//
//  PixelEditOperation.h
//  46px
//
//  Created by Ben Gotow on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PixelEditOperation : NSObject <NSCoding>
{
}

@property (nonatomic, retain) UIImage * original;
@property (nonatomic, retain) UIImage * changed;
@property (nonatomic, assign) CGRect changeRegion;


- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
