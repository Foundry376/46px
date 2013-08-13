//
//  DrawingCollectionViewCell.h
//  46px
//
//  Created by Ben Gotow on 8/13/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PixelDrawing.h"

@interface DrawingCollectionViewCell : UICollectionViewCell
{
    UIImageView * _imageView;
}
@property (nonatomic, strong) PixelDrawing * drawing;

@end
