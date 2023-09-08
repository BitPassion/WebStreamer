//
//  CIImage+Extension.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/2/23.
//

import Foundation
import UIKit
import CoreMedia

let _context = CIContext()
let _resizeFilter = CIFilter(name:"CILanczosScaleTransform")!

extension CIImage {
    
    var imageBuffer: CVPixelBuffer? {
        let size = extent.size
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        ]
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        guard let pixelBuffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        _context.render(self, to: pixelBuffer)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    var sampleBuffer: CMSampleBuffer? {
        guard let pixelBuffer = imageBuffer else { return nil }
        var newSampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = .invalid
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        guard let videoInfo = videoInfo else { return nil }
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo, sampleTiming: &timimgInfo, sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer
    }
    
    func pixelBuffer(_ imageBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let size = extent.size
        var pixelBuffer: CVPixelBuffer? = nil
        //let format = CVPixelBufferGetPixelFormatType(imageBuffer)
        //let description = CVPixelFormatDescriptionCreateWithPixelFormatType(nil, format)
        //let options: [NSObject: Any] = [
        //    kCVPixelBufferCGImageCompatibilityKey: true,
        //    kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        //]
        let options: [NSObject: Any] = [
            kCVPixelBufferExtendedPixelsTopKey: 0,
            kCVPixelBufferExtendedPixelsLeftKey: 0,
            kCVPixelBufferExtendedPixelsBottomKey: 0,
            kCVPixelBufferExtendedPixelsRightKey: 10,
        ]
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        guard let pixelBuffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        _context.render(self, to: pixelBuffer)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    func sampleBuffer(_ timestamp: CMTime, _ duration: CMTime) -> CMSampleBuffer? {
        guard let pixelBuffer = imageBuffer else { return nil }
        var newSampleBuffer: CMSampleBuffer? = nil
        var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo(duration: duration, presentationTimeStamp: timestamp, decodeTimeStamp: .zero)
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        guard let videoInfo = videoInfo else { return nil }
        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescription: videoInfo, sampleTiming: &timingInfo, sampleBufferOut: &newSampleBuffer)
        
        return newSampleBuffer
    }
    
    func resize(_ width: CGFloat, _ height: CGFloat) -> CIImage {
        let scale = height / extent.height
        let aspectRatio = width / (extent.width * scale)

        _resizeFilter.setValue(self, forKey: kCIInputImageKey)
        _resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        _resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let outputImage = _resizeFilter.outputImage!
        return outputImage
    }
}
