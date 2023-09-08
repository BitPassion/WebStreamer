//
//  ScreenRecorder.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/2/23.
//

import Foundation
import ReplayKit
import CoreImage
import CoreMedia

class ScreenRecorder: NSObject {
    
    static let shared = ScreenRecorder()
    
    fileprivate let recorder: RPScreenRecorder = RPScreenRecorder.shared()
    
    fileprivate var context = CIContext()
    fileprivate var saves: Int = 0
    fileprivate var isAudioAllowed: Bool = false
    fileprivate var isMicrophoneAllowed: Bool = false
    fileprivate var audioBuffer: CMSampleBuffer? = nil
    fileprivate var isRecording: Bool = false
    
    var orientation: UIInterfaceOrientation = .portrait
    
    var isLandscape: Bool {
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    override init() {
        super.init()
        
        recorder.isCameraEnabled = false
        recorder.isMicrophoneEnabled = false
        recorder.delegate = self
    }
    
    func start(_ completion: @escaping (Bool, Error?) -> Void) {
        if isRecording {
            completion(true, nil)
            return
        }
        
        if LiveStreamManager.shared.currentConnection == nil {
            completion(false, nil)
            return
        }
        
        recorder.startCapture { sampleBuffer, bufferType, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let connection = LiveStreamManager.shared.currentConnection else {
                completion(false, nil)
                return
            }
            
            switch bufferType {
            case .video:
                if connection.mode != .audio {
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        var image = CIImage(cvImageBuffer: imageBuffer)
                        let width = CVPixelBufferGetWidth(imageBuffer)
                        let height = CVPixelBufferGetHeight(imageBuffer)
                        if self.isLandscape, width < height {
                            image = image.resize(image.extent.height, image.extent.width)
                            let imageBuffer = image.pixelBuffer(imageBuffer)
                            LiveStreamManager.shared.sendVideoBuffer(imageBuffer!, sampleBuffer.duration, sampleBuffer.presentationTimeStamp)
                        } else {
                            LiveStreamManager.shared.sendVideoBuffer(sampleBuffer)
                        }
                    }
                    //LiveStreamManager.shared.sendVideoBuffer(sampleBuffer)
                    //if let pixelBuffer = self.resizePixelBuffer(sampleBuffer) {
                    //    LiveStreamManager.shared.sendVideoBuffer(pixelBuffer, sampleBuffer.duration, sampleBuffer.presentationTimeStamp)
                    //}
                }
                break
            case .audioApp:
                self.isAudioAllowed = true
                if connection.mode != .video {
                    if self.isMicrophoneAllowed {
                        self.audioBuffer = sampleBuffer
                    } else {
                        LiveStreamManager.shared.sendAudioBuffer(sampleBuffer)
                        //print(sampleBuffer)
                    }
                }
                break
            case .audioMic:
                self.isMicrophoneAllowed = true
                //LiveStreamManager.shared.sendAudioBuffer(sampleBuffer)
                break
            default:
                print("ScreenRecorder - error")
                break
            }
        } completionHandler: { error in
            if let error = error {
                print(error.localizedDescription)
                completion(false, error)
            } else {
                self.isRecording = true
                completion(true, nil)
            }
        }
    }
    
    func stop(_ completion: @escaping (Bool) -> Void) {
        recorder.stopCapture { error in
            self.isRecording = false
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    fileprivate func resizePixelBuffer(_ sampleBuffer: CMSampleBuffer) -> CVPixelBuffer? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        var image = CIImage(cvImageBuffer: imageBuffer)
        if width % 2 == 0, height % 2 == 0 {
            return imageBuffer
        } else if width % 2 == 1, height % 2 == 1 {
            image = image.cropped(to: CGRect(x: 0, y: 0, width: width - 1, height: height - 1))
        } else if width % 2 == 1 {
            image = image.cropped(to: CGRect(x: 0, y: 0, width: width - 1, height: height))
        } else {
            image = image.cropped(to: CGRect(x: 0, y: 0, width: width, height: height - 1))
        }
        //print("imageSize width = \(image.extent.width), imageSize height = \(image.extent.height)")
        let buffer = image.pixelBuffer(imageBuffer)
        return buffer
    }
}

// MARK: - RPScreenRecorderDelegate
extension ScreenRecorder: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        print("RPScreenRecorder isAvailable = \(screenRecorder.isAvailable)")
    }
    
    func screenRecorder(_ screenRecorder: RPScreenRecorder, didStopRecordingWith previewViewController: RPPreviewViewController?, error: Error?) {
        print("RPScreenRecorder didStopRecording = \(error?.localizedDescription ?? "No error")")
    }
}
