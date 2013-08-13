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
        _imageView = [[UIImageView alloc] initWithFrame: frame];
        [_imageView setBackgroundColor: [UIColor whiteColor]];
        [self.contentView addSubview: _imageView];
        [[self layer] setBorderWidth: 2];
        [[self layer] setBorderColor: [[UIColor colorWithWhite:0 alpha:0.3] CGColor]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_imageView setFrame: self.bounds];
}

- (void)setDrawing:(PixelDrawing *)drawing
{
    _drawing = drawing;
    [_imageView setImage: [drawing image]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_imageView setImage: nil];
}
@end
