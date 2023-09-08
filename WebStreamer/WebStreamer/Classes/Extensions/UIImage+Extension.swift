//
//  UIImage+Extension.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/2/23.
//

import Foundation
import UIKit
import CoreMedia
import SVGKit
import SDWebImage

extension UIImage {
    var cvPixelBuffer: CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey: false,
            ]
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)
        guard let pixelBuffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue)
        context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    var sampleBuffer: CMSampleBuffer? {
        guard let pixelBuffer = cvPixelBuffer else { return nil }
        var newSampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = .invalid
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        guard let videoInfo = videoInfo else { return nil }
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo, sampleTiming: &timimgInfo, sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer
    }
    
    class func svgImage(named: String, color: UIColor, size: CGSize) -> UIImage? {
        let url = Bundle.main.url(forResource: named, withExtension: "svg")!
        let image = SVGKImage(contentsOf: url)
        return image?.uiImage.withTintColor(color).sd_resizedImage(with: size, scaleMode: .aspectFit)
    }
}
