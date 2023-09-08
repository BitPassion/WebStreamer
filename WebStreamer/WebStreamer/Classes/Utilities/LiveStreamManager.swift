//
//  LiveStreamManager.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 4/20/23.
//

import UIKit
import Logboard
import AVFoundation

class LiveStreamManager: NSObject {

    static let shared = LiveStreamManager()
    
    //fileprivate let RTMPServerURL = "rtmp://osp2.montanasat.net/stream"
    //fileprivate let RTMPStreamName = "77b61199-6187-430b-8293-3a39f4b36378"
    //fileprivate let RTMPServerURL = "rtmp://a.rtmp.youtube.com/live2"
    //fileprivate let RTMPStreamName = "vtpy-66a2-psgs-70p4-8vwx"
    fileprivate var RTMPServerURL = ""
    fileprivate var RTMPStreamName = ""

    fileprivate var rtmpConnection = RTMPConnection()
    fileprivate var rtmpStream: RTMPStream!

    fileprivate var reachability: Reachability!
    fileprivate let logger = LBLogger.with("com.RandomMusic.app")
    fileprivate let maxRetryCount: Int = 2
    fileprivate var retryCount: Int = 0
    
    fileprivate var artwork: UIImage? = nil
    fileprivate var artworkTimer: Timer? = nil
    fileprivate var connectionStatus: RTMPConnection.Code = .connectClosed
    
    var connections: [LiveStream] = []
    var currentConnectionIndex: Int = -1
    var currentConnection: LiveStream? = nil
    
    var isStreaming: Bool = false
    
    var didUpdateStatus: ((RTMPConnection.Code) -> Void)? = nil
    
    override init() {
        super.init()
        initialize()
        setupReachability()
        loadConnections()
    }
    
    func initialize() {
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        //rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
        //    print(error)
        //}
        
        // Specifies the audio codec settings.
        rtmpStream.audioSettings = AudioCodecSettings(
            bitRate: 64 * 1000//, format: .pcm
        )

        //rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)) { error in
        //    print(error)
        //}

        NotificationCenter.default.addObserver(self, selector: #selector(didInterruptionNotification(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRouteChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    fileprivate func setupReachability() {
        do {
            reachability = try Reachability(hostname: "osp2.montanasat.net")
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc fileprivate func reachabilityChanged() {
        print(reachability.connection)
    }
    
    fileprivate func loadConnections() {
        if let connects = UserDefaults.standard.object(forKey: kRTMPConnections) as? [[String: Any]] {
            for json in connects {
                connections.append(LiveStream(json: json))
            }
        }
        
        if let object = UserDefaults.standard.object(forKey: kRTMPCurrentConnectionIndex), let index = object as? Int {
            currentConnectionIndex = index
        }
        
        if currentConnectionIndex != -1 {
            let connection = connections[currentConnectionIndex]
            if connection.key != "" {
                RTMPStreamName = connection.key
                RTMPServerURL = connection.url
            } else {
                RTMPStreamName = (connection.url as NSString).lastPathComponent
                RTMPServerURL = connection.url.replacingOccurrences(of: RTMPStreamName, with: "")
            }
            currentConnection = connection
        }
    }
    
    func connection(with id: String) -> LiveStream? {
        if id == "" {
            return nil
        }
        
        return connections.first { connection in
            return connection.id == id
        }
    }
    
    func removeConnection(_ connection: LiveStream) {
        if let index = connections.firstIndex(where: { liveStream in
            return connection.id == liveStream.id
        }) {
            connections.remove(at: index)
            if index == currentConnectionIndex {
                currentConnectionIndex = -1
                currentConnection = nil
                //stop()
            }
        }
        
        var connections: [[String: Any]] = []
        for connection in self.connections {
            connections.append(connection.json)
        }
        
        UserDefaults.standard.set(connections, forKey: kRTMPConnections)
    }
    
    func saveConnection(_ connection: LiveStream) {
        if let index = connections.firstIndex(where: { liveStream in
            return connection.id == liveStream.id
        }) {
            connections[index] = connection
            if currentConnectionIndex == index {
                currentConnection = connection
            }
        } else {
            connections.append(connection)
        }
        
        if currentConnection == nil, connections.count == 1 {
            currentConnection = connections[0]
            currentConnectionIndex = 0
        }
        
        var connections: [[String: Any]] = []
        for connection in self.connections {
            connections.append(connection.json)
        }
        UserDefaults.standard.set(connections, forKey: kRTMPConnections)
    }
    
    func updateConnection() {
        UserDefaults.standard.set(currentConnectionIndex, forKey: kRTMPCurrentConnectionIndex)
        if currentConnectionIndex == -1 {
            stop()
            return
        }
        
        let connection = connections[currentConnectionIndex]
        if connection.key != "" {
            RTMPStreamName = connection.key
            RTMPServerURL = connection.url
        } else {
            RTMPStreamName = (connection.url as NSString).lastPathComponent
            RTMPServerURL = connection.url.replacingOccurrences(of: RTMPStreamName, with: "")
        }
        currentConnection = connection
        if isStreaming == true {
            stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.start()
            }
        }
    }
    
    func updateConnection(_ connection: LiveStream) {
        currentConnection = connection
        RTMPStreamName = connection.key
        RTMPServerURL = connection.url
    }
    
    func refreshConnection() {
        UserDefaults.standard.set(currentConnectionIndex, forKey: kRTMPCurrentConnectionIndex)
        if currentConnectionIndex == -1 {
            stop()
            return
        }
        
        let connection = connections[currentConnectionIndex]
        if connection.key != "" {
            RTMPStreamName = connection.key
            RTMPServerURL = connection.url
        } else {
            RTMPStreamName = (connection.url as NSString).lastPathComponent
            RTMPServerURL = connection.url.replacingOccurrences(of: RTMPStreamName, with: "")
        }
        currentConnection = connection
        if isStreaming == true {
            var audioSettings = rtmpStream.audioSettings
            if connection.audioBitrate == .auto {
                audioSettings.bitRate = 64 * 1000
            } else {
                audioSettings.bitRate = connection.audioBitrate.rawValue * 1000
            }
            //if audioSettings.bitRate > 160 * 1000 {
            //    audioSettings.bitRate = 160 * 1000
            //}
            rtmpStream.audioSettings = audioSettings

            var videoSettings = rtmpStream.videoSettings
            if connection.videoBitrate == .auto {
                videoSettings.bitRate = 2500 * 1000
            } else {
                videoSettings.bitRate = UInt32(connection.videoBitrate.rawValue * 1000)
            }
            rtmpStream.videoSettings = videoSettings

            rtmpStream.frameRate = Float64(connection.frameRate.rawValue)
            rtmpStream.mixer.videoIO.frameScale = connection.frameRate.frameScale
        }
    }
    
    func start() {
        guard let connection = currentConnection else {
            didUpdateStatus?(.connectFailed)
            return
        }
        //if reachability.connection == .unavailable {
        //    didUpdateStatus?(.connectFailed)
        //    return
        //}
        isStreaming = true
        UIApplication.shared.isIdleTimerDisabled = true
        var audioSettings = rtmpStream.audioSettings
        if connection.audioBitrate == .auto {
            audioSettings.bitRate = 64 * 1000
        } else {
            audioSettings.bitRate = connection.audioBitrate.rawValue * 1000
        }
        //if audioSettings.bitRate > 160 * 1000 {
        //    audioSettings.bitRate = 160 * 1000
        //}
        rtmpStream.audioSettings = audioSettings

        var videoSettings = rtmpStream.videoSettings
        if connection.videoBitrate == .auto {
            videoSettings.bitRate = 2500 * 1000
        } else {
            videoSettings.bitRate = UInt32(connection.videoBitrate.rawValue * 1000)
        }
        rtmpStream.videoSettings = videoSettings

        rtmpStream.frameRate = Float64(connection.frameRate.rawValue)
        rtmpStream.mixer.videoIO.frameScale = connection.frameRate.frameScale
        
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        rtmpConnection.connect(RTMPServerURL)
        //rtmpStream.publish(RTMPStreamName)
    }
    
    func pause() {
        rtmpStream.paused.toggle()
        isStreaming = false
    }
    
    func stop() {
        isStreaming = false
        UIApplication.shared.isIdleTimerDisabled = false
        rtmpConnection.close()
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    }
    
    func stop(isDisconnected: Bool) {
        isStreaming = false
        UIApplication.shared.isIdleTimerDisabled = false
        rtmpConnection.close(isDisconnected: isDisconnected)
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.removeEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
    }
    
    func sendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        if connectionStatus != .connectSuccess {
            return
        }
        //self.rtmpStream.mixer.audioIO.outputAudio(buffer)
        //self.rtmpStream.appendSampleBuffer(buffer)
    }
    
    func sendAudioBuffer(_ buffer: CMSampleBuffer) {
        if connectionStatus != .connectSuccess {
            return
        }
        //self.rtmpStream.mixer.audioIO.outputAudio(buffer)
        self.rtmpStream.appendSampleBuffer(buffer)
    }
    
    func sendVideoBuffer(_ buffer: CMSampleBuffer) {
        if connectionStatus != .connectSuccess {
            return
        }
        //self.rtmpStream.mixer.videoIO.outputVideo(buffer)
        self.rtmpStream.appendSampleBuffer(buffer)
    }
    
    func sendVideoBuffer(_ imageBuffer: CVPixelBuffer, _ duration: CMTime, _ presentationTimeStamp: CMTime) {
        if connectionStatus != .connectSuccess {
            return
        }
        //self.rtmpStream.mixer.videoIO.outputVideo(imageBuffer, duration, presentationTimeStamp)
        self.rtmpStream.appendSampleBuffer(imageBuffer, duration, presentationTimeStamp)
    }
    
    @objc fileprivate func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        logger.info(code)
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            retryCount = 0
            rtmpStream.publish(RTMPStreamName)
            //sharedObject!.connect(rtmpConnection)
        case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
            guard retryCount <= maxRetryCount else {
                return
            }
            Thread.sleep(forTimeInterval: pow(2.0, Double(retryCount)))
            rtmpConnection.connect(RTMPServerURL)
            retryCount += 1
        default:
            break
        }
        
        if let status = RTMPConnection.Code(rawValue: code) {
            connectionStatus = status
            didUpdateStatus?(status)
        }
    }

    @objc fileprivate func rtmpErrorHandler(_ notification: Notification) {
        logger.error(notification)
        rtmpConnection.connect(RTMPServerURL)
    }
    
    @objc fileprivate func didInterruptionNotification(_ notification: Notification) {
        logger.info(notification)
    }

    @objc fileprivate func didRouteChangeNotification(_ notification: Notification) {
        logger.info(notification)
    }
}
