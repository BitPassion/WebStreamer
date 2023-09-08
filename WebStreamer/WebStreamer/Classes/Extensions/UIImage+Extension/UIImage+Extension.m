//
//  UIImage+Extension.m
//
//  Created by Olivier Halligon on 12/08/09.
//  Copyright 2009 AliSoftware. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (ResizeCategory)

- (UIImage*)resizedImageToSize:(CGSize)dstSize
{
	CGImageRef imgRef = self.CGImage;
	// the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
	
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return self;
    }
    
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = self.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;  
			
		case UIImageOrientationLeft: //EXIF = 6  
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;  
			
		case UIImageOrientationRightMirrored: //EXIF = 7  
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;  
			
		case UIImageOrientationRight: //EXIF = 8  
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;  
			
		default:  
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
	}  
	
	/////////////////////////////////////////////////////////////////////////////
	// The actual resize: draw the image on a new context, applying a transform matrix
	UIGraphicsBeginImageContextWithOptions(dstSize, NO, self.scale);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {  
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
	
	CGContextConcatCTM(context, transform);
	
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return resizedImage;
}

- (UIImage *)stretchImageToSize:(CGSize)dstSize {
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, dstSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, dstSize.width, dstSize.height), self.CGImage);
    UIImage *stretchedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return stretchedImage;
}

- (UIImage *)resizedImageToSize:(CGSize)dstSize scale:(CGFloat)scale {
    CGImageRef imgRef = self.CGImage;
    // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
    CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    dstSize.width *= scale;
    dstSize.height *= scale;
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return self;
    }
    
    UIImageOrientation orient = self.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    /////////////////////////////////////////////////////////////////////////////
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(context, transform);
    
    // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    [self drawInRect:CGRectMake(0, 0, dstSize.width, dstSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

/////////////////////////////////////////////////////////////////////////////


- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale {
	// get the image size (independant of imageOrientation)
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!

	// adjust boundingSize to make it independant on imageOrientation too for farther computations
	UIImageOrientation orient = self.imageOrientation;  
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            // NOP
            break;
	}

	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
	
	if ( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		//NSLog(@"Image is smaller, and we asked not to scale it in this case (scaleIfSmaller:NO)");
		dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
	} else {		
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
		
		if (wRatio < hRatio) {
			//NSLog(@"Width imposed, Height scaled ; ratio = %f",wRatio);
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		} else {
			//NSLog(@"Height imposed, Width scaled ; ratio = %f",hRatio);
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
		}
	}
		
	return [self resizedImageToSize:dstSize];
}

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);

    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);

    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);

    CGContextSetAlpha(ctx, alpha);

    CGContextDrawImage(ctx, area, self.CGImage);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)rotateImageByRadian:(CGFloat)radian {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radian);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [UIScreen mainScreen].scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radian);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotateImage;
}

- (UIImage *)cropImageWithRect:(CGRect)cropRect {
    if (self.scale > 1.0f) {
        cropRect = CGRectMake(cropRect.origin.x * self.scale,
                              cropRect.origin.y * self.scale,
                              cropRect.size.width * self.scale,
                              cropRect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)crop:(CGRect)rect {
    if (self.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)overlayImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [image drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *iimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return iimage;
}

- (UIImage *)overlayImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGRect frame;
    CGSize imageSize = image.size;
    if (contentMode == UIViewContentModeScaleAspectFit) {
        CGFloat imageScale = fmaxf(imageSize.width / self.size.width, imageSize.height / self.size.height);
        CGSize scaledImageSize = CGSizeMake(imageSize.width / imageScale, imageSize.height / imageScale);
        frame = CGRectMake(0.5f * (self.size.width - scaledImageSize.width),
                           0.5f * (self.size.height - scaledImageSize.height),
                           scaledImageSize.width,
                           scaledImageSize.height);
    } else if (contentMode == UIViewContentModeScaleAspectFill) {
        CGFloat imageScale = fminf(imageSize.width / self.size.width, imageSize.height / self.size.height);
        CGSize scaledImageSize = CGSizeMake(imageSize.width / imageScale, imageSize.height / imageScale);
        frame = CGRectMake(0.5f * (self.size.width - scaledImageSize.width),
                           0.5f * (self.size.height - scaledImageSize.height),
                           scaledImageSize.width,
                           scaledImageSize.height);
    } else {
        frame = CGRectMake(0, 0, self.size.width, self.size.height);
    }
    [image drawInRect:frame];
    UIImage *iimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return iimage;
}

- (UIImage *)imageWithOverlayColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)changeColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, YES, [[UIScreen mainScreen] scale]);
    
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = [self size];
    
    // Retrieve source image and begin image context
    CGSize itemImageSize = [self size];
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    UIGraphicsBeginImageContextWithOptions(contextRect.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [self CGImage]);
    // Fill and end the transparency layer
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
    const CGFloat* colors = CGColorGetComponents(color.CGColor);
    
    if(model == kCGColorSpaceModelMonochrome) {
        CGContextSetRGBFillColor(c, colors[0], colors[0], colors[0], colors[1]);
    }else{
        CGContextSetRGBFillColor(c, colors[0], colors[1], colors[2], colors[3]);
    }
    contextRect.size.height = -contextRect.size.height;
    contextRect.size.height -= 15;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)maskedImage:(UIImage *)mask {
    CGImageRef imageReference = self.CGImage;
    CGImageRef maskReference = mask.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL, // Decode is null
                                             YES // Should interpolate
                                             );
    
    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
}

+ (UIImage *)colorImage:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)colorImage:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale {
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
