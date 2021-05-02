//
//  BookmarkViewModel.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 30/04/21.
//

import UIKit

class BookmarkListViewModel {
    
    private(set) var bookmarkViewModels = [NewsViewModel]()
    private let db = CoreDataMenegaer()
    
    /// fetch bookmark data adn add to view model
    func fetchData(completion: @escaping(Bool) -> Void) {
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let data = db.fetchAllData(ofType: Bookmark.self, with: [sort])
        guard let saveData = data else {
            completion(false)
            return
        }
        
        let vm = saveData.map { (data) -> NewsViewModel in
            let bookmark = data
            let newsDetail = NewsDetail(id: Int(bookmark.id!)!, title: bookmark.title!, category: bookmark.subCategory!, desc: bookmark.desc!, detailUrl: bookmark.detailUrl!, publishTime: Int(bookmark.publishTime), coverPic: [bookmark.coverPic!], pages: [Page(pageContent: bookmark.page!)])
            return NewsViewModel(newsDetail)
        }
        self.bookmarkViewModels = vm
        completion(true)
    }
    /// delete bookmark view model at selected row or index
    func deleteRow(index: Int) {
        bookmarkViewModels.remove(at: index)
    }
    
    /// cek if bookmark data is empty or not
    func isDataEempty() -> Bool {
        return self.bookmarkViewModels.count == 0 ? true : false
    }
}

