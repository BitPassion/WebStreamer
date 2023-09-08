//
//  LiveStream.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/22/23.
//

import UIKit

enum LiveStreamMode: Int {
    case audioVideo = 0
    case video
    case audio
    
    var title: String {
        switch self {
        case .audioVideo:
            return "Audio + Video"
            
        case .video:
            return "Video only"
            
        case .audio:
            return "Audio only"
        }
    }
}

enum LiveStreamTargetType: Int {
    case `default` = 0
    case audio
    case video
    
    var title: String {
        switch self {
        case .default:
            return "Default"
            
        case .audio:
            return "Audio"
            
        case .video:
            return "Video"
        }
    }
}

enum LiveStreamBitrate: Int {
    case auto = 0
    case bps96 = 96
    case bps128 = 128
    case bps160 = 160
    case bps256 = 256
    case bps320 = 320
    case bps1200 = 1200
    case bps2500 = 2500
    case bps3500 = 3500
    case bps4500 = 4500
    case bps5500 = 5500
    case bps6500 = 6500
    
    var title: String {
        switch self {
        case .auto:
            return "Auto"
            
        case .bps96:
            return "96 Kbps"
            
        case .bps128:
            return "128 Kbps"
            
        case .bps160:
            return "160 Kbps"
            
        case .bps256:
            return "256 Kbps"
            
        case .bps320:
            return "320 Kbps"
            
        case .bps1200:
            return "1200 Kbps"
            
        case .bps2500:
            return "2500 Kbps"
            
        case .bps3500:
            return "3500 Kbps"
            
        case .bps4500:
            return "4500 Kbps"
            
        case .bps5500:
            return "5500 Kbps"
            
        case .bps6500:
            return "6500 Kbps"
        }
    }
}

enum LiveStreamFrameRate: Int {
    case fps10 = 10
    case fps15 = 15
    case fps20 = 20
    case fps25 = 25
    case fps30 = 30
    case fps50 = 50
    case fps60 = 60
    case fps120 = 120
    
    var title: String {
        switch self {
        case .fps10:
            return "10 fps"
            
        case .fps15:
            return "15 fps"
            
        case .fps20:
            return "20 fps"
            
        case .fps25:
            return "25 fps"
            
        case .fps30:
            return "30 fps"
            
        case .fps50:
            return "50 fps"
            
        case .fps60:
            return "60 fps"
            
        case .fps120:
            return "120 fps"
        }
    }
    
    var frameScale: CGFloat {
        switch self {
        case .fps10:
            return 1.20
            
        case .fps15:
            return 1.16
            
        case .fps20:
            return 1.10
            
        case .fps25:
            return 1.08
            
        case .fps30:
            return 1.00
            
        case .fps50:
            return 0.92
            
        case .fps60:
            return 0.82
            
        case .fps120:
            return 0.64
        }
    }
}

class LiveStream: NSObject {

    var id: String = UUID().uuidString
    var name: String = ""
    var url: String = ""
    var key: String = ""
    var mode: LiveStreamMode = .audioVideo
    var targetType: LiveStreamTargetType = .default
    var audioBitrate: LiveStreamBitrate = .auto
    var videoBitrate: LiveStreamBitrate = .auto
    var frameRate: LiveStreamFrameRate = .fps30
    var login: String = ""
    var password: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case key
        case mode
        case targetType
        case audioBitrate
        case videoBitrate
        case frameRate
        case login
        case password
    }
    
    var json: [String: Any] {
        return [
            CodingKeys.id.rawValue: id,
            CodingKeys.name.rawValue: name,
            CodingKeys.url.rawValue: url,
            CodingKeys.key.rawValue: key,
            CodingKeys.mode.rawValue: mode.rawValue,
            CodingKeys.targetType.rawValue: targetType.rawValue,
            CodingKeys.audioBitrate.rawValue: audioBitrate.rawValue,
            CodingKeys.videoBitrate.rawValue: videoBitrate.rawValue,
            CodingKeys.frameRate.rawValue: frameRate.rawValue,
            CodingKeys.login.rawValue: login,
            CodingKeys.password.rawValue: password,
        ]
    }
    
    init(name: String, url: String, key: String, mode: LiveStreamMode, targetType: LiveStreamTargetType, audioBitrate: LiveStreamBitrate, videoBitrate: LiveStreamBitrate, frameRate: LiveStreamFrameRate, login: String, password: String) {
        super.init()
        
        self.name = name
        self.url = url
        self.key = key
        self.mode = mode
        self.targetType = targetType
        self.audioBitrate = audioBitrate
        self.videoBitrate = videoBitrate
        self.frameRate = frameRate
        self.login = login
        self.password = password
    }
    
    init(json: [String: Any]) {
        super.init()
        
        if let id = json[CodingKeys.id.rawValue] as? String {
            self.id = id
        }
        
        if let name = json[CodingKeys.name.rawValue] as? String {
            self.name = name
        }
        
        if let url = json[CodingKeys.url.rawValue] as? String {
            self.url = url 
        }
        
        if let key = json[CodingKeys.key.rawValue] as? String {
            self.key = key
        }
        
        if let rawValue = json[CodingKeys.mode.rawValue] as? Int, let mode = LiveStreamMode(rawValue: rawValue) {
            self.mode = mode
        }
        
        if let rawValue = json[CodingKeys.targetType.rawValue] as? Int, let targetType = LiveStreamTargetType(rawValue: rawValue) {
            self.targetType = targetType
        }
        
        if let rawValue = json[CodingKeys.audioBitrate.rawValue] as? Int, let audioBitrate = LiveStreamBitrate(rawValue: rawValue) {
            self.audioBitrate = audioBitrate
        }
        
        if let rawValue = json[CodingKeys.videoBitrate.rawValue] as? Int, let videoBitrate = LiveStreamBitrate(rawValue: rawValue) {
            self.videoBitrate = videoBitrate
        }
        
        if let rawValue = json[CodingKeys.frameRate.rawValue] as? Int, let frameRate = LiveStreamFrameRate(rawValue: rawValue) {
            self.frameRate = frameRate
        }
        
        if let login = json[CodingKeys.login.rawValue] as? String {
            self.login = login
        }
        
        if let password = json[CodingKeys.password.rawValue] as? String {
            self.password = password
        }
    }
    
    override func copy() -> Any {
        let connection = LiveStream(json: json)
        return connection
    }
}
