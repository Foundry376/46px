

UIImage* UIImageFromLayer(CGLayerRef layer, CGRect rect, BOOL flipped)
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (flipped) {
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -rect.size.height);
    }
    CGContextDrawLayerAtPoint(ctx, CGPointMake(-rect.origin.x, -rect.origin.y), layer);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

CGImageRef CGImageCreateFromData(NSData* data, CGSize size)
{
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * size.height);
    
    bitmapData = (void*)[data bytes];
    if ([data length] != bitmapByteCount)
        return nil;
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (bitmapData, size.width, size.height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorspace);
    if (context == NULL)
        // error creating context
        return nil;
    
    CGImageRef i = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return i;
}


NSData* CGImageGetData(CGImageRef image, CGRect region)
{
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    int width = region.size.width;
    int height = region.size.height;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = calloc( bitmapByteCount , sizeof(uint8_t));
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorspace);
    if (context == NULL)
        // error creating context
        return nil;
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -region.origin.x, -region.origin.y);
    CGContextDrawImage(context, CGRectMake(0,0,CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGContextRestoreGState(context);
    
    // When finished, release the context
    CGContextRelease(context);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    
    NSData * data = [NSData dataWithBytes:bitmapData length:bitmapByteCount];
    free(bitmapData);
    
    return data;
}
