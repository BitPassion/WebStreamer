//
//  BookmarkManager.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/15/23.
//

import UIKit

class BookmarkManager: NSObject {

    static let shared = BookmarkManager()
    
    private(set) var bookmarks: [Bookmark] = []
    
    override init() {
        super.init()
        
        loadBookmarks()
    }
    
    fileprivate func loadBookmarks() {
        self.bookmarks.removeAll()
        if let urls = UserDefaults.standard.object(forKey: kAppBookmarks) as? [[String: Any]] {
            for json in urls {
                self.bookmarks.append(Bookmark(json: json))
            }
        }
    }
    
    func removeBookmark(_ bookmark: Bookmark) {
        if let index = bookmarks.firstIndex(where: { _bookmark in
            return bookmark.id == _bookmark.id
        }) {
            bookmarks.remove(at: index)
        }
        
        let bookmarks: [[String: Any]] = self.bookmarks.map { $0.json }
        UserDefaults.standard.set(bookmarks, forKey: kAppBookmarks)
    }
    
    func removeBookmark(_ url: String) {
        if let index = bookmarks.firstIndex(where: { _bookmark in
            return url == _bookmark.url
        }) {
            bookmarks.remove(at: index)
        }
        
        let bookmarks: [[String: Any]] = self.bookmarks.map { $0.json }
        UserDefaults.standard.set(bookmarks, forKey: kAppBookmarks)
    }
    
    func saveBookmark(_ bookmark: Bookmark) {
        if let index = bookmarks.firstIndex(where: { _bookmark in
            return bookmark.id == _bookmark.id
        }) {
            bookmarks[index] = bookmark
        } else {
            bookmarks.append(bookmark)
        }
        
        let bookmarks: [[String: Any]] = self.bookmarks.map { $0.json }
        UserDefaults.standard.set(bookmarks, forKey: kAppBookmarks)
    }
    
    func isBookmarked(_ url: String) -> Bool {
        return bookmarks.contains(where: { bookmark in
            return bookmark.url == url
        })
    }
}
