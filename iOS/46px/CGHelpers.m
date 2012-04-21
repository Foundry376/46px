


UIImage* UIImageFromLayer(CGLayerRef layer, CGRect rect)
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -rect.size.height);
    CGContextDrawLayerAtPoint(ctx, CGPointMake(-rect.origin.x, -rect.origin.y), layer);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
