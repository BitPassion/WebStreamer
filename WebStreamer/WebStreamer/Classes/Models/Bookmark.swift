//
//  Bookmark.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/15/23.
//

import UIKit

class Bookmark: NSObject {

    var id: String = UUID().uuidString
    var name: String = ""
    var url: String = ""
    var date: Date = .init()
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case date
    }
    
    var json: [String: Any] {
        return [
            CodingKeys.id.rawValue: id,
            CodingKeys.name.rawValue: name,
            CodingKeys.url.rawValue: url,
            CodingKeys.date.rawValue: date
        ]
    }
    
    init(name: String, url: String) {
        super.init()
        
        self.name = name
        self.url = url
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
        
        if let date = json[CodingKeys.date.rawValue] as? Date {
            self.date = date
        }
    }
    
    override func copy() -> Any {
        let bookmark = Bookmark(json: json)
        return bookmark
    }
}
