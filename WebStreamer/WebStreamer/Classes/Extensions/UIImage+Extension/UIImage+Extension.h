#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage(Extension)

- (UIImage *)resizedImageToSize:(CGSize)dstSize;
- (UIImage *)stretchImageToSize:(CGSize)dstSize;
- (UIImage *)resizedImageToSize:(CGSize)dstSize scale:(CGFloat)scale;
- (UIImage *)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
- (UIImage *)rotateImageByRadian:(CGFloat)radian;
- (UIImage *)cropImageWithRect:(CGRect)cropRect;
- (UIImage *)crop:(CGRect)rect;
- (UIImage *)overlayImage:(UIImage *)image;
- (UIImage *)overlayImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode;
- (UIImage *)imageWithOverlayColor:(UIColor *)color;
- (UIImage *)changeColor:(UIColor *)color;
- (UIImage *)maskedImage:(UIImage *)mask;

+ (UIImage *)colorImage:(UIColor *)color size:(CGSize)size;
+ (UIImage *)colorImage:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale;

@end
