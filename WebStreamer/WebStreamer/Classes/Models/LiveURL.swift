//
//  LiveStream.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/22/23.
//

import UIKit

class LiveURL: NSObject {

    var id: String = UUID().uuidString
    var connectionId: String = ""
    var name: String = ""
    var url: String = ""
    var date: Date = .init()
    
    enum CodingKeys: String, CodingKey {
        case id
        case connectionId
        case name
        case url
        case date
    }
    
    var json: [String: Any] {
        return [
            CodingKeys.id.rawValue: id,
            CodingKeys.connectionId.rawValue: connectionId,
            CodingKeys.name.rawValue: name,
            CodingKeys.url.rawValue: url,
            CodingKeys.date.rawValue: date
        ]
    }
    
    var thumbURL: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Thumbnails")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url.appendingPathComponent("\(id).jpg")
    }
    
    init(name: String, connectionId: String, url: String) {
        super.init()
        
        self.name = name
        self.connectionId = connectionId
        self.url = url
    }
    
    init(json: [String: Any]) {
        super.init()
        
        if let id = json[CodingKeys.id.rawValue] as? String {
            self.id = id
        }
        
        if let connectionId = json[CodingKeys.connectionId.rawValue] as? String {
            self.connectionId = connectionId
        }
        
        if let name = json[CodingKeys.name.rawValue] as? String {
            self.name = name
        }
        
        if let url = json[CodingKeys.url.rawValue] as? String {
            self.url = url
        }
        
        if let date = json[CodingKeys.date.rawValue] as? Date {
            self.date = date
        }
    }
    
    override func copy() -> Any {
        let connection = LiveStream(json: json)
        return connection
    }
}
