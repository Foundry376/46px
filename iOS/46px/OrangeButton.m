//
//  OrangeButton.m
//  46px
//
//  Created by Ben Gotow on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OrangeButton.h"

@implementation OrangeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIImage * bb = [UIImage imageNamed:@"button_background.png"];
    UIImage * bbd = [UIImage imageNamed:@"button_background_down.png"];
    UIImage * bbh = [UIImage imageNamed:@"button_background_highlighted.png"];
    UIImage * bbdh = [UIImage imageNamed:@"button_background_down+highlighted.png"];
    
    bb = [bb stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    bbd = [bbd stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    bbh = [bbh stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    bbdh = [bbdh stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize: 22]];
    [self setBackgroundImage:bb forState:UIControlStateNormal];
    [self setBackgroundImage:bbd forState:UIControlStateSelected];
    [self setBackgroundImage:bbh forState:UIControlStateHighlighted];
    [self setBackgroundImage:bbdh forState:UIControlStateSelected | UIControlStateHighlighted];
    [self setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [[self titleLabel] setShadowOffset: CGSizeMake(0, 1)];
    
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueChangeSetting context:nil];
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueChangeSetting context:nil];
    
    baseImageInsets = [self imageEdgeInsets];
    baseTitleInsets = [self titleEdgeInsets];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"selected"] || [keyPath isEqualToString:@"highlighted"]){   
        if(self.selected || self.highlighted){
            [self setTitleEdgeInsets: UIEdgeInsetsMake(baseTitleInsets.top + 3, baseTitleInsets.left + 3, baseTitleInsets.bottom - 3, baseTitleInsets.right - 3)];
            [self setImageEdgeInsets: UIEdgeInsetsMake(baseImageInsets.top + 3, baseImageInsets.left + 3, baseImageInsets.bottom - 3, baseImageInsets.right - 3)];   
            
        } else {
            [self setTitleEdgeInsets: baseTitleInsets];
            [self setImageEdgeInsets: baseImageInsets];   
        }
    } 
}

- (void)dealloc
{
    [super dealloc];
}

@end
