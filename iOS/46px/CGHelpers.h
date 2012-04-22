
typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} RGBAPixel;

UIImage* UIImageFromLayer(CGLayerRef layer, CGRect rect, BOOL flipped);
CGImageRef CGImageCreateFromData(NSData* data, CGSize size);
NSData* CGImageGetData(CGImageRef image, CGRect region);