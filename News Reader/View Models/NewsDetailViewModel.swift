//
//  NewsDetailViewModel.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 30/04/21.
//

import UIKit

struct NewsDetailViewModel {
    private var newsDetail: NewsDetail
    private let db = CoreDataMenegaer()

    init(newsDetail: NewsDetail) {
        self.newsDetail = newsDetail
    }
    
    var category: String {
        return self.newsDetail.subcategory
    }
    
    var detailUrl: URL? {
        return URL(string: self.newsDetail.detailUrl)
    }
    
    /// update bookmark status in view model
    private mutating func updateBookmarkStatus(status: Bool) {
        self.newsDetail.didBookmarked = status
    }
    
    /// cek bookmark status
    mutating func cekBookmark() {
        
        let pred = NSPredicate(format: "id == %@", String(newsDetail.id))
        let data = db.fetchData(ofType: Bookmark.self, with: pred)
        if data != nil {
            self.updateBookmarkStatus(status: true)
        } else {
            self.updateBookmarkStatus(status: false)

        }
        
    }
    
    var page: String {
        return self.newsDetail.pages.first?.pageContent ?? ""
    }
    
    var bookmarkImageIcon: UIImage? {
        if newsDetail.didBookmarked {
            return UIImage(systemName: "bookmark.fill")
        }
        return UIImage(systemName: "bookmark")
    }
    
    var isBookmarked: Bool {
        return self.newsDetail.didBookmarked
    }
    
    mutating func addBookmark() {
        var result = self
        db.addBookmark(news: newsDetail) { (isSuccess) in
            if isSuccess {
                result.updateBookmarkStatus(status: true)
            } else {
                result.updateBookmarkStatus(status: false)
            }
        }
        self = result
    }
    
    /// delete bookmark from database
    mutating func deleteBookmark() {
        var result = self
        
        let pred = NSPredicate(format: "id == %@", String(newsDetail.id))
        
        db.deleteSpecificData(ofType: Bookmark.self, with: pred) { (isSuccess) in
            if isSuccess {
                result.updateBookmarkStatus(status: false)
            } else {
                result.updateBookmarkStatus(status: true)
            }
        }
        
        self = result
        
    }
}
