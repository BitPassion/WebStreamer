//
//  HistoryManager.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/10/23.
//

import UIKit

class HistoryManager: NSObject {

    static let shared = HistoryManager()
    
    private(set) var urls: [LiveURL] = []
    
    override init() {
        super.init()
        
        loadHistories()
    }
    
    private func loadHistories() {
        if let urls = UserDefaults.standard.object(forKey: kAppHistories) as? [[String: Any]] {
            for json in urls {
                self.urls.append(LiveURL(json: json))
            }
        }
    }
    
    func save() {
        let urls: [[String: Any]] = self.urls.map { $0.json }
        UserDefaults.standard.set(urls, forKey: kAppHistories)
    }
    
    func add(_ url: LiveURL) {
        urls.append(url)
        save()
    }
    
    func remove(_ url: LiveURL) {
        if let index = urls.firstIndex(where: { _url in
            return url.id == _url.id
        }) {
            urls.remove(at: index)
        }
        
        save()
    }
    
    func clear() {
        urls.removeAll()
        save()
    }
}
