//
//  LiveURLManager.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit

class LiveURLManager: NSObject {

    static let shared = LiveURLManager()
    
    var urls: [LiveURL] = []
    var currentURLIndex: Int = -1 {
        didSet {
            UserDefaults.standard.set(currentURLIndex, forKey: kAppCurrentURLIndex)
        }
    }
    var currentURL: LiveURL? {
        if urls.count > 0 {
            if currentURLIndex != -1, currentURLIndex < urls.count {
                return urls[currentURLIndex]
            } else {
                currentURLIndex = 0
                return urls[0]
            }
        }
        
        return nil
    }
    
    override init() {
        super.init()
        
        loadLiveURLs()
    }
    
    fileprivate func loadLiveURLs() {
        if let urls = UserDefaults.standard.object(forKey: kAppLiveURLs) as? [[String: Any]] {
            for json in urls {
                self.urls.append(LiveURL(json: json))
            }
        }
        
        if let object = UserDefaults.standard.object(forKey: kAppCurrentURLIndex), let index = object as? Int {
            currentURLIndex = index
        }
        
        if currentURLIndex != -1 {
            
        }
    }
    
    func removeURL(_ url: LiveURL) {
        if let index = urls.firstIndex(where: { liveURL in
            return url.id == liveURL.id
        }) {
            urls.remove(at: index)
            if index == currentURLIndex {
                currentURLIndex = -1
            }
        }
        
        let urls: [[String: Any]] = self.urls.map { $0.json }
        UserDefaults.standard.set(urls, forKey: kAppLiveURLs)
    }
    
    func saveURL(_ url: LiveURL) {
        if let index = urls.firstIndex(where: { liveURL in
            return url.id == liveURL.id
        }) {
            urls[index] = url
            if currentURLIndex == index {
                //currentURL = url
            }
        } else {
            urls.append(url)
        }
        
        if urls.count == 1 {
            currentURLIndex = 0
        }
        
        let urls: [[String: Any]] = self.urls.map { $0.json }
        UserDefaults.standard.set(urls, forKey: kAppLiveURLs)
    }
}
