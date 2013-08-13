//
//  DrawingCollectionViewCell.m
//  46px
//
//  Created by Ben Gotow on 8/13/13.
//
//

#import "DrawingCollectionViewCell.h"

@implementation DrawingCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor whiteColor]];
        [[self layer] setBorderWidth: 2];
        [[self layer] setBorderColor: [[UIColor colorWithWhite:0 alpha:0.3] CGColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, rect.size.height);
    CGContextScaleCTM(c, 1, -1);
    CGContextSetInterpolationQuality(c, kCGInterpolationNone);
    CGContextDrawImage(c, CGRectInset(rect, 2, 2), [[_drawing image] CGImage]);
}

- (void)setDrawing:(PixelDrawing *)drawing
{
    _drawing = drawing;
    [self setNeedsDisplay];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _drawing = nil;
}

@end
