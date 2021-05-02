//
//  NewsViewModel.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 28/04/21.
//

import UIKit

//MARK: - NewsListViewModel

class NewsListViewModel {
    
    private(set) var nextPageLink = "" // link to download next page news data
    private(set) var isLoading = false // to indicate that data is stil get loaded
    private(set) var newsViewModels = [NewsViewModel]()
    private let db = CoreDataMenegaer()
    
    /// add new newsViewModels array
    private func addNewsViewModels(_ vm: [NewsViewModel]) {
        self.newsViewModels.append(contentsOf: vm)
    }
    
    // reset news view model array  if user refresh page
    private func resetNewsViewModels() {
        self.newsViewModels = []
    }
    
    // update loading status when fetch data
    private func updateLoadingStatus() {
        self.isLoading = !isLoading
    }
    
    /// fetch news data and add to view model
    func fetchData(with link: String, isRefreshingData: Bool? = false, completion: @escaping (Bool) -> Void) {
        
        guard let url = URL(string: link) else { return }
        let resource = Resource<NewsResponse>(url: url)
        updateLoadingStatus()
        
        Webservice().fetchNews(resource: resource) { (result) in
            self.updateLoadingStatus()

            switch result {
            case .success(let newsResponse):
                let vmList = newsResponse.data.rows.map { NewsViewModel($0)}
                
                // if fetching data is to refres page, delete or reset current news view model
                if isRefreshingData! {
                    self.resetNewsViewModels()
                }
                // add news view model to list
                self.addNewsViewModels(vmList)
                self.nextPageLink = newsResponse.data.nextPage
                completion(true)
            case .failure(let error):
                completion(false)
                print("DEBUG: \(error)")
            }
        }
    }
    
    /// cek if news is bookmarked or not
    func cekBookmark(index: Int) {
        let pred = NSPredicate(format: "id == %@", String(newsViewModels[index].newsId))
        let data = db.fetchData(ofType: Bookmark.self, with: pred)
        if data != nil {
            self.newsViewModels[index].updateBookmarkSaturs(status: true)
            return
        } else {
            self.newsViewModels[index].updateBookmarkSaturs(status: false)
        }
    }
    
    /// to add new bookmark to core data
    func addBookmark(index: Int) {
        let news = newsViewModels[index].news
        db.addBookmark(news: news) { (isSuccess) in
            if isSuccess {
                self.newsViewModels[index].updateBookmarkSaturs(status: true)
            } else {
                self.newsViewModels[index].updateBookmarkSaturs(status: false)
            }
        }
    }
    
    /// delete selected news bookmark from coredata
    func deleteBookmark(index: Int) {
        
        let pred = NSPredicate(format: "id == %@", String(newsViewModels[index].newsId))
        db.deleteSpecificData(ofType: Bookmark.self, with: pred) { (isSuccess) in
            if isSuccess {
                self.newsViewModels[index].updateBookmarkSaturs(status: false)
            } else {
                self.newsViewModels[index].updateBookmarkSaturs(status: true)
            }
        }
        
    }
    
    func shouldHideEmptyStage() -> Bool {
        return self.newsViewModels.count > 0 ? true : false
    }
}

//MARK: - NewsViewModel

struct NewsViewModel {
    private(set) var news: NewsDetail
    
    init(_ news: NewsDetail) {
        self.news = news
    }
    
    var newsId: Int {
        return news.id
    }
    
    var publishTime: String {
        let date = Date(timeIntervalSince1970: Double(self.news.publishTime))
        return date.timeAgoDisplay().uppercased()
    }

    var publishTimeInteger: Int {
        return self.news.publishTime
    }
    
    var newsTitle: String {
        return self.news.title
    }
    
    var newsSubTitle: String {
        return self.news.description
    }
    
    var newsCategory: String {
        return self.news.subcategory
    }
    
    var newsDetailUrl: String {
        return self.news.detailUrl
    }
    
    var imageUrl: String {
        guard self.news.coverPic.count != 0 else { return "" }
        return self.news.coverPic[0]
    }
    
    var isBookmarked: Bool {
        return self.news.didBookmarked
    }
    
    mutating func updateBookmarkSaturs(status: Bool) {
        self.news.didBookmarked = status
    }
    
    var bookmarkImage: UIImage? {
        if self.news.didBookmarked {
            return UIImage(systemName: "book.fill")
        }
        return UIImage(systemName: "book")
    }
    
    var bookmarkTitle: String {
        if self.news.didBookmarked {
            return "Bookmarked"
        }
        return "Bookmark"
    }

}
