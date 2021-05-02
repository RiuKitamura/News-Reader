//
//  NewsResponse.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 28/04/21.
//

import Foundation


struct NewsResponse: Decodable {
    let data: NewsData
}

struct NewsData: Decodable {
    let nextPage: String
    let rows: [NewsDetail]
}

struct NewsDetail: Decodable {
    let id: Int
    let title: String
    let subcategory: String
    let description: String
    let detailUrl: String
    let publishTime: Int
    let coverPic: [String]
    let pages: [Page]
    var didBookmarked = false
    
    private enum CodingKeys: String, CodingKey { case id, title, subcategory, description, detailUrl, publishTime, coverPic, pages}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subcategory = try container.decode(String.self, forKey: .subcategory)
        description = try container.decode(String.self, forKey: .description)
        detailUrl = try container.decode(String.self, forKey: .detailUrl)
        publishTime = try container.decode(Int.self, forKey: .publishTime)
        coverPic = try container.decode([String].self, forKey: .coverPic)
        pages = try container.decode([Page].self, forKey: .pages)
    }
    
    init(id: Int, title: String, category: String, desc: String, detailUrl: String, publishTime: Int, coverPic: [String], pages: [Page]) {
        self.id = id
        self.title = title
        self.subcategory = category
        self.description = desc
        self.detailUrl = detailUrl
        self.publishTime = publishTime
        self.coverPic = coverPic
        self.pages = pages
    }
}

struct Page: Decodable {
    let pageContent: String
}
